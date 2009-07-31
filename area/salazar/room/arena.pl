use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Arena') 
         ->desc( "Arena di Salazar. " .
        "\n") 
    
         ->add_exit('nord',   './bassi_s3') 

           
         ;

    return $self;
}

1;
