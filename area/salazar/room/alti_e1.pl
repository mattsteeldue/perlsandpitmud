use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Ultimo livello') 
         ->desc( "Questo è il livello alto della torre sull'arco " .
                 "Est." .
                 "Lungo il lato di questo passaggio c'è l'entrata del Ristorante " .
                 "dove potrai rifocillarti e riprendere le forze tra un'impresa e l'altra." .
                 "\n") 
    
         ->add_exit('nordovest', './alti_n4') 
         ->add_exit('sud',       './alti_e2') 
         ->add_exit('est',      './ristorante') 

           
         ;
 
    return $self;
}

1;
