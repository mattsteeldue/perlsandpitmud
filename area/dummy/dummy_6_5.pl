use VirtualRoom;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('The riverside') 
         ->desc( "You are near the torrent.\n" .
                 "The light is spotly because the woods.\n" .
                 "You can hear the torrent flowing here about." ) 
         
         ->add_exit('south', './room/north_door') 
         ->add_exit('down',  './room/mill') 
         ;

    return $self;
}
               
1;
