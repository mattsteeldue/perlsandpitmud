use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Ultimo livello') 
         ->desc( "Questo è il livello alto della torre sull'arco " .
                 "Est. ".
                 "\n") 
    
         ->add_exit('nord',     './alti_e1') 
         ->add_exit('sud',      './alti_e3') 

           
         ;

    return $self;
}

1;
