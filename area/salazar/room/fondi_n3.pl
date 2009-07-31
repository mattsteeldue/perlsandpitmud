use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello inferiore') 
         ->desc( "Questo è il livello basso della torre sull'arco " .
                 "Nord. " .
                 "Verso nord c'è l'ingresso alle scuderie. " .
                 "\n" ) 
    
         ->add_exit('ovest',  './bassi_n2') 
         ->add_exit('sudest', './bassi_n4') 
         ->add_exit('nord',   './stable') 
    
           
         ;

    return $self;
}

1;
