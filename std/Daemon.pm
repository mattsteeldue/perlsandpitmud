# Daemon.pm
# Created Jan 2007
# Author  flogisto

package Daemon;
use strict;
##use diagnostics;

use Commons;
use Object;
our @ISA = qw(Object);

=pod

=head1 DESCRIPTION

A daemon is a collection of functionality.
Any function can be called using someghint like:  daemon('patch','do_patch');

=cut
# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $name  = shift;
    my $self  = $this->SUPER::new( $name ); 
    bless $self, $class ;

    $self->set_property('unique')
         ->short( $name ) 
         ->desc( $name ) 
         ->go_to_daemon_room()
         ;

    return $self;
}

# ---------------------------------------------------------------------
sub cannot_get { 
    notify_fail("Daemon..." );
    return 1; 
}

# ---------------------------------------------------------------------
my $daemon_room;
sub go_to_daemon_room {
    my $this  = shift;
    my $class = ref($this) || $this;
    # At restart check if the daemon rests where it should
    #$daemon_room = find_object( getsetup('DaemonRoom') ) unless ref($daemon_room);
    $daemon_room = find_object( driver()->daemon_room() ) unless ref($daemon_room);
    if ( $daemon_room && $this->environment != $daemon_room ) {
        $this->move( $daemon_room );
    }
    return $this;
}


# ---------------------------------------------------------------------
sub restart {    
    my $this  = shift;
    my $class = ref($this) || $this;
    $this->SUPER::restart(); 
    $this->go_to_daemon_room();
    return $this;
}

1;
