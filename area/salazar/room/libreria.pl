use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Libreria') 
         ->desc( "La libreria di Salazar." .
                 "\n") 
    
         ->add_exit('nord', './alti_n2') 
         ->set_property('library')  

           
         ;
         
    return $self;
}

1;
