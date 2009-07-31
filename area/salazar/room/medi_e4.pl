use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello mediano') 
         ->desc( "Questo è il livello mediano della torre sull'arco " .
                 "Est. " .
                 "Una rampa sale al livello superiore verso nordest e " . 
                 "una scende al livello inferiore verso sudovest. " . 
                 "\n") 
    
         ->add_exit('nordest',   './medi_e3') 
         ->add_exit('sudovest',  './medi_s1') 

         ->add_exit('alto',  './alti_e3') 
         ->add_exit('basso', './bassi_s1') 
    
         
         ; 
         
    return $self;
}

1;
