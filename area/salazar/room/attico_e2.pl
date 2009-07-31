use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Attico') 
         ->desc( "Questo è l'ultimo livello della torre sull'arco " .
                 "Est. " .
                 "Verso sud intravedi l'insegna dell'infermeria " .
                 "Da qui si vede in lontananza la sagoma della Rocca. " .
                 "Una rampa scende al livello inferiore verso sud. " . 
                 "\n") 
    
         ->add_exit('nord',     './attico_e1') 
         ->add_exit('sud',      './attico_e3') 

         ->add_exit('basso', './alti_e3') 
    
         ->add_wandering_area( 'bird' ) 

         ->set_property('indoor')  
         ;

    return $self;
}
