use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello mediano') 
         ->desc( "Questo è il livello mediano della torre sull'arco " .
                 "Sud." .
                 "\n" ) 
    
         ->add_exit('ovest', './medi_s3') 
         ->add_exit('est',   './medi_s1') 

         
         ; 
         
    return $self;
}

1;
