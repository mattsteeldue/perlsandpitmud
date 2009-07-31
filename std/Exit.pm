# Exit.pm
# Created Aug 2006
# Author  flogisto

package Exit;
use strict;
##use diagnostics;

use Commons;
use Object;

our @ISA = qw(Object);

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $name  = shift;
    my $self  = $this->SUPER::new; 
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

__END__

