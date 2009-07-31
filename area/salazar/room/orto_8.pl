use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Orto') 
         ->desc( "Orto zona Sud.") 
    
         ->add_exit('ovest', './orto_7') 
         ->add_exit('est', './orto_9') 

         ->add_wandering_area( 'orto' )  
         ->set_property('outdoor')
         ;

    return $self;
}
