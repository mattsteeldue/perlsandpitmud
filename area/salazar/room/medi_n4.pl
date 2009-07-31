use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello mediano') 
         ->desc( "Questo è il livello mediano della torre sull'arco " .
                 "Nord. " .
                 "Una rampa sale al livello superiore verso nordovest e " . 
                 "una scende al livello inferiore verso sudest. " . 
                 "\n") 
    
         ->add_exit('nordovest',  './medi_n3') 
         ->add_exit('sudest', './medi_e1') 
    
         ->add_exit('alto',  './alti_n3') 
         ->add_exit('basso', './bassi_e1') 
    
         
         ; 
         
    return $self;
}

1;
