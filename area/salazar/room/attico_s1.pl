use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Attico') 
         ->desc( "Questo è l'ultimo livello della torre sull'arco " .
                 "Sud. " .
                 "Si tratta di una zona di passeggiata molto piacevole. " .
                 "Una rampa scende al livello inferiore verso nordest. " . 
                 "\n") 
    
         ->add_exit('ovest',   './attico_s2') 
         ->add_exit('nordest', './attico_e4') 
    
         ->add_exit('basso', './alti_e4') 

         ->add_wandering_area( 'bird' ) 
    
         ->set_property('outdoor')  
         ;

    return $self;
}
