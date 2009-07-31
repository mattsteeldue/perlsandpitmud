use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Ultimo livello') 
         ->desc( "Questo è il livello alto della torre sull'arco " .
                 "Est. " .
                 "Una rampa sale al livello superiore verso sudovest e " . 
                 "una scende al livello inferiore verso nordest. " . 
                 "\n") 
    
         ->add_exit('nordest',   './alti_e3') 
         ->add_exit('sudovest',  './alti_s1') 

         ->add_exit('alto', './attico_s1') 
         ->add_exit('basso', './medi_e3') 

           
         ;
    return $self;
}

1;
