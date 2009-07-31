# VirtualRoom.pm
# Created Aug 2006
# Author  flogisto
# 
=pod

=head1 DESCRIPTION

 This package allows you to build tousands of rooms very similar each other
 using few configuration files.

 You can build a grid of rooms or places without specifically programming each room.
 In the grid each room is identified on a map by a couple of coordinates (x horizontal,
 y vertical); the grid is based on few configuration file: ccc_grid.txt, ccc_prop.txt
 ccc_short.txt, ccc_long.txt, where "ccc" shoul be an acronym that identifies the map
 itself. In this way it is possible to define several maps.
 
 The ccc_clon.txt contains descriptions for cloned-objects (like add_object).
 
 In the file ccc_grid.txt the map logic-wideness is given by the length of the first 
 usable row (divided by 2 and minus 2), because each cell is defined by a couple of 
 characters. The map logic-height is given by the number of usable rows.
 
 In particular, codes that begins with "0" are "special" and "inaccessible" and the 
 adjacent cells give information of that with a small standard wording.
 
 First colums is not part of the grid, so it can be used as ruler. Last column also.

 In our case, the Mondo Emerso map is defined by a file "em_grid.txt" which defines
 a 62 x 50 cells grid. Definitions of the "couple of characters" are coded in the
 files em_short.txt, em_long.txt, em_clon.txt
 
=cut

package VirtualRoom;
use strict;

##use diagnostics;
use Commons;
use Room

our @ISA = qw(Room);

# these variabiles are "global" within Virtual Rooms
# they are indexed by the "grid_name" + "desc-code"
my $gridfile   = {} ;
my $grid       = {} ;
my $longdescs  = {} ;
my $shortdescs = {} ;
my $properties = {} ;                        
my $clones     = {} ;
my $centers    = {} ;
my $maxx       = {} ;
my $maxy       = {} ;
my $maxz       = {} ;
               
# ---------------------------------------------------------------------
sub grid_name       { (@_)>1 ? ($_[0]->{GridName}      = $_[1],$_[0]) : $_[0]->{GridName}       } 
sub coord_x         { (@_)>1 ? ($_[0]->{CoordX  }      = $_[1],$_[0]) : $_[0]->{CoordX  }       } 
sub coord_y         { (@_)>1 ? ($_[0]->{CoordY  }      = $_[1],$_[0]) : $_[0]->{CoordY  }       } 
sub coord_z         { (@_)>1 ? ($_[0]->{CoordZ  }      = $_[1],$_[0]) : $_[0]->{CoordZ  }       } 
sub desc_code       { (@_)>1 ? ($_[0]->{DescCode}      = $_[1],$_[0]) : $_[0]->{DescCode}       } 

sub max_coord_x     { (@_)>1 ? $_[0] : $maxx->{ $_[0]->{GridName} } }
sub max_coord_y     { (@_)>1 ? $_[0] : $maxy->{ $_[0]->{GridName} } }
sub max_coord_z     { (@_)>1 ? $_[0] : $maxz->{ $_[0]->{GridName} } }
                               
# ---------------------------------------------------------------------
sub set_up_grid {
    my $self  = shift;
    my $class = ref($self) || $self;
    my $pl = current_user();

    my $name = $self->name;

    # given the file-name of this room, determines grid-name and coordinates x,y,z.
    my $dir = basedirname($self->module);
    my ($b,$x,$y,$z);
    ($b,$x,$y,$z) = ($1,$2,$3,-1) if $name =~ m/^(.+)\_(\d+)\_(\d+)$/;
    ($b,$x,$y,$z) = ($1,$2,$3,$4) if $name =~ m/^(.+)\_(\d+)\_(\d+)\_(\d+)$/;
    $self->grid_name($b);
    $self->coord_x($x);
    $self->coord_y($y);
    $self->coord_z($z);

    # load just once per grid-name: load geographical definitions (
    # next virtual room will not reload the file since it is in ram.
    unless( exists $gridfile->{$b} && $gridfile->{$b} ) {       
        # reads the following configuration file
        my $localshortdescs = {} ;
        my $locallongdescs  = {} ;
        my $localproperties = {} ;
        my $localclones     = {} ;
        my $localcenters    = {} ;
        restore_config( $localshortdescs, $dir . '/' . $b . "_short.txt");
        restore_config( $locallongdescs,  $dir . '/' . $b . "_long.txt");
        restore_config( $localproperties, $dir . '/' . $b . "_prop.txt");
        restore_config( $localclones,     $dir . '/' . $b . "_clon.txt");
        restore_config( $localcenters,    $dir . '/' . $b . "_center.txt");
        while ( my ($key,$value) = each %{$localshortdescs} ) { $shortdescs->{"$b.$key"} = $value } 
        while ( my ($key,$value) = each %{$locallongdescs}  ) { $longdescs ->{"$b.$key"} = $value } 
        while ( my ($key,$value) = each %{$localproperties} ) { $properties->{"$b.$key"} = $value } 
        while ( my ($key,$value) = each %{$localclones}     ) { $clones    ->{"$b.$key"} = $value } 
        while ( my ($key,$value) = each %{$localcenters}    ) { $centers   ->{"$b.$key"} = $value } 
        $maxx->{$b} = 100; # default grid dimension
        $maxy->{$b} = 100;
        $maxz->{$b} = 1;
        
        $gridfile->{$b} = $dir . '/' . $b . "_grid.txt";
        $grid->{$b} = [] ;
        # the grid file is opened manually:
        #if ( open( GRID , clean_root($gridfile->{$b}) ) ) {
        if ( basedepth( $gridfile->{$b} ) > 0 ) { #&& open( GRID , clean_root($gridfile->{$b}) ) ) {
            my @buf = cat_array($gridfile->{$b});
            my $i = 0; #-1;
            my $layer = 0;
            #while ( my $line = <GRID> ) { 
            foreach my $line ( @buf ) { 
                $layer++ if $line =~ m/^#LAYER/;
                next if $line =~ m/^#/; # lines beginning with "#" are skipped
                $i++;
                $line =~ s/[\015\012]//; # wipe out cr-lf
                $grid->{$b}->[$i] = $line;
            }
            #close( GRID );        
            $grid->{$b}->[0] = '#';
            $layer = 1 if $layer < 1;
            $maxz->{$b} = $layer;
            $maxy->{$b} = int( $i / $layer );
            $maxx->{$b} = (length($grid->{$b}->[2])-2) / 2 ; # element in pos zero stores the width.
            log_file( "muddrv.log", "Grid $b loaded: ", $maxx->{$b}, "x", $maxy->{$b}, "x", $maxz->{$b} ) ;
        }
    }
    
    # builds standard exists and description.   
    my $bn = $dir . '/' . $b;
    my $desccode ;
    my %codes = ();
    my %neighbour = ();
    my %summary = ();
    my $descr;
    
    if( $z < 1 || $maxz->{$b} == 1 ) {
        $desccode = "$b." . substr($grid->{$b}->[$y], 2*$x - 1, 2) ;
    }
    else {
        my $layer = $maxy->{$b};
        $desccode = "$b." . substr($grid->{$b}->[$y+($layer*($z-1))], 2*$x - 1, 2) ;
        ###print $maxy->{$b} ," ", $maxz->{$b}, " ";
        ###print "layer:$layer el:", $y+($layer*($z-1)), "\n";
    }

    $self->desc_code( $desccode );
    $self->short( $shortdescs->{ $desccode } ) if exists( $shortdescs->{ $desccode } );
    
    # set-up properties for this room
    if ( ref($properties->{ $desccode }) eq 'ARRAY' ) {
        #while ( my ($key,$value) = each %{$properties} ) { $self->set_property( $key, $value ) ; }
        foreach my $pr ( @{$properties->{ $desccode }} ) { 
            if ( $pr =~ /=/ ) { $self->set_property( $`,$' ) }
            else { $self->set_property( $pr ) }
        }
    }
    else {
        log_file( "muddrv.log", "Wrong property in ${b}_prop($desccode)." );
    }
    
    # set-up clones for this room
    if ( ref($clones->{ $desccode }) eq 'ARRAY' ) {
        foreach my $clo ( @{$clones->{ $desccode }} ) { $self->add_object( $clo ) ; }
    }
    #else {
    #    log_file( "muddrv.log", "No clones in ${b}_prop($desccode)." );
    #}
    
    # initialize neighbour set-up
    my ($n,$s,$e,$w,$ne,$se,$nw,$sw,$u,$d);
    $n  = getsetup("Direction_n") ;
    $s  = getsetup("Direction_s") ;
    $e  = getsetup("Direction_e") ;
    $w  = getsetup("Direction_w") ;
    $ne = getsetup("Direction_ne") ;
    $se = getsetup("Direction_se") ;
    $nw = getsetup("Direction_nw") ;
    $sw = getsetup("Direction_sw") ;
    $u  = getsetup("Direction_u") ;
    $d  = getsetup("Direction_d") ;

    #tell_object( $pl, "\n($n,$s,$e,$w,$ne,$se,$nw,$sw,$u,$d)" );
    #tell_object( $pl, "\n coord: $x $y $z $b $desccode" );
    #tell_object( $pl, "\n ". ($y+1) .",". (2*$x-1) .",". substr($grid->{$b}->[$y+1], 2*$x    -1, 2) );

    foreach my $verb ($n,$s,$e,$w,$ne,$se,$nw,$sw,$u,$d) { 
        $codes{$verb} = '00' ;
        $neighbour{$verb} = '' ;
    }                                              
    # search neighbour unaccessible rooms for their short description, giving a summary.
    $codes{$n } = substr($grid->{$b}->[$y-1], 2*$x    -1, 2) if $y > 1                           && ! ( $self->query_property('no-north'));    
    $codes{$s } = substr($grid->{$b}->[$y+1], 2*$x    -1, 2) if $y < $maxy->{$b}                 && ! ( $self->query_property('no-south'));    
    $codes{$e } = substr($grid->{$b}->[$y],   2*($x+1)-1, 2) if $x < $maxx->{$b}                 && ! ( $self->query_property('no-east' ));    
    $codes{$w } = substr($grid->{$b}->[$y],   2*($x-1)-1, 2) if $x > 1                           && ! ( $self->query_property('no-west' ));    
    $codes{$ne} = substr($grid->{$b}->[$y-1], 2*($x+1)-1, 2) if $y > 1           && $x < $maxx->{$b} && $self->query_property('northeast');
    $codes{$se} = substr($grid->{$b}->[$y+1], 2*($x+1)-1, 2) if $y < $maxy->{$b} && $x < $maxx->{$b} && $self->query_property('southeast');
    $codes{$nw} = substr($grid->{$b}->[$y-1], 2*($x-1)-1, 2) if $y > 1           && $x > 1           && $self->query_property('northwest'); 
    $codes{$sw} = substr($grid->{$b}->[$y+1], 2*($x-1)-1, 2) if $y < $maxy->{$b} && $x > 1           && $self->query_property('southwest');
    #tell_object( $pl, "\ncodes: " );
    #while ( my ($key,$value) = each %codes ) { tell_object( $pl, "$key->$value " ) }
    #
    $neighbour{$n } = $shortdescs->{ "$b.".$codes{$n } } if exists $shortdescs->{ "$b.".$codes{$n } };
    $neighbour{$s } = $shortdescs->{ "$b.".$codes{$s } } if exists $shortdescs->{ "$b.".$codes{$s } };
    $neighbour{$e } = $shortdescs->{ "$b.".$codes{$e } } if exists $shortdescs->{ "$b.".$codes{$e } };
    $neighbour{$w } = $shortdescs->{ "$b.".$codes{$w } } if exists $shortdescs->{ "$b.".$codes{$w } };
    $neighbour{$ne} = $shortdescs->{ "$b.".$codes{$ne} } if exists $shortdescs->{ "$b.".$codes{$ne} };
    $neighbour{$se} = $shortdescs->{ "$b.".$codes{$se} } if exists $shortdescs->{ "$b.".$codes{$se} };
    $neighbour{$nw} = $shortdescs->{ "$b.".$codes{$nw} } if exists $shortdescs->{ "$b.".$codes{$nw} };
    $neighbour{$sw} = $shortdescs->{ "$b.".$codes{$sw} } if exists $shortdescs->{ "$b.".$codes{$sw} };
    #tell_object( $pl, "\nneighbour:" );
    #while ( my ($key,$value) = each %neighbour ) { tell_object( $pl, "$key->$value " ) if $value }
    #
    $summary{ $neighbour{$n }} .= ' ' .$n  if $codes{$n } =~ m/^0/ && $neighbour{$n } ne ''; 
    $summary{ $neighbour{$s }} .= ' ' .$s  if $codes{$s } =~ m/^0/ && $neighbour{$s } ne ''; 
    $summary{ $neighbour{$e }} .= ' ' .$e  if $codes{$e } =~ m/^0/ && $neighbour{$e } ne ''; 
    $summary{ $neighbour{$w }} .= ' ' .$w  if $codes{$w } =~ m/^0/ && $neighbour{$w } ne ''; 
    $summary{ $neighbour{$ne}} .= ' ' .$ne if $codes{$ne} =~ m/^0/ && $neighbour{$ne} ne ''; 
    $summary{ $neighbour{$se}} .= ' ' .$se if $codes{$se} =~ m/^0/ && $neighbour{$se} ne ''; 
    $summary{ $neighbour{$nw}} .= ' ' .$nw if $codes{$nw} =~ m/^0/ && $neighbour{$nw} ne ''; 
    $summary{ $neighbour{$sw}} .= ' ' .$sw if $codes{$sw} =~ m/^0/ && $neighbour{$sw} ne ''; 
    #tell_object( $pl, "\nsummary:" );
    #while ( my ($key,$value) = each %summary ) { tell_object( $pl, "$key->$value;" ) }
    #tell_object( $pl, "\n" );
    
    # then builds up long description using all the above.
    $descr = $shortdescs->{ $desccode } if ( exists( $shortdescs->{ $desccode } ) ); # default
    $descr = $longdescs->{ $desccode } if ( exists( $longdescs->{ $desccode } ) );
    my @dirs = keys( %summary );
    for my $i ( 0 .. $#dirs ) {
       #$descr .= "\nNelle vicinanze:" unless $i; # when i = 0
       $descr .= parse_std_msg('Neighbour') unless $i; # when i = 0
       $descr .= "; " if $i ; # when i > 0
       $descr .= $summary{$dirs[$i]} . ", " . $dirs[$i]; # accumulate dirs.
    }

    $self->desc( $descr );
    
    # append obvious exits. Codes beginning with 0 are unaccessible.
    $self->add_exit( $n , $bn . '_' .  $x    . '_' . ($y-1) ) if $codes{$n } !~ m/^0/ ;
    $self->add_exit( $s , $bn . '_' .  $x    . '_' . ($y+1) ) if $codes{$s } !~ m/^0/ ;
    $self->add_exit( $e , $bn . '_' . ($x+1) . '_' .  $y    ) if $codes{$e } !~ m/^0/ ;
    $self->add_exit( $w , $bn . '_' . ($x-1) . '_' .  $y    ) if $codes{$w } !~ m/^0/ ;
    $self->add_exit( $ne, $bn . '_' . ($x+1) . '_' . ($y-1) ) if $codes{$ne} !~ m/^0/ ;
    $self->add_exit( $se, $bn . '_' . ($x+1) . '_' . ($y+1) ) if $codes{$se} !~ m/^0/ ;
    $self->add_exit( $nw, $bn . '_' . ($x-1) . '_' . ($y-1) ) if $codes{$nw} !~ m/^0/ ;
    $self->add_exit( $sw, $bn . '_' . ($x-1) . '_' . ($y+1) ) if $codes{$sw} !~ m/^0/ ;

    unless( $z < 1 || $maxz->{$b} == 1 ) {
        $self->add_exit($u ,   $bn . '_' .  $x    . '_' .  $y   . '_' . ($z+1) ) if $z < $maxz->{$b};
        $self->add_exit($d ,   $bn . '_' .  $x    . '_' .  $y   . '_' . ($z-1) ) if $z > 1;
    }
       
    # In any virtual room a wizard can reload all the grid definitions & descriptions.
    $self->add_action( 'reload','reload' ); 
    if ( ref($pl) && $pl->isa('User') && $pl->wizardhood ) {   
        #tell_object( $pl, "gridfile: $gridfile->{$b}\n" ) if $gridfile->{$b};
        #tell_object( $pl, "dim: $maxx->{$b} $maxy->{$b} $maxz->{$b}\n" ) if $gridfile->{$b};
        #tell_object( $pl, $grid->{$b}->[$y], "\n" ) if $gridfile->{$b};
        tell_object( $pl, "desccode $desccode : ") ;
        while ( my ($key,$value) = each %summary ) { 
            tell_object( $pl, "$value->$key " ) ;
        }
        #tell_object( $pl, "shortdesc: ", %$shortdescs, "\n" );
        #tell_object( $pl, "desc: ", $shortdescs->{ $desccode } ) if exists( $shortdescs->{ $desccode } );
        #tell_object( $pl, "DESC: ", $longdescs->{ $desccode } ) if exists( $longdescs->{ $desccode } );
    }

    return $self;
}

# ---------------------------------------------------------------------
sub examine_object {
    my $room    = shift;
    my $class   = ref($room) || $room;
    ###print "(VirtualRoom): $class";
    ###print "\n";
    my ($room_desc,$dummya,$dummyb) = $room->SUPER::examine_object; 
    #$room_desc = daemon('room_desc_dir')->do_look_room( $room );
    return ($room_desc,0,0);

    #if ( $pl->query_property('known_grid_' . $this->grid_name) ) {
    #    my $msg ;
    #    $msg = "Coordinate geografiche: " . $room->coord_x() . "," . $room->coord_y() . "\n";
    #    $room_desc = $msg . $room_desc;
    #}
}

# ---------------------------------------------------------------------
# reload the virtual grid definition.
# Usable by a wizard in any room of the grid: updates the grid but doesn't reload any room.
sub reload { 
    my $this   = shift;
    my $verb   = shift;
    my $what   = shift;
    my $pl     = current_user();
    #tell_object ( $pl, "Passed: $this - $verb \n" );
    #tell_object ( $pl,  $pl->inputline, "\n" );
    my $b = '';
    my $c = $this->desc_code() || '00';
    $b = $1 if $c =~ m/^(.+)\./ ;
    if ( ref($pl) && $pl->isa('User') && $pl->wizardhood ) {
        if ( $b ) {
            delete $gridfile->{$b} ;
            tell_object ( $pl, "Virtual Grid Reloaded.\n" );
            }
        else {
            tell_object ( $pl, "Cannot reload Virtual Grid from here.\n" );
        }
        return 1;
    }
    return 0;
}

# ---------------------------------------------------------------------
sub desc {
    my $this  = shift;
    my $class = ref($this) || $this;
    return $this->SUPER::desc( @_ ) if scalar @_ > 0;
    my $descr = $this->SUPER::desc( @_ );

    my $pl    = current_user();

    if ( ref($pl) && $pl->isa('User') && $pl->custom('HasCompass') ) {
        my $x = $this->coord_x();
        my $y = $this->coord_y();
        my $z = $this->coord_z();
        my ($n,$s,$e,$w);
        $n  = getsetup("Direction_n") ;
        $s  = getsetup("Direction_s") ;
        $e  = getsetup("Direction_e") ;
        $w  = getsetup("Direction_w") ;
    
        # gives you some informations about the nearest town.
        my $distq = 999999999;
        my $sq = 0;
        my $dx = 0;
        my $dy = 0;
        my $city = '';
        my $citydx = 0;
        my $citydy = 0;
        my $b = '';
        my $c = $this->desc_code() || '00';
        $b = $1 if $c =~ m/^(.+)\./ ;
        for my $cn ( keys %$centers ) {
            next unless $cn =~ m/^$b\./;
            $dx = $centers->{$cn}->[1] - $x;
            $dy = $centers->{$cn}->[2] - $y;
            $sq = $dx * $dx + $dy * $dy;
            if ( $sq >= 4 && $sq < $distq ) {
                $distq = $sq;
                $city = $centers->{$cn}->[0];
                $citydx = $dx;
                $citydy = $dy;
            }
        }
    
        if ( $distq >= 4 && $city ) { # se hai il sestante...
            my $dist = int(0.5+sqrt($distq));
            my $ndx = 2.0*$citydx/$dist;
            my $ndy = 2.0*$citydy/$dist;
            my $dir = '';
            $dir .= $n if $ndy < -1;
            $dir .= $s if $ndy > +1;
            $dir .= $w if $ndx < -1;
            $dir .= $e if $ndx > +1;
            my $fuzzy = std_msg('some');
            $fuzzy = std_msg('few') if ($dist < 4);
            $fuzzy = std_msg('many') if ($dist > 8);
            $descr .= " ";
            $descr .= parse_std_msg('NearestCity',
                      $city, $fuzzy, $dir ) ;
        }
    }
        
    return $descr
}
   
# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->set_up_grid();

    return $self;
}

1;
