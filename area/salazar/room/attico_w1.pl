use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Attico') 
         ->desc( "Questo è l'ultimo livello della torre sull'arco " .
                 "Ovest. " .
                 "Si tratta di una zona di passeggiata molto piacevole. " .
                 "Una rampa scende al livello inferiore verso sudest. " . 
                 "\n") 
    
         ->add_exit('nord',   './attico_w2') 
         ->add_exit('sudest', './attico_s4') 

         ->add_exit('basso', './alti_s4') 

         ->add_wandering_area( 'bird' ) 

         ->set_property('outdoor')  
         ;

    return $self;
}
