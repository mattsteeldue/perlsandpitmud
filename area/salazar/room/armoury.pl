use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Armeria') 
         ->desc( "Armeria di Salazar. " .
        "\n") 
    
         ->add_exit('sud', './medi_n1') 

           
         ; 

    return $self;
}

1;
