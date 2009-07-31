use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello mediano') 
         ->desc( "Questo è il livello mediano della torre sull'arco " .
                 "Ovest. " .
                 "Verso ovest c'è la bottega di un fabbro ferraio di Salazar. " .
                 "\n" ) 
    
         ->add_exit('nord',   './medi_w2') 
         ->add_exit('sudest', './medi_s4') 
         ->add_exit('ovest', './smith') 

         
         ; 
         
    return $self;
}

1;
