use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Ultimo livello') 
         ->desc( "Questo è il livello alto della torre sull'arco " .
                 "Sud. " .
                 "Una rampa sale al livello superiore verso nordovest e " . 
                 "una scende al livello inferiore verso sudest. " . 
                 "\n") 
    
         ->add_exit('nordovest', './alti_w1') 
         ->add_exit('sudest', './alti_s3') 

         ->add_exit('alto', './attico_w1') 
         ->add_exit('basso', './medi_s3') 

           
         ;

    return $self;
}

1;
