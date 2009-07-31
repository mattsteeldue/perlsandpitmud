use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Scuola');
    $self->desc( "Questa è la scuola" );
    
    return $self;
}
