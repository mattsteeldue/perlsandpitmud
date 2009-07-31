use VirtualRoom;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->short('La vallata') 
         ->desc( "La vallata.\n") 
         ;
    
    return $self;
}

1;
