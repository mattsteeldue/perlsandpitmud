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
         ->add_id('guard') 
         ->short('patrol guard') 
         ->shorts('patrol guards') 
         ->desc( "He is a guard of the Castel patrol. "
                ."He wear a reculation uniform and a sword.") 
         ->set_property('unique')  
         
         ->set_stats(10)  
         
         ->add_reply( 'hello','Guard says "Hello"' ) 
         ->add_chat( 'Guard says : "I\'m hungry."', 12,13 );  
         
         ->following( 'ronda_leader' );
         ;
         
    return $self;
}

