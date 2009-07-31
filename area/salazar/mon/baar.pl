# baar.pl
# Created Jan 2007
# Author  flogisto

use Mobile;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->add_id('baar') 
         ->short('il vecchio Baar') 
         ->desc( "Questo vecchio è l'ortolano di Salazar. "
                ."Scontroso e burbero, si aggira sempre fra le piante del suo bell'orto.") 
         
         ->set_property('unique') 
         
         ->hit_points(10) 
         
         ->add_reply( 'ciao',"Bard risponde: 'buongiorno a te!'" ) 
         ->add_reply( 'buongiorno',"Bard risponde: 'buongiorno a te!'" ) 
         
         ->wandering_prob( 05 )  # %-probability
         ->add_wandering_area( 'orto' )  # areas
         
         ->chat_prob( 05 )  # %-probability
         ->add_chat( 'Baar dice: "Monellacci!"' )  
         ->add_chat( 'Baar dice tra sè: "Eh! Eh! ...poi faremo i conti..."' )  
         
   #     ->trail_path( [ 'basso','alto','basso','alto' ] ) 
   #     ->trail_delay( 60 ) 
         ;
    return $self;
}
