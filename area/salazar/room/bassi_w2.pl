use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello inferiore') 
         ->desc( "Questo è il livello basso della torre percorrendo l'arco " .
                 "Ovest. " .
                 "Una rampa sale al livello superiore in direzione nord. " . 
                 "Verso ovest, attraverso tutto lo spessore delle mura " .
                 " si apre la magnifica Porta Occidentale. " .
                 "\n") 
    
         ->add_exit('nord', './bassi_w3') 
         ->add_exit('sud',  './bassi_w1') 

         ->add_exit('alto', './medi_w3') 

         ->add_exit('ovest', './porta_ovest') 

           
         ;

    return $self;
}

1;
