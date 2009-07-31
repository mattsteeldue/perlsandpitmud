use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Orto') 
         ->desc( "Orto zona Sud.") 
    
         ->add_exit('sudest', './bassi_e4') 

         ->add_exit('ovest', './orto_8') 
         ->add_exit('nord', './orto_6') 

         ->add_wandering_area( 'orto' )  
         ->set_property('outdoor')
         ;

    return $self;
}

