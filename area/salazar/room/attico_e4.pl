use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Attico') 
         ->desc( "Questo è l'ultimo livello della torre sull'arco " .
                 "Sudest. " .
                 "Si tratta di una zona di passeggiata molto piacevole. " .
                 "\n" ) 
    
         ->add_exit('nordest',   './attico_e3') 
         ->add_exit('sudovest',  './attico_s1') 

         ->add_wandering_area( 'bird' ) 

         ->set_property('outdoor')  
         ;

    return $self;
}
