use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Orto') 
         ->desc( "Orto zona Ovest.") 
    
         ->add_exit('nord',  './orto_1') 
         ->add_exit('sud',   './orto_7') 
         ->add_exit('ovest', './fondi_w2') 

         ->add_wandering_area( 'orto' )  
         ->set_property('outdoor')
         ;

    return $self;
}

