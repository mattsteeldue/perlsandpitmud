use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello mediano - ovest') 
         ->desc( "Questo è il livello mediano della torre sull'arco " .
                 "Ovest. " .
                 "Una rampa sale al livello superiore verso sudovest e " . 
                 "una scende al livello inferiore verso nordest. " . 
                 "\n") 
    
         ->add_exit('nordest',  './medi_n1') 
         ->add_exit('sudovest', './medi_w3') 

         ->add_exit('alto',  './alti_w3') 
         ->add_exit('basso', './bassi_n1') 

         
         ; 
         
    return $self;
}

1;
