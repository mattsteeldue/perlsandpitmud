use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Ultimo livello') 
         ->desc( "Questo è il livello alto della torre sull'arco " .
                 "Sud. " .
                 "Una rampa sale al livello superiore verso est e " . 
                 "una scende al livello inferiore verso nordovest. " . 
                 "\n") 
    
         ->add_exit('nordovest', './alti_s4') 
         ->add_exit('est', './alti_s2') 

         ->add_exit('alto',  './attico_s2') 
         ->add_exit('basso', './medi_s4') 

           
         ;

    return $self;
}

1;
