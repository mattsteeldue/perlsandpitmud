use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->short('Casa di soana') 
         ->desc( "Ti trovi nella casa di Soana. La saletta tappezzata di scaffali ".
                 "con libri e recipienti con il contenuto di ogni colore. " .
                 "Al centro c'è un tavolo il caminetto acceso." .
                 "\n") 
                 
         ->add_detail('saletta',
          "E` tappezzata di scaffali colmi di libri e recipienti." )  
         ->add_detail('libri',
          "Scorri rapidamente i titoli, si tratta di libri di magia." )  
         ->add_detail('recipienti',
          "Si tratta di recipienti di varia misura." )  
         ->add_detail('tavolo',
          "Anche questo è colmo di libri." )  
         ->add_detail('caminetto',
          "C'è una pentola. Qualcosa sta cuocendo." )  
         ->add_detail('pentola',
          "Meglio non toccare." )  

         ->set_property(['indoor','magic']) 
    
    # by default a virtual-room has four exits.
    # so 'entra' substitutes 'est'.
         ->add_exit('esci', './radura', '$n esce' ) 
         ;
    return $self;
}

1;
