use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Ultimo livello') 
         ->desc( "Questo è il livello alto della torre sull'arco " .
                 "Ovest." .
                 "Sul lato est si nota l'insegna della più antica osteria di Salazar. " .
                 "Le voci e il profumo che provengono dalla birreria probabilmente sono segno della " .
                 "buona qualità della birra che viene servita." .
                 "\n" ) 
    
         ->add_exit('nord',   './alti_w2') 
         ->add_exit('sudest', './alti_s4') 

         ->add_exit('ovest',  './birraio') 

           
         ;

    return $self;
}

1;
