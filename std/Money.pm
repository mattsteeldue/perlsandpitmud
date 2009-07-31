# Money.pm
# Created Dec 2006
# Author  flogisto

package Money;
use strict;
##use diagnostics;

use Commons;
use Object;

our @ISA = qw(Object);

=pod

=cut

# ---------------------------------------------------------------------
sub amount          { (@_)>1 ? ($_[0]->{Amount}        = $_[1],$_[0]) : $_[0]->{Amount}         } 

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $param = shift || 1;
    my $self  = $this->SUPER::new; 

    $self->bulk( 0 )            # lt
         ->weight( 0 )          # kg
         
         ->amount( $param < 1 ? 1 : $param ) 
         
         ->{std_dinar_JustCloned} = 2
         ;

    bless $self, $class;
    return $self;
}

# ---------------------------------------------------------------------
# function called during trans_object_in.
# param is the "environment", i.e. the either the user or the room.
sub init {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $env = shift || return $this;
    my $pl = current_user(); 

    $this->{std_dinar_JustCloned} -= 1 if $this->{std_dinar_JustCloned} ;
  
    if ( ref($env) && $env->isa('Living' ) ) {
        return $this if $this->{std_dinar_JustCloned} ;
        $env->money( $env->money() + $this->amount() );
        $this->destroy() ;
        return $this;
    }

    # if some Money is dropped here, then merge with any alredy here 
    if ( ref($env) && $env->isa('Room' ) ) {
        my $money = find_object( $this->name, $env );
        if ( ref($money) && $money->isa('Money') && $money != $this ) {
            #print $this->name, ", ", $env->name, ", ";
            #print $this->amount, ", ", $money->amount, "\n" ;
            $money->amount( $this->amount + $money->amount);
            $this->destroy;
        }
    }
    return $this;
}

1;
