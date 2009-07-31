# ronda.pl
# Created Feb 2009
# Author  flogisto

use Mobile;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->add_id('ronda_leader') 
         ->add_id('guardia') 
         ->short('ufficiale di ronda') 
         ->shorts('ufficiali di ronda') 
         ->desc( "Si tratta del sottufficiale di ronda per il castello. "
                ."Indossa la divisa d'ordinanza e porta la spada al fianco.") 
         
         ->set_property('unique')  
         
         ->set_stats(10)  
         
         ->add_reply( 'buongiorno','La guardia dice: "Buongiorno"' ) 
         
         ->wandering_prob( 5 )  # %-probability
         ->add_wandering_area( 'mattsteel_castle' )
         ->follower( ['ronda_follower'] )
           # areas
         
         ->chat_prob( 5 )  # %-probability
         ->add_chat( 'La guardia dice: "Mi raccomando, niente risse qui attorno."' )  

         ;

    return $self;
}

