use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Ultimo livello - ovest') 
         ->desc( "Questo è il livello alto della torre sull'arco " .
                 "Ovest. " .
                 "Una rampa sale al livello superiore verso nordest e " . 
                 "una scende al livello inferiore verso sudovest. " . 
                 "\n") 
    
         ->add_exit('nordest',  './alti_n1') 
         ->add_exit('sudovest', './alti_w3') 

         ->add_exit('alto', './attico_n1') 
         ->add_exit('basso', './medi_w3') 

           
         ;

    return $self;
}

1;
