use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Orto') 
         ->desc( "Orto zona Est.") 
    
         ->add_exit('nord', './orto_3') 
         ->add_exit('sud', './orto_9') 
         ->add_exit('ovest', './orto_5') 

         ->add_wandering_area( 'orto' )  
         ->set_property('outdoor')
         ;

    return $self;
}

