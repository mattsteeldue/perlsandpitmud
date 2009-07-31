use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello mediano') 
         ->desc( "Questo è il livello mediano della torre sull'arco " .
                 "Est.\n" ) 
    
         ->add_exit('nordovest', './medi_n4') 
         ->add_exit('sud',       './medi_e2') 
         ->add_exit('est',      './jeweller') 

           
         ;
         
    return $self;
}

1;
