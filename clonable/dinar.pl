# money.pl
# Created Dec 2006
# Author  flogisto

use Money;

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $amount = shift || 1;
    my $self  = $this->SUPER::new( $amount ); 
    $self->short( \&short_amount );
    $self->desc( \&short_amount );

    bless $self, $class;
    return $self;
}

# ---------------------------------------------------------------------
sub short_amount {
    return $_[0]->amount . " dinar" ;
}
