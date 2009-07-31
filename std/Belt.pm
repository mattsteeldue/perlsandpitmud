# Belt.pm
# Created Nov 2006
# Author  flogisto

package Belt;
use strict;
##use diagnostics;

use Commons;
use Garment;
our @ISA = qw(Garment);

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $name  = shift || 0;
    my $self  = $this->SUPER::new( $name ); 
    bless $self, $class;
    return $self;
}

# ---------------------------------------------------------------------
sub destroy {
    my $this  = shift;
    my $class = ref($this) || $this;
    $this->SUPER::destroy; 
    return $this;
}

1;
