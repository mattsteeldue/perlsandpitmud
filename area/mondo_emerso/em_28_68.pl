use VirtualRoom;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->short('Torre di Salazar') 
         ->desc( "Sei di fronte alla porta principale della torre di Salazar " .
                 "Da qui puoi accedere all'interno della città. " .
                 "Un sentiero si dirige verso sud fino alla foresta." .
                 "\n") 
    
         # by default a virtual-room has four exits.
         # so 'entra' substitutes 'est'.
         ->remove_exit('est', 'area/salazar/room/porta_ovest') 
         ->add_exit('entra', 'area/salazar/room/porta_ovest', '$n entra in città') 
         ;
    return $self;
}

1;
