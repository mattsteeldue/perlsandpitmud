use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello inferiore') 
         ->desc( "Questo è il livello basso della torre sull'arco " .
                 "Sud. " .
                 "Una rampa sale al livello superiore verso nordest. " . 
                 "In cima alla rampa si trova l'infermeria di Salazar.".
                 "\n") 
    
         ->add_exit('ovest',   './bassi_s2') 
         ->add_exit('nordest', './bassi_e4') 

         ->add_exit('alto',  './medi_e4') 

           
         ;
    return $self;
}

1;
