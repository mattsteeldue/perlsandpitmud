use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello inferiore') 
         ->desc( "Questo è il livello basso della torre sull'arco " .
                 "Sud. " .
                 "Verso sud vedi l'entrata della grande arena. " .
                 "\n" ) 
    
         ->add_exit('nordovest', './bassi_s4') 
         ->add_exit('est',  './bassi_s2') 
         ->add_exit('sud',  './arena') 

           
         ;

    return $self;
}

1;
