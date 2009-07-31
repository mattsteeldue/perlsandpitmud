use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Ultimo livello') 
         ->desc( "Questo è il livello alto della torre sull'arco " .
                 "Sud." .
                 "Qui vicino vedi l'entrata alla biblioteca principale di Salazar. " .
                 "\n") 
    
         ->add_exit('ovest',   './alti_s2') 
         ->add_exit('nordest', './alti_e4') 
         ->add_exit('sud',     './library') 
    
           
         ;
    return $self;
}

1;
