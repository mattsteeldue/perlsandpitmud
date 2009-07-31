use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Magazzini Generali') 
         ->desc( "Questo è l'atrio dei Magazzini Generali di Salazar. " .
                 "A motivo della vicinanza con l'ampia Porta Ovest, " .
                 "I vari commercianti della torre usano accogliere in questo luogo " .
                 "le varie merci che giungono da fuori. " .
                 "Si tratta di un luogo di forte passaggio e grande confusione." .
                 "\n") 
    
         ->add_exit('est', './bassi_w3') 

         
         ; 
         
    return $self;
}

1;
