use VirtualRoom;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('La sponda del fiume') 
         ->desc( "Sei vicino alla sponda del torrente.\n" .
                 "La luce filtra a macchie attraverso i rami.\n" .
                 "Riesci a sentire il torrente che scorre da qualce parte qui sotto." ) 
         
         ->add_exit('sud', './room/north_door') 
         ->add_exit('basso',  './room/mill') 
         ;

    return $self;
}
               
1;
