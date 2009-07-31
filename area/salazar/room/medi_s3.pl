use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello mediano') 
         ->desc( "Questo è il livello mediano della torre sull'arco " .
                 "Sud. " .
                 "Una rampa sale al livello superiore verso nordovest e " . 
                 "una scende al livello inferiore verso est. " . 
                 "\n") 
    
         ->add_exit('nordovest', './medi_s4') 
         ->add_exit('est', './medi_s2') 

         ->add_exit('alto', './alti_s4') 
         ->add_exit('basso', './bassi_s2') 

         
         ; 
         
    return $self;
}

1;
