use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello mediano') 
         ->desc( "Questo è il livello mediano della torre sull'arco " .
                 "Est." .
                 "\n" ) 
    
         ->add_exit('nord',     './medi_e1') 
         ->add_exit('sud',      './medi_e3') 

           
         ;
         
    return $self;
}

1;
