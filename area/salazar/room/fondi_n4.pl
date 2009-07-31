use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello inferiore') 
         ->desc( "Questo è il livello basso della torre sull'arco " .
                 "Nord.\n" ) 
    
         ->add_exit('nordovest',  './bassi_n3') 
         ->add_exit('sudest', './bassi_e1') 
    
         ->add_exit('sudovest', './orto_3') 

           
         ;

    return $self;
}

1;
