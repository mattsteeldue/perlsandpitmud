use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Attico') 
         ->desc( "Questo è l'ultimo livello della torre sull'arco " .
                 "Nord.\n" ) 
    
         ->add_exit('ovest',  './attico_n2') 
         ->add_exit('sudest', './attico_n4') 
    
         ->add_wandering_area( 'bird' ) 

         ->set_property('indoor')
         ;

    return $self;
}
