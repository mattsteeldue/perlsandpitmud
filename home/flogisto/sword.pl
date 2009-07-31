# sword.pl
# Created Jan 2008
# Author  flogisto

use Weapon;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( ); 
    bless $self, $class;

    $self->weapon_class( 1 );

    $self->name('spada');
    $self->short('spada');
    $self->shorts('spade');
    $self->desc( "Spada." );
    return $self;
}

