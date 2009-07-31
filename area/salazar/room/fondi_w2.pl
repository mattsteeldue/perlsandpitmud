use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Fondamenta - ovest') 
         ->desc( "Questo è una galleria nelle fondamenta della torre. " .
                 "Si tratta di un luogo buio caratterizzato da un tanfo insopportabile. " .
                 "Una rampa ti consente di tornare alla superficie. " . 
                 "\n") 
    
         ->add_exit('nord', './fondi_w3') 
         ->add_exit('sud',  './fondi_w1') 

         ->add_exit('alto', './medi_w3') 

         ->add_exit('est', './orto_4') 

           
         ;
    
    return $self;
}

1;
