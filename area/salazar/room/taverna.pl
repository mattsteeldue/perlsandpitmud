use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Taverna') 
         ->desc( "Questa è la taverna del 'Cane Morto' " .
                 "e già il nome suggerisce quanto malfamata sia questa bettola. " .
                 "\n") 
    
         ->add_exit('ovest', './bassi_e3') 
         ->set_property('inn')  

         
         ; 
         
    return $self;
}

1;
