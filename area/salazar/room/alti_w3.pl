use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Ultimo livello - ovest') 
         ->desc( "Questo è il livello alto della torre sull'arco " .
                 "Ovest. " .
                 "Una rampa sale al livello superiore verso sud e " . 
                 "una scende al livello inferiore verso nordest. " . 
                 "\n") 
    
         ->add_exit('nordest', './alti_w4') 
         ->add_exit('sud',     './alti_w2') 

         ->add_exit('alto',  './attico_w2') 
         ->add_exit('basso', './medi_w4') 

           
         ;

    return $self;
}

1;
