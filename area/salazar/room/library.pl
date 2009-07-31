use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Biblioteca') 
         ->desc( "Biblioteca di Salazar. " .
        "\n") 
    
         ->add_exit('nord', './alti_s1') 

           
         ;
         
    return $self;
}

1;
