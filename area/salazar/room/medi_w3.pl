use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello mediano - ovest') 
         ->desc( "Questo è il livello mediano della torre sull'arco " .
                 "Ovest. " .
                 "Una rampa sale al livello superiore verso nordovest e " . 
                 "una scende al livello inferiore verso sud. " . 
                 "\n") 
    
         ->add_exit('nordest', './medi_w4') 
         ->add_exit('sud',     './medi_w2') 

         ->add_exit('alto', './alti_w4') 
         ->add_exit('basso', './bassi_w2') 

         
         ; 
         
    return $self;
}

1;
