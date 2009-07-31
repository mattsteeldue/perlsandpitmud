use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello mediano - ovest') 
         ->desc( "Questo è il livello mediano della torre sull'arco " .
                 "Ovest. " .
                 "\n" ) 
    
         ->add_exit('nord',  './medi_w3') 
         ->add_exit('sud',   './medi_w1') 

         
         ; 
         
    return $self;
}

1;
