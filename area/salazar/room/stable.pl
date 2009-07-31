use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Scuderie') 
         ->desc( "Scuderie di Salazar. " .
        "\n") 
    
         ->add_exit('sud', './bassi_n3') 

         
         ; 
         
    return $self;
}

1;
