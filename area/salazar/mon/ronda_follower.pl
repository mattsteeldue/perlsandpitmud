# ronda.pl
# Created Feb 2009
# Author  flogisto

use Mobile;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->add_id('ronda_follower') 
         ->add_id('guardia') 
         ->short('guardia di ronda') 
         ->shorts('guardie di ronda') 
         ->desc( "Si tratta del soldato di ronda per la città. "
                ."Indossa la divisa d'ordinanza e porta la spada al fianco.") 
         ->set_property('unique')  
         
         ->set_stats(10)  
         
         ->add_reply( 'ciao','La guardia dice: "Ciao"' ) 
         
         ->following( 'ronda_leader' );
         ;
         
    return $self;
}

