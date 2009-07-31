use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello mediano') 
         ->desc( "Questo è il livello mediano della torre sull'arco " .
                 "Sud. " .
                 "Verso nord c'è la bottega del sarto. " .
                 "\n" ) 
    
         ->add_exit('ovest',   './medi_s2') 
         ->add_exit('nordest', './medi_e4') 
         ->add_exit('sud',   './tailor') 
    
         
         ; 
         
    return $self;
}

1;
