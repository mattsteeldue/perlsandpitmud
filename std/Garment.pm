# Garment.pm
# Created Aug 2006
# Author  flogisto

package Garment;
use strict;
##use diagnostics;

use Commons;
use Object;

our @ISA = qw(Object);

=pod

=head1 DESCRIPTION

 Helmet, Boots, Gloves, Armour, Shield, Cloak, Ring, Amulet, Earring, Belt

=cut


# ---------------------------------------------------------------------
sub wearing         { (@_)>1 ? ($_[0]->{Wearing}       = $_[1],$_[0]) : $_[0]->{Wearing}     } 
sub armour_class    { (@_)>1 ? ($_[0]->{ArmourClass}   = $_[1],$_[0]) : $_[0]->{ArmourClass} } 

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $name  = shift || 0;
    my $self  = $this->SUPER::new( $name ); 
    bless $self, $class;

    $self->wearing     ( 0 )
         ->armour_class( 0 )
         ;

    return $self;
}

# ---------------------------------------------------------------------
sub destroy {
    my $this  = shift;
    my $class = ref($this) || $this;

    if ( $this->wearing ) {
        if (ref($this->environment) && $this->environment->isa('Living') ) {
            my $result = $this->move( $this->environment->environment );
            ###print "Garment::destroy. $result\n";
        }
    }

    $this->SUPER::destroy; 
    return $this;
}

# ---------------------------------------------------------------------
sub cannot_drop { 
    my $this  = shift;
    my $class = ref($this) || $this;
    if ( $this->wearing ) {
        notify_fail( parse_std_msg('NotifyWearing') ) ;
        return 1;
    }
    return 0; 
}

# ---------------------------------------------------------------------
sub done { 
    return $_[0]; 
}

# ---------------------------------------------------------------------
sub examine_object {
    my $this     = shift;
    my $class    = ref($this) || $this;
    my ($me,$ro,$ta) = $this->SUPER::examine_object( @_ ); 
    $me .= "\nClasse: " . $this->armour_class();
    return ($me, $ro, $ta);
}

1;
