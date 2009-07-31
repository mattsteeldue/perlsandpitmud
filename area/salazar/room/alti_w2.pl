use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Ultimo livello - ovest') 
         ->desc( "Questo è il livello alto della torre sull'arco " .
                 "Ovest. " .
                 "\n") 
    
         ->add_exit('nord', './alti_w3') 
         ->add_exit('sud',  './alti_w1') 

           
         ;

    return $self;
}

1;
