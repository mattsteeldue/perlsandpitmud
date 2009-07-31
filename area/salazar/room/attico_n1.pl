use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Attico') 
         ->desc( "Questo è l'ultimo livello della torre sull'arco " .
                 "Nord. " .
                 "Una rampa scende al livello inferiore verso sudovest. " . 
                 "\n") 
    
         ->add_exit('sudovest', './attico_w4') 
         ->add_exit('est',      './attico_n2') 
    
         ->add_exit('basso', './alti_w4') 
    
         ->add_object( '../obj/skull') 
         ->add_object( '../obj/torch') 

         ->add_wandering_area( 'bird' ) 

         ->set_property('outdoor')  
         ;

    return $self;
}
