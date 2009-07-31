# pugnale.pl
# Created May 2007
# Author  flogisto

use Weapon;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new;
    bless $self, $class;

    $self->add_id(['spada','spade']) 
         ->short('spada di legno') 
         ->shorts('spade di legno') 
         
         ->desc( 'Questa è una spada di legno usata dai bambini per giocare alla battaglia.') 
         
         ->set_property('wood') 
         ->value( 20 ) 
         ;
    return $self;
}

1;
