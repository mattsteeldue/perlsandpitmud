use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Ufficio Postale') 
         ->desc( "Questo è l'Ufficio Postale di Salazar. ".
                 "Qui è possibile usare il comando '{B}mail{/B}'. " .   
                 "Da qui è possibile inviare messaggi di posta verso chiunque nel Mondo Emerso " .
                 "e ovviamente è il luogo dove poterli ricevere e leggere. " .
                 "Prova anche con '{B}help mail{/B}'. " .
                 "\n") 
    
         ->add_exit('sud', './alti_n1') 
         ->set_property('postoffice')  # in questo modo funziona il comando cmd/norm.

    # il comando è stato integrato nella directory cmd/norm
    #     ->add_action( 'mail', 'do_mail' ) 

         
         ; 
         
    return $self;
}

1;
