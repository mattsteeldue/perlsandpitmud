#!/usr/bin/perl

require 5.010;
use lib 'std';
use lib 'bin';
use strict;
use warnings;
use diagnostics;

use Engine;
use Mudmon;

# Arguments:
# ARGV[0]  is the configuration file
# ARGV[1]  may be the -f switch to start in two-treads mode.

my $threaded = ($ARGV[1] && $ARGV[1] eq '-f') ? 1 : 0;
my $kidpid = fork if $threaded;

if ( $kidpid ) {
    my $mon = new Mudmon( $ARGV[0], $kidpid ) || exit 1;
    $mon->run( $kidpid );
    $mon->destroy( $kidpid );
}
else {
    my $drv = new Engine( $ARGV[0] ) || exit 1;
    $drv->run();
    $drv->destroy() ;
}
1;

=pod

=head1 NAME

Starts Muddrv!
Use: Muddrv->new( $configfile )
arguments: config-file, timeout
With PerlIDE use param: bin/engine_ide.cfg

=head1 DESCRIPTION

---

=cut
