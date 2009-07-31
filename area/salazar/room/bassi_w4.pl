use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello inferiore - ovest') 
         ->desc( "Questo è il livello basso della torre sull'arco " .
                 "Ovest.\n" ) 
    
         ->add_exit('nordest',  './bassi_n1') 
         ->add_exit('sudovest', './bassi_w3') 

         ->add_exit('sudest', './orto_1') 

           
         ;

    return $self;
}

1;
