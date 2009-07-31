# guard.pl
# Created Jan 2009
# Author  flogisto

use Mobile;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->add_id('guardia') 
         ->short('guardia della porta') 
         ->desc( "Si tratta del soldato di guardia alla porta. "
                ."Indossa la divisa d'ordinanza e porta la spada al fianco.") 
         
         ->set_property('unique')  
         
         ->set_stats(10)  
         
         ->add_reply( 'buongiorno','La guardia dice: "Buongiorno"' ) 
         
   #     ->wandering_prob( 05 )  # %-probability
   #     ->add_wandering_area( 'orto' )  # areas
         
         ->chat_prob( 5 )  # %-probability
         ->add_chat( 'La guardia dice: "Non è prudente avventurarsi fuori di notte."', 19..24, 0..5 )  
         ->add_chat( 'La guardia dice: "Non è prudente girare per Salazar di notte."', 19..24, 0..5 )  
         ->add_chat( 'La guardia dice: "Mi raccomando, niente risse qui attorno."', 19 .. 24 )  
         ->add_chat( 'La guardia dice: "Prendi il sestante per orientarti nel Mondo Emerso."', 6 .. 18 )  
         ->add_chat( 'La guardia dice: "Attento a chi incontri nella foresta."' )  
         ->add_chat( 'La guardia dice: "Che fame."', 12,13 )  
         
   #     ->trail_path( [ 'basso','alto','basso','alto' ] ) 
   #     ->trail_delay( 60 ) 
         ;

    return $self;
}
