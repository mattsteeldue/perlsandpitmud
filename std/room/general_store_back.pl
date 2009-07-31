use BackShop;

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new ( $this ); 
    bless $self, $class;
    
    $self->short("Magazzino generale");
    $self->desc( "Questo è il magazzino di default di ogni shop" .
                 "\n");
    return $self;
}

1;
