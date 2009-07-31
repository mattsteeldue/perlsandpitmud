use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Ultimo livello') 
         ->desc( "Questo è il livello alto della torre sull'arco " .
                 "Sud. " .
                 "\n" ) 
    
         ->add_exit('ovest', './alti_s3') 
         ->add_exit('est',   './alti_s1') 

           
         ;
    return $self;
}

1;
