use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Fabbro') 
         ->desc( "Fabbro di Salazar. " .
        "\n") 
    
         ->add_exit('est', './medi_w1') 

           
         ;
         
    return $self;
}

1;
