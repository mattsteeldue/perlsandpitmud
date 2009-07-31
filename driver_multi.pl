#!/usr/bin/perl

require 5.010;
use lib 'std';
use lib 'bin';
use strict;
use warnings;
use diagnostics;
use Muddrv;
use Mudmon;

# Arguments:
# ARGV[0]  is the configuration file
# ARGV[1]  may be the -f switch to start in two-treads mode.

my @cfglist = @ARGV;
my $threaded = ($cfglist[$#cfglist] eq '-f') ? 1 : 0;
pop @cfglist if $threaded;

foreach my $cfg (@cfglist) {

    my $mud = fork;
    if ( $mud ) {
        print "$mud\n";
    }
    else {
        
        my $kidpid = fork if $threaded;
        
        if ( $kidpid ) {
            my $mon = new Mudmon( $cfg, $kidpid ) ;
            $mon->run( $kidpid );
            $mon->destroy( $kidpid );
        }
        else {
            my $drv = new Muddrv( $cfg ) || exit 1;
            $drv->run();
            $drv->destroy() ;
        }
    }
    
}

while ( -1 != wait ) {
    print "wait\n";
    sleep 1;
};

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
