# room_desc_daemon.pl
# Created Jan 2008
# Author  flogisto

# ---------------------------------------------------------------------
use Daemon;

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( 'room_desc_daemon' );
    bless $self, $class ;
    
    my $dbh = dbi();
    my $sth = $dbh->table_info( undef, undef, 'engine_room_annotation' );
    if ( ! $dbh->err && ! $sth->fetch() ) {
        $dbh->do( qq[ 
            create table engine_room_annotation (
            room_name  char(256),
            level      integer,
            username   char(64),
            datetime   real,
            annotation char(1024) )
                    ] );
    }
    return $self;
}

# ---------------------------------------------------------------------
sub get_annotation {
    my $me      = shift;
    my $room    = shift || return ''; # basename($pl->environment->module);
    my $msg = '';
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ select * from engine_room_annotation where room_name=? ]) ;
    $sth->execute( $room );
    while ( my $row = $sth->fetchrow_hashref() ) {
        $msg .= "<"
             . $row->{username} . " "
             . "> " 
             . $row->{annotation}
             . "\n" ;
    }
    $sth->finish();
    return substr($msg,0,1024);
}

# ---------------------------------------------------------------------
sub get_total_annotation {
    my $me      = shift;
    my $room    = shift || return ''; # basename($pl->environment->module);
    my $msg = '';
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ select * from engine_room_annotation where room_name=? ]) ;
    $sth->execute( $room );
    while ( my $row = $sth->fetchrow_hashref() ) {
        $msg .= "<"
             . $row->{level} . " "
             . $row->{username} . " "
             . $row->{datetime} 
             . "> " 
             . $row->{annotation}
             . "\n" ;
    }
    $sth->finish();
    return $msg;
}

# ---------------------------------------------------------------------
sub add_annotation {
    my $me     = shift;
    my $room   = shift; # basename($pl->environment->module);
    my $what   = "@_";
    my $pl     = current_user();
    my $dt     = time_to_str( time(), 'YYMMDD.HHMISS' );
    my $msg = '';

    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ insert into engine_room_annotation values ( ?, ?, ?, ?, ? ) ] );
    $sth->execute( $room, 
        $pl->level, 
        $pl->cap_name, 
        $dt, 
        $what );
    $sth->finish();    
    return 1;
}

# ---------------------------------------------------------------------
sub delete_annotation {
    my $me      = shift;
    my $room    = shift; # basename($pl->environment->module);
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ delete from engine_room_annotation where room_name=?] );
    $sth->execute( $room ); 
    $sth->finish();
}

# This is called from within Room::examine_object to get the description of the room.
# ---------------------------------------------------------------------
sub do_look_room {
    my $me      = shift;
    my $room    = shift;
    my $class   = ref($room) || $room;
    my $pl      = current_user();
    my $this    = driver;
    my $dirs    = { };
    my $room_desc;
    my $temp_desc;
    my $i;
    my $object;
    my @stddir  = @{getsetup('Directions')};
    
    foreach my $verb ( @stddir ) { 
        $dirs->{$verb} = getsetup("Direction_$verb"); 
    }
    
    $room_desc .=  '<' . $room->module . '>' . "\n" if ref($pl) && $pl->isa('User') && $pl->wizardhood(); 
    $room_desc .=  ' - ' . getcolor('ShortRoom') . $room->short . ansi_clear() . ' - ' . "\n" if ($pl->brief() & 3) == 3; 
    $room_desc .=  $room->short . "\n"  if ($pl->brief() & 3) == 2; 

    # map of exits.
    my @layout = (
    '. . . . . ',
    '.       . ',
    '.   o   . ',
    '.       . ',
    '. . . . . ',
    );
    
    my @arrow = ( qw( H H H H ) ) ;
    @arrow = @{ getsetup('DescRoomShapeArrow') } if getsetup('DescRoomShapeArrow');
    substr($layout[2],2,2) = '--'      if exists $room->obvious_exits->{$dirs->{w} }; #ovest    } ; 
    substr($layout[2],5,2) = '--'      if exists $room->obvious_exits->{$dirs->{e} }; #est      } ; 
    substr($layout[1],4,1) = '|'       if exists $room->obvious_exits->{$dirs->{n} }; #nord     } ; 
    substr($layout[1],3,1) = '\\'      if exists $room->obvious_exits->{$dirs->{nw}}; #nordovest} ; 
    substr($layout[1],5,1) = '/'       if exists $room->obvious_exits->{$dirs->{ne}}; #nordest  } ; 
    substr($layout[3],4,1) = '|'       if exists $room->obvious_exits->{$dirs->{s} }; #sud      } ; 
    substr($layout[3],3,1) = '/'       if exists $room->obvious_exits->{$dirs->{sw}}; #sudovest } ; 
    substr($layout[3],5,1) = '\\'      if exists $room->obvious_exits->{$dirs->{se}}; #sudest   } ; 
    substr($layout[0],1,1) = $arrow[0] if exists $room->obvious_exits->{$dirs->{u} }; #up       } ; 
    substr($layout[1],1,1) = $arrow[1] if exists $room->obvious_exits->{$dirs->{u} }; #up       } ; 
    substr($layout[3],1,1) = $arrow[2] if exists $room->obvious_exits->{$dirs->{d} }; #down     } ; 
    substr($layout[4],1,1) = $arrow[3] if exists $room->obvious_exits->{$dirs->{d} }; #down     } ; 

    # affect enviroment.
    map $_ =~ s/\./\^/g, @layout if $room->query_property('forest');
    #map $_ =~ s/\./\_/g, @layout if $room->query_property('indoor');
    #substr($layout[2],4,1) = '.' if $room->query_property('outdoor');
    map $_ = "{GREEN}${_}{RESET}", @layout if $room->query_property('forest');
    map $_ = parse_color($_), @layout;
    
    # long desc
    #$room_desc .=  $room->desc . " \n"  if $pl->brief() & 1;
    if ( $pl->brief() & 1 ) {
        
        #my @ary = split( /\n/, $room->desc ); 
        #map $_ =~ s/[\012\015]$//g, @ary;
        my @lines = wrap_at( $pl->wrap_col - 10, 
            parse_color( $room->light > 0 ? $room->desc : std_msg('Actions_it_is_dark' ) ) );
        
        pop @lines unless $lines[$#lines];
        for( $i = 0; $i <= $#lines || $i <= $#layout; $i++ ) {
            $room_desc .=  ($i <= $#layout ? $layout[$i] : ' ' x 10 );
            # getcolor('LongRoom') . ansi_clear()
            $room_desc .=  ($i <= $#lines  ? $lines[$i]  : ' ' x 1);
            $room_desc .= " \n" if $i <= max($#lines,$#layout);
        }
    }

    #
    # display obvious exits.
    #
    my @exits  = sort keys %{$room->obvious_exits};
    $temp_desc = '';
    $temp_desc .= parse_std_msg('Actions_Look_no_exits') . "\n" unless @exits;
    $temp_desc .= (1 == @exits ? 
                    parse_std_msg('Actions_Look_one_exit') :
                    parse_std_msg('Actions_Look_more_exits') ) if @exits;
    my %srid = reverse %{$dirs};
    for( $i = 0; $i < @exits; $i++ ) {
        if ( exists $srid{$exits[$i]} ) {
            my $c = substr($exits[$i],0,1);
            my $flag1 = -1 != pos_array( @stddir, $c ) ;
            my $flag2 = $exits[$i] eq getsetup("Direction_$c") ;
            $temp_desc .= parse_color('{B}') if $flag1 and $flag2;
            $temp_desc .= substr($exits[$i],0,1) ;
            $temp_desc .= parse_color('{/B}') if $flag1 and $flag2;
            $temp_desc .= substr($exits[$i],1) ;
        }
        else {
            $temp_desc .= $exits[$i];
        }
        $temp_desc .=  ", " if $i < @exits - 2;
        $temp_desc .=  " " . std_msg('And') . " " if $i == @exits - 2;
    }
    $temp_desc .= ".\n" if @exits;
    $room_desc .= join( "\n", wrap_at( $pl->wrap_col, $temp_desc ) );
    
    #
    # collect users, objects, monsters
    my @invent = @{$room->inventory} ;
    remove_from_array( \@invent, $pl );

    my @people = ();
    my @items  = ();
    my $items  = {};
    my @monst  = ();
    my $monst  = {};

    foreach $object ( @invent ) {
        next if not $object->visible;
        if( $object->isa('User') ) {
            push (@people, $object);
        }
        elsif ( $object->isa('Living') ) {
            if ( exists $monst->{ $object->name } ) {
                $monst->{ $object->name } += 1 ;
            }
            else {
                push (@monst, $object);
                $monst->{ $object->name } = 1;
            }
        }
        else { # Object.
            if ( exists $items->{ $object->name } ) {
                $items->{ $object->name } += 1 ;
            }
            else {
                push (@items, $object);
                $items->{ $object->name } = 1;
            }
        }
        
    }

    # items
    $temp_desc = '';
    $temp_desc .= parse_std_msg('Actions_Look_obj_pres') if @items;
    for( $i = 0; $i < @items; $i++ ) {
        $object = $items[$i];
        if ( $items->{ $object->name } == 1 ) {
            $temp_desc .= $object->short() ;
        }
        else {
            $temp_desc .= number_in_letter($items->{ $object->name }) . " " . $object->shorts() ;
        }
        $temp_desc .=  ", " if $i < @items - 2;
        $temp_desc .=  " " . std_msg('And') . " " if $i == @items - 2;
    }
    $temp_desc .= ".\n" if @items;
    $room_desc .= join( "\n", wrap_at( $pl->wrap_col, $temp_desc ) );

    # monsters
    $temp_desc = '';
    $temp_desc .= parse_std_msg('Actions_Look_mon_pres') if @monst;
    for( $i = 0; $i < @monst; $i++ ) {
        $object = $monst[$i];
        if( $monst->{ $object->name } == 1 ) {
            $temp_desc .= $object->short();
        }
        else {
            $temp_desc .= number_in_letter($monst->{ $object->name }) . " " . $object->shorts() ;
        }
        $temp_desc .=  ", "    if $i < @monst - 2;
        $temp_desc .=  " " . std_msg('And') . " " if $i == @monst - 2;
    }
    $temp_desc .= ".\n" if @monst;
    $room_desc .= join( "\n", wrap_at( $pl->wrap_col, $temp_desc ) );

    # users    
    $temp_desc = '';
    for( $i = 0; $i < @people; $i++ ) {
        $object = $people[$i];
        if ( $object->ghost() ) {
            $temp_desc .= parse_std_msg('TheGhostOf',$object->cap_name );
        }
        else {
            $temp_desc .= parse_string( '{B}' . $object->cap_name() .'{/B}') ;
        }
        $temp_desc .=  ", "    if $i < @people - 2;
        $temp_desc .=  " " . std_msg('And') . " " if $i == @people - 2;
    }
    $temp_desc .= ( @people==1 ? " " . std_msg('Is') 
                               : " " . std_msg('Are') ) 
               . " " . std_msg('Here') . "." . "\n" if @people;
    $room_desc .= join( "\n", wrap_at( $pl->wrap_col, $temp_desc ) );

    # annotations
    $temp_desc = '';
    if ($pl->brief() & 4) {
        my $annot = $me->get_annotation( basename( $room->module ) );
        if ( $annot ) {
            $temp_desc .= getcolor('Annotation') . "Annotazioni:\n";
            $temp_desc .= $annot;
        }
    }
    $room_desc .= join( "\n", wrap_at( $pl->wrap_col, $temp_desc ) );

    #write_client("##\n");
    #write_client($room_desc);
    #write_client("##\n");
    
    return $room_desc;
}
