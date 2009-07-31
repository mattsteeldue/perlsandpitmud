use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Gioiellere') 
         ->desc( "Gioiellere di Salazar. " .
                 "Verso ovest vedi l'insegna di una bottega d'orefice. " .
                 "\n") 
    
         ->add_exit('ovest', './medi_e1') 

           
         ;
         
    return $self;
}

1;
