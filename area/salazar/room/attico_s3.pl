use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Attico') 
         ->desc( "Questo è l'ultimo livello della torre sull'arco Sud. " .
                 "Verso sud vedi l'entrata al planetario di Salazar. " .
                 "Si tratta di una zona di passeggiata molto piacevole. " 
               ) 
    
         ->add_exit('nordovest', './attico_s4') 
         ->add_exit('est', './attico_s2') 
         ->add_exit('sud',  './planetario') 

         ->add_wandering_area( 'bird' ) 

         ->set_property('outdoor')  
         ;

    return $self;
}
