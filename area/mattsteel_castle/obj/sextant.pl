# sextant.pl
# Created Jan 2008
# Author  flogisto

use Object;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( 'sestante' ); 
    bless $self, $class;

    $self->name('sestante') 
         ->short('sestante') 
         ->shorts('sestanti') 
         ->desc( "Questo è un sestante, consente di fare il " .
                 "{B}punto{/B} in qualunque parte del Mondo Emerso ti trovi." ) 
         
         ->add_action( 'punto','do_punto' ) 
         
         ->set_property('permanent') 
         ;
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
        if ( ref($room) && $room->isa('VirtualRoom') && $room->grid_name() eq 'em' ) {
            my $x = $room->coord_x() - $room->max_coord_x()/2;
            my $y = $room->coord_y() - $room->max_coord_y()/2;
            my $dirx = ($x>0 ? getsetup('Direction_e') : getsetup('Direction_w') );
            my $diry = ($y>0 ? getsetup('Direction_s') : getsetup('Direction_n') );
            $x = int( $x/2 );
            $y = int( $y/2 );
            $x = 1-$x if $x < 1;
            $y = 1-$y if $y < 1;
            tell_object( $pl, "Leggi sul sestante: $x $dirx, $y $diry.\n" );
            return 1;
        }
        else {
            tell_object( $pl, "Il sestante non funziona bene qui.\n" .
                              "Probabilmente dovresti usarlo quanto ti trovi in viaggio sul territorio del Mondo Emerso.\n" );
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
    if ( ref($pl) && $pl->isa('User') ) {
        $pl->set_property('CustomHasCompass',1,driver()->time_between() + 10 ) ;
    }
}

# ---------------------------------------------------------------------
sub done { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $pl      = shift;
    if ( ref($pl) && $pl->isa('User') ) {
        $pl->set_property('CustomHasCompass',0 ) ;
    }
}

# ---------------------------------------------------------------------
sub heart_beat  { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $tt      = shift || time();
    $this->SUPER::heart_beat($tt);
    
    $pl = $this->environment();
    if ( ref($pl) && $pl->isa('User') ) {
        $pl->set_property('CustomHasCompass',1,driver()->time_between() + 10 ) ;
    }
}
