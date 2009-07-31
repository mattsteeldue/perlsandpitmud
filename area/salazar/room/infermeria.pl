use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Infermeria') 
         ->desc( "Infermeria Salazar." .
                 "\n") 
    
         ->add_exit('ovest', './attico_e3') 
         ->set_property('infirmary')  

           
         ;
         
    return $self;
}

