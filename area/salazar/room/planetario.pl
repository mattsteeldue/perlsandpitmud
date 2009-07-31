use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Planetario') 
         ->desc( "Planetario di Salazar. " .
        "Osservatorio e planetario di Salazar." .
        "\n") 
    
         ->add_exit('nord', './attico_s3') 

         
         ; 
         
    return $self;
}

1;
