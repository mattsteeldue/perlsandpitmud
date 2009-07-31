use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Orto di Baar') 
         ->desc( "Questo è la parte di mezzo del giardino centrale. " .
                 "Il terreno è coltivato ad orto e tutt'intorno. " .
                 "si vedono lunghe file di zucchine, lattuga, erba cipollina " .
                 "e anche qualche albero da frutta " .
                 "C'è una piccola casetta in muratura, con una sola finestra " .
                 "Di fronte alla casa c'è un pozzo per l'acqua." ) 
    
         ->add_detail(['casa','casetta'],
        "E' la casa di Baar, il custode dell'orto." ) 
         ->add_detail(['giardino'],
        "Sei proprio nel centro del giardino" ) 
         ->add_detail(['terreno','coltivato','orto'],
        "L'orto è ben curato coltivato, sicuramente il custode sta facendo un buon lavoro." ) 
         ->add_detail(['zucchine','lattuga','erba'],
        "Meglio non toccare nulla." ) 
         ->add_detail(['acqua'],
        "E' nel pozzo." ) 
         ->add_detail(['pozzo','vera','marmo'],
        "Si tratta di un bel pozzo in mattoni con una vera in marmo, con solchi profondi " .
        "a causa delle corde usate per attingere l'acqua: attento a non caderci dentro." ) 
        
         ->add_exit('est', './orto_6') 

         ->add_wandering_area( 'orto' )  
         ->add_object( '../mon/baar') 
         ->set_property('outdoor')
         ;

    return $self;
}

