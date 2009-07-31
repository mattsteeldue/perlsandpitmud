use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Terrazza - ovest') 
         ->desc( "Questo è l'ultimo livello della torre sull'arco " .
                 "Ovest. " .
                 "Verso ovest vedi l'entrata di un piccolo templo. " .
                 "\n" ) 
    
         ->add_exit('nordest', './attico_w4') 
         ->add_exit('sud',     './attico_w2') 
         ->add_exit('ovest',   './templo') 

         ->add_wandering_area( 'bird' ) 

         ->set_property('outdoor')  
         ;

    return $self;
}
