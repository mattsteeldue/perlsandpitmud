use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello inferiore') 
         ->desc( "Questo è il livello basso della torre sull'arco " .
                 "Sud. " .
                 "Una rampa sale al livello superiore verso ovest. " . 
                 "\n") 
    
         ->add_exit('ovest', './bassi_s3') 
         ->add_exit('est',   './bassi_s1') 
    
         ->add_exit('alto',    './medi_s3') 


           
         ;

    return $self;
}

1;
