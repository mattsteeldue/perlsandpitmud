use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Terrazza - ovest') 
         ->desc( "Questo è l'ultimo livello della torre sull'arco " .
                 "Nordovest.\n" ) 
    
         ->add_exit('nordest',  './attico_n1') 
         ->add_exit('sudovest', './attico_w3') 

         ->add_wandering_area( 'bird' ) 

         ->set_property('outdoor')  
         ;
    
    return $self;
}
