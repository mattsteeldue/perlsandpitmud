use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello inferiore') 
         ->desc( "Questo è il livello basso della torre sull'arco " .
                 "Sud. " .
                 "\n" ) 
    
         ->add_exit('nordovest', './bassi_w1') 
         ->add_exit('sudest', './bassi_s3') 

         ->add_exit('nordest', './orto_7') 

           
         ;

    return $self;
}

1;
