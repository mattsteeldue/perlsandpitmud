use Room;

sub new {
    my $this  = shift;
    #my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, ref($this) || $this;
    
    $self->short('Fondamenta - ovest')
         ->desc( "Questo è una galleria nelle fondamenta della torre. " .
                 "Si tratta di un luogo buio caratterizzato da un tanfo insopportabile. " .
                 "\n") 
    
         ->add_exit('nord',   './fondi_w2') 
         ->add_exit('sudest', './fondi_s4') 

         ->set_property(['dark']) 

           
         ;

    return $self;
}

1;
