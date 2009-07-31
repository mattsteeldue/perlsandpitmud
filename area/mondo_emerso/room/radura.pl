use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->short('Radura nella foresta');
    $self->desc( "Ti trovi in una piccola radura circondata dagli alberi della foresta. " .
                 "Si tratta di una piccola casetta fatta di assi di legno con due finestre " .
                 "e un camino in pietra dal quale esce un filo di fumo." .
                 "\n");
    
    $self->set_property(['forest','outdoor','meadow']);             
    
    # by default a virtual-room has four exits.
    # so 'entra' substitutes 'est'.
    $self->add_exit('entra', './casa_di_soana');
    $self->add_exit('ovest', '../em_28_72');
    $self->add_exit('nordovest', '../em_28_71');

    return $self;
}

1;
