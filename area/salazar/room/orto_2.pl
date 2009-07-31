use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Orto') 
         ->desc( "Orto zona Nord.") 
    
         ->add_exit('ovest', './orto_1') 
         ->add_exit('est', './orto_3') 

         ->add_wandering_area( 'orto' )  
         ->set_property('outdoor')
         ;

    return $self;
}

