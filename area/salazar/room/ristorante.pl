use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Ristorante') 
         ->desc( "Ristorante." .
                 "\n") 
    
         ->add_exit('ovest', './alti_e1') 
         ->set_property('inn')  

         
         ; 
         
    return $self;
}

1;
