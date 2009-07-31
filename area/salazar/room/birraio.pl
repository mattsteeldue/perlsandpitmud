use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Birraio') 
         ->desc( "La cantina del birraio è totalmente impregnata di vapori e aromi. ".
                 "è possibile dissetarsi e degustare della buona birra a buon mercato e in compagnia." .
                 "\n") 
    
         ->add_exit('est', './alti_w1') 
         ->set_property('inn')  

           
         ;

    return $self;
}

1;
