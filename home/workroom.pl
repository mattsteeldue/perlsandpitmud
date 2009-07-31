use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Workroom');
    $self->desc( "Questa è la tua stanza di lavoro. Mettila a posto." );

    return $self;
}
