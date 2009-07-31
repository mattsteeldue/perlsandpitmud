# sextant.pl
# Created Jan 2008
# Author  flogisto

use Object;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( 'sestante' ); 
    bless $self, $class;

    $self->name('sestante');
    $self->short('sestante');
    $self->shorts('sestanti');
    $self->desc( "Questo è un sestante, consente di fare il " .
                 "{B}punto{/B} in qualunque parte del Mondo Emerso ti trovi." );
    
    $self->add_action( 'punto','do_punto' );
    
    $self->set_property('permanent');
    
    return $self;
}

# ---------------------------------------------------------------------
sub do_punto { 
    my $this   = shift;
    my $verb   = shift; # panorama
    my $what   = shift;
    my $pl     = $this->environment();
        
    if (ref($pl)) { 
        my $room = $pl->environment();
        if ( ref($room) && $room->isa('VirtualRoom') ) {
            my $x = $room->coord_x() - $room->max_coord_x()/2;
            my $y = $room->coord_y() - $room->max_coord_y()/2;
            my $dirx = ($x>0 ? 'est' : 'ovest' );
            my $diry = ($y>0 ? 'sud' : 'nord' );
            $x = int( $x/2 );
            $y = int( $y/2 );
            $x = 1-$x if $x < 1;
            $y = 1-$y if $y < 1;
            tell_object( $pl, "Leggi sul sestante: $x $dirx, $y $diry.\n" );
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
