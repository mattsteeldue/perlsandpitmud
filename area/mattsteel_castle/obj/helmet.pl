# helmet.pl
# Created Nov 2006
# Author  flogisto

use Helmet;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new;
    bless $self, $class;

    $self->short('elmetto') 
         ->shorts('elmetti') 
         ->desc( 'Un semplice elmetto.') 
         
         ->set_property('unique') 
         ->add_id('elmetto') 
         ->value( 100 ) 
         ;

    return $self;
}

1;
