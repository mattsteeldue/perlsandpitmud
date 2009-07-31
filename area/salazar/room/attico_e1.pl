use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Attico') 
         ->desc( "Questo è l'ultimo livello della torre sull'arco " .
                 "Est. " .
                 "Una rampa scende al livello inferiore verso nordovest. " . 
                 "\n") 
    
         ->add_exit('nordovest', './attico_n4') 
         ->add_exit('sud',       './attico_e2') 

         ->add_exit('basso', './alti_n4') 

         ->add_wandering_area( 'bird' ) 

         ->set_property('outdoor')  
         ;

    return $self;
}
