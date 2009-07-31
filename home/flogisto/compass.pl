# sextant.pl
# Created Jan 2008
# Author  flogisto

use Object;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( 'bussola' ); 
    bless $self, $class;

    $self->name('bussola');
    $self->short('bussola');
    $self->shorts('bussole');
    $self->desc( "Una bussola." );
    
    $self->add_action( 'punto','do_punto' );
    
    return $self;
}

# ---------------------------------------------------------------------
sub do_punto { 
    my $this   = shift;
    my $verb   = shift; # panorama
    my $what   = shift;
    my $pl     = $this->environment();
    my $fmt = <<'END';
 Grid: @<<<<<<<<<<  Coord:  @>>> @>>> @>>>
 Code: @<<<<<<<<<<  Square: @>>> @>>> @>>>  (+@ +@)
END
    
    if (ref($pl)) { 
        my $room = $pl->environment();
        if ( ref($room) && $room->isa('VirtualRoom') ) {

            $^A = "";
            formline( $fmt, 
                $room->grid_name(), 
                $room->coord_x(), $room->coord_y(), $room->coord_z(),
                $room->desc_code(), 
                int((3+$room->coord_x())/4), int((3+$room->coord_y())/4), int((3+$room->coord_z())/4),
                int((3+$room->coord_x())%4), int((3+$room->coord_y())%4)
                );
                
            while ( my ($key,$value) = each %{ $room->properties } ) { 
                formline( '  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n',
                "$key = $value" );
            }    

            tell_object( $pl, $^A );
            return 1;
        }
    }
    
    return 0;
}

# ---------------------------------------------------------------------
sub init { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $pl      = shift;
    $pl->custom('HasCompass',1) if ref($pl) && $pl->isa('User');
}

# ---------------------------------------------------------------------
sub done { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $pl      = shift;
    $pl->custom('HasCompass',0) if ref($pl) && $pl->isa('User');
}
