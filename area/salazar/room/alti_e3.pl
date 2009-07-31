use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Ultimo livello') 
         ->desc( "Questo è il livello alto della torre sull'arco " .
                 "Est. " .
                 "Una rampa sale al livello superiore verso nord e " . 
                 "una scende al livello inferiore verso sudovest. " . 
                 "\n") 
    
         ->add_exit('nord',      './alti_e2') 
         ->add_exit('sudovest',  './alti_e4') 

         ->add_exit('alto',  './attico_e2') 
         ->add_exit('basso', './medi_e4') 
    
           
         ;

    return $self;
}

1;
