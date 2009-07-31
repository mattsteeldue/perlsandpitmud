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
         ->add_id('guard') 
         ->short('patrol officier') 
         ->shorts('patrol officiers') 
         ->desc( "He is the officier who leads the Castel patrol. "
                ."He wear a reculation uniform and a sword.") 
         
         ->set_property('unique')  
         
         ->set_stats(10)  
         
         ->add_reply( 'hello','Guard says: "Hello"' ) 
         
         ->wandering_prob( 5 )  # %-probability
         ->add_wandering_area( 'dummy_castle' )
         ->follower( ['ronda_follower'] )
           # areas
         
         ->chat_prob( 5 )  # %-probability
         ->add_chat( 'Guard says: "I warn you, brawl are not allowed here."' )  
         ->add_chat( 'Guard says: "It is not wise venture outside in the night"', 19..24, 0..5 )  

         ;

    return $self;
}

