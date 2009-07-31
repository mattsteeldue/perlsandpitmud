use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Ultimo livello') 
         ->desc( "Questo è il livello alto della torre sull'arco " .
                 "Nord. " .
                 "Una rampa sale al livello superiore verso sudest e " . 
                 "una scende al livello inferiore verso nordovest. " . 
                 "\n") 
    
         ->add_exit('nordovest',  './alti_n3') 
         ->add_exit('sudest', './alti_e1') 
    
         ->add_exit('alto', './attico_e1') 
         ->add_exit('basso', './medi_n3') 

           
         ;

    return $self;
}

1;
