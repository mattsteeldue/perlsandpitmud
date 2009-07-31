use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello inferiore - ovest') 
         ->desc( "Questo è il livello basso della torre sull'arco " .
                 "Ovest. " .
                 "Una rampa sale al livello superiore verso sudest." . 
                 "\n") 
    
         ->add_exit('nord',   './bassi_w2') 
         ->add_exit('sudest', './bassi_s4') 

         ->add_exit('alto',  './medi_s4') 

           
         ;

    return $self;
}

1;
