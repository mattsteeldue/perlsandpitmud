use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello mediano') 
         ->desc( "Questo è il livello mediano della torre sull'arco " .
                 "Nord. " .
                 "Una rampa sale al livello superiore verso sudest e " . 
                 "una scende al livello inferiore verso ovest. " . 
                 "\n") 
    
         ->add_exit('ovest',  './medi_n2') 
         ->add_exit('sudest', './medi_n4') 
    
         ->add_exit('alto', './alti_n4') 
         ->add_exit('basso', './bassi_n2') 

         
         ; 
         
    return $self;
}

1;
