use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Ultimo livello') 
         ->desc( "Questo è il livello alto della torre sull'arco " .
                 "Nord. " .
                 "Un cartello indica che l'Ufficio Postale si trova verso ovest " .
                 "Una rampa sale al livello superiore verso ovest e " . 
                 "una scende al livello inferiore verso sudest. " . 
                 "\n") 
    
         ->add_exit('ovest',  './alti_n2') 
         ->add_exit('sudest', './alti_n4') 
    
         ->add_exit('alto',  './attico_n2') 
         ->add_exit('basso', './medi_n4') 

         ->add_detail('cartello',
        "Presso l'Ufficio Postale è possibile inviare messaggi di posta " .
        "verso chiunque nel Mondo Emerso " ) 
         ->add_detail(['arco','rampa'],
        "La torre è di pianta essenzialmente cilindrica suddivisa in tre " .
        "piani principali collegati da rampe." ) 
    
           
         ;

    return $self;
}

1;
