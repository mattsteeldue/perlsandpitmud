use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Attico') 
         ->desc( "Questo è l'ultimo livello della torre sull'arco " .
                 "Nordest.\n" ) 
    
         ->add_exit('nordovest',  './attico_n3') 
         ->add_exit('sudest', './attico_e1') 
    
         ->add_wandering_area( 'bird' ) 

         ->set_property('outdoor')  
         ;

    return $self;
}
