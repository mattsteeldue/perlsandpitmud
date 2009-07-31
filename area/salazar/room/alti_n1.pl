use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Ultimo livello') 
         ->desc( "Questo è il livello alto della torre sull'arco " .
                 "Nord. " .
                 "C'e` l'insegna dell'Ufficio Postale di Salazar " .
                 "da dove è possibile inviare messaggi di posta verso chiunque nel Mondo Emerso " .
                 "e ovviamente è il luogo dove poterli ricevere e leggere. " .
                 "\n") 
    
         ->add_exit('nord',  './postoffice') 
         ->add_exit('sudovest', './alti_w4') 
         ->add_exit('est',      './alti_n2') 
    
         ->add_object( '../obj/skull') 
         ->add_object( '../obj/torch') 

           
         ;
    return $self;
}

1;
