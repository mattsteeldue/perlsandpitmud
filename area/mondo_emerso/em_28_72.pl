use VirtualRoom;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->short('Terra del Vento - Sentiero nella foresta') 
         ->desc( "Il sentiero prosegue verso sud nel folto della foresta e " .
                 "verso nord ritorna verso Salazar. " .
                 "A molti passi dal sentiero intravedi una radura." .
                 "\n") 
    
         # by default a virtual-room has four exits.
         # so 'entra' substitutes 'est'.
         ->add_exit('radura', './room/radura', '$n esce verso la radura' ) 
         ->remove_exit('est', './em_29_72')
         ;  

    return $self;
}

1;
