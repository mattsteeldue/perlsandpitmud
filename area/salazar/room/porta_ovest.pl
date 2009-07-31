use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Porta della città Salazar') 
         ->desc( "Sei sotto il magnifico arco della porta di Salazar. " .
                 "Qui a fianco vedi l'entrata del Corpo di Guardia della Torre. " .
                 "Uscendo verso {B}ovest{/B}, stai per avventurarti nello sterminato " .
                 "territorio del Mondo Emerso" .
                 "\n") 
    
           

         ->add_exit('est',   './bassi_w2') 
         ->add_exit('entra', './guard', '$n entra nel corpo di guardia') 

         ->add_exit('ovest', 'area/mondo_emerso/em_28_68') 
    
         ->add_object( '../obj/sextant' ) 
         ->add_object( '../mon/guard' )
         ;

    return $self;
}

1;
