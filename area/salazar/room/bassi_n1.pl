use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello inferiore') 
         ->desc( "Questo è il livello basso della torre sull'arco " .
                 "Nord. " .
                 "Una rampa sale al livello superiore verso sudovest." . 
                 "\n") 
    
         ->add_exit('sudovest', './bassi_w4') 
         ->add_exit('est',      './bassi_n2') 
    
         ->add_exit('alto',  './medi_w4') 
    
           
         ;

    return $self;
}

1;
