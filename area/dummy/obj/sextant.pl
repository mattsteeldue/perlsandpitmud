# sextant.pl
# Created Jan 2008
# Author  flogisto

use Object;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( 'sestante' ); 
    bless $self, $class;

    $self->name('sextant') 
         ->short('a sextant') 
         ->shorts('sextants') 
         ->desc( "This is a sextant. It allows you to find your  " .
                 "{B}point{/B} in any place you will be." ) 
         
         ->add_action( 'point','do_punto' ) 
         
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
        if ( ref($room) && $room->isa('VirtualRoom') ) {
            my $x = $room->coord_x() - $room->max_coord_x()/2;
            my $y = $room->coord_y() - $room->max_coord_y()/2;
            my $dirx = ($x>0 ? getsetup('Direction_e') : getsetup('Direction_w') );
            my $diry = ($y>0 ? getsetup('Direction_s') : getsetup('Direction_n') );
            $x = int( $x/2 );
            $y = int( $y/2 );
            $x = 1-$x if $x < 1;
            $y = 1-$y if $y < 1;
            tell_object( $pl, "You read the sexstant: $x $dirx, $y $diry.\n" );
            return 1;
        }
        else {
            tell_object( $pl, "The sextant works when you travel in lands.\n" );
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
