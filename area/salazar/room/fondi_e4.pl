use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello inferiore') 
         ->desc( "Questo è il livello basso della torre sull'arco " .
                 "Est.\n" ) 
    
         ->add_exit('nordest',   './bassi_e3') 
         ->add_exit('sudovest',  './bassi_s1') 

         ->add_exit('nordovest', './orto_9') 

           
         ;
    return $self;
}

1;
