use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello inferiore') 
         ->desc( "Questo è il livello basso della torre sull'arco " .
                 "Nord. " .
                 "Una rampa sale al livello superiore verso est. " . 
                 "Verso est si apre l'omonima Porta Est. " .
                 "\n") 
    
         ->add_exit('ovest', './bassi_n1') 
         ->add_exit('est',   './bassi_n3') 
    
         ->add_exit('alto', './medi_n3') 

         ->add_object( '../obj/skull') 
         ->add_object( '../obj/torch') 

           
         ;

    return $self;
}

1;
