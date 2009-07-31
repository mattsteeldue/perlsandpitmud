use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello mediano') 
         ->desc( "Questo è il livello mediano della torre sull'arco " .
                 "Est. " .
                 "Una rampa sale al livello superiore verso sudovest e " . 
                 "una scende al livello inferiore verso nord. " . 
                 "\n") 
    
         ->add_exit('nord',      './medi_e2') 
         ->add_exit('sudovest',  './medi_e4') 

         ->add_exit('alto', './alti_e4') 
         ->add_exit('basso', './bassi_e2') 

         
         ; 
         
    return $self;
}

1;
