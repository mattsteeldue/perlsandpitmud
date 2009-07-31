use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello inferiore') 
         ->desc( "Questo è il livello basso della torre sull'arco " .
                 "Est. " .
                 "Una rampa sale al livello superiore verso nordovest. " . 
                 "In cima alla rampa si trova il tempio.".
                 "\n") 
    
         ->add_exit('nordovest', './bassi_n4') 
         ->add_exit('sud',       './bassi_e2') 

         ->add_exit('alto',  './medi_n4') 
        
           
         ;
    return $self;
}

1;
