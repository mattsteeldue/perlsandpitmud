# child.pl
# Created Jun 2007
# Author  flogisto

use Mobile;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->name('bambino') 
         ->short('bambino') 
         ->shorts('bambini') 
         ->desc( "Un bambino che corre e gioca."
               ) 
         ->add_id('bambino') 
         
         ->hit_points(10) 
         
         ->add_reply( 'bambino',"Il bambino risponde: 'Bambino a chi?'" ) 
         
         ->chat_prob( 01 )  # %-probability
         ->add_chat( 'Il bambino urla: "All\'attacco!"' )  
         ->add_chat( 'Il bambino urla: "Scappiamo!"' )  
         ->add_chat( 'Il bambino ti guarda, sorride e scappa.' )  
         ->add_chat( 'Il bambino ti fa le boccacce.' )  
         ->add_chat( 'Il bambino ti guarda impaurito.' )  
         
         ->wandering_prob( 15 )  # %-probability
         ->add_wandering_area( 'salazar' )  # areas
   #     ->trail_path( [ 'basso','alto','basso','alto' ] ) 
   #     ->trail_delay( 60 ) 
         ;

    return $self;
}
