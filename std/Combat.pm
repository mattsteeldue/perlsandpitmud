# Combat.pm
# Created Jan 2007
# Author  flogisto

package Combat;
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
    my $self  = $this->SUPER::new( $name ); 
    bless $self, $class ;

    $self->short( $name )
         ->desc( $name )
         ;
    
    return $self;
}

# ---------------------------------------------------------------------
sub cannot_get { 
    notify_fail("Un combat..." );
    return 1; 
}
