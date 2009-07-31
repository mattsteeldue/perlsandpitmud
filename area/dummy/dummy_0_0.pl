use VirtualRoom;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->short('A small valley') 
         ->desc( "A small valley.\n") 
         ;
    
    return $self;
}

1;
