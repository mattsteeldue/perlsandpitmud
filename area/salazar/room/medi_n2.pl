use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello mediano') 
         ->desc( "Questo è il livello mediano della torre sull'arco " .
                 "Nord. " .
                 "Verso sud c'è l'entrata all'armeria di Salazar. ".
                 "\n" ) 
    
         ->add_exit('ovest', './medi_n1') 
         ->add_exit('est',   './medi_n3') 
    
           
         ;
         
    return $self;
}

1;
