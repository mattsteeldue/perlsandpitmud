use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello inferiore') 
         ->desc( "Questo è il livello basso della torre sull'arco " .
                 "Est. " .
                 "Un'insegna raffigurante un cane morto è appesa qui a fianco. " .
                 "\n" ) 
    
         ->add_exit('nord',      './bassi_e2') 
         ->add_exit('sudovest',  './bassi_e4') 
         ->add_exit('est',      './taverna') 

           
         ;

    return $self;
}

1;
