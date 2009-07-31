use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Fondamenta - ovest') 
         ->desc( "Questo è una galleria nelle fondamenta della torre. " .
                 "Si tratta di un luogo buio caratterizzato da un tanfo insopportabile. " .
                 "\n" ) 
    
         ->add_exit('nordest', './fondi_w4') 
         ->add_exit('sud',     './fondi_w2') 

         ->set_property(['dark']) 

           
         ;
         
    return $self;
}

1;
