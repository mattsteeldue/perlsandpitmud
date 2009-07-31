# Weapon.pm
# Created Aug 2006
# Author  flogisto

package Weapon;
use strict;
##use diagnostics;

use Commons;
use Object;

our @ISA = qw(Object);

=pod

=head1 DESCRIPTION

 Sword, Axe, Whip

=cut

# ---------------------------------------------------------------------
sub weapon_type     {(@_)>1 ? ($_[0]->{WeaponType}     = $_[1],$_[0]) : $_[0]->{WeaponType}     } 
sub weapon_class    {(@_)>1 ? ($_[0]->{WeaponClass}    = $_[1],$_[0]) : $_[0]->{WeaponClass}    } 
sub wielding        {(@_)>1 ? ($_[0]->{Wielding}       = $_[1],$_[0]) : $_[0]->{Wielding}       } 

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $name  = shift || 0;
    my $self  = $this->SUPER::new( $name ); 
    bless $self, $class;

    $self->weapon_type( 'weapon' )
         ->weapon_class( 0 )
         ;

    return $self;
}

# ---------------------------------------------------------------------
sub destroy {
    my $this  = shift;
    my $class = ref($this) || $this;

    $this->SUPER::destroy; 
    return $this;
}

# ---------------------------------------------------------------------
sub cannot_drop { 
    my $this  = shift;
    my $class = ref($this) || $this;
    if ( $this->wielding ) {
        notify_fail( std_msg('NotifyWielding') ) ;
        return 1;
    }
    return 0; 
}
1;

