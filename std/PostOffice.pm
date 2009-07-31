# PostOffice.pm
# Created Aug 2006
# Author  flogisto

package PostOffice;
use strict;

##use diagnostics;
use Commons;
use Room;

our @ISA = qw(Room);
               
# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new;
    bless $self, $class;

    $self->light( 1 );
    
    return $self;
}
    

1;
