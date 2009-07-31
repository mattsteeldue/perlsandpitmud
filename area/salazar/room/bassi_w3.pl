use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello inferiore - ovest') 
         ->desc( "Questo è il livello basso della torre sull'arco " .
                 "Ovest. " .
                 "Verso ovest puoi accedere ai Magazzini Generali. " .
                 #vedi l'insegna dell'emporio principale di Salazar " .
                 "\n" ) 
    
         ->add_exit('nordest', './bassi_w4') 
         ->add_exit('sud',     './bassi_w2') 
         ->add_exit('ovest',   './magazzini') 

           
         ;

    return $self;
}

1;
