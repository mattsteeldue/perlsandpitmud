use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello inferiore') 
         ->desc( "Questo è il livello basso della torre sull'arco " .
                 "Est. " .
                 "Una rampa sale al livello superiore verso sud. " . 
                 #"Verso est si apre l'omonima Porta Est. " .
                 "\n") 
    
         ->add_exit('nord',     './bassi_e1') 
         ->add_exit('sud',      './bassi_e3') 

         ->add_exit('alto', './medi_e3') 

    #     ->add_exit('est', 'area/mondo_emerso/em_29_68') 

           
         ;

    return $self;
}

1;
