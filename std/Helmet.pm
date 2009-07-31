# Helmet.pm
# Created Nov 2006
# Author  flogisto

package Helmet;
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
    $self->armour_class( 1 );
    return $self;
}

# ---------------------------------------------------------------------
sub destroy {
    my $this  = shift;
    my $class = ref($this) || $this;

    if ( $this->wearing ) { 
        if (ref($this->environment) && $this->environment->isa('Living') ) {
            $this->environment->armour_helmet( 0 ) ;
        }
    }

    $this->SUPER::destroy; 
    return $this;
}

1;
