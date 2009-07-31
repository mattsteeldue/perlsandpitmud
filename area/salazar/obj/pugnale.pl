# pugnale.pl
# Created May 2007
# Author  flogisto

use Weapon;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new;
    bless $self, $class;

    $self->short('pugnale') 
         ->shorts('pugnali') 
         ->desc( 'Un pugnale da ladro.') 
         ->value( 100 ) 
         
         ->set_property('metal') 
         ;

    return $self;
}

1;
