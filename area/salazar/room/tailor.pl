use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Sarto') 
         ->desc( "Sarto di Salazar. " .
        "\n") 
    
         ->add_exit('nord', './medi_s1') 

         
         ; 
         
    return $self;
}

1;
