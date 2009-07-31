use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello mediano') 
         ->desc( "Questo è il livello mediano della torre sull'arco " .
                 "Sud. " .
                 "Una rampa sale al livello superiore verso sudest e " . 
                 "una scende al livello inferiore verso nordovest. " . 
                 "\n") 
    
         ->add_exit('nordovest', './medi_w1') 
         ->add_exit('sudest', './medi_s3') 

         ->add_exit('alto',  './alti_s3') 
         ->add_exit('basso', './bassi_w1') 

         
         ; 
         
    return $self;
}

1;
