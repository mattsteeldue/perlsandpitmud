# Mudmon.pl
# Created Aug 2008
# Author  flogisto

package Mudmon;

=pod

=head1 NAME

Mudmon - Multi User Dungeon Monitor

=head1 DESCRIPTION

This is the mud driver monitor. It monitors the driver (Muddrv)


=head2 Members

lockfile        internal constant
constants       custom setup constants
dir             directory structures
new             called once at startup: builds up the controller
run             main loop.
destroy         shut-down is complete.

=cut

use strict; # qw(subs vars refs);
#use warnings;
##use diagnostics;

use Commons qw( log_file restore_config basedepth basefilename driver );

# ---------------------------------------------------------------------
sub lockfile       { basefilename($_[0]->{ConfigFile}) . ".lock.txt" }
sub constants      { {} }
sub dir            { $_[0]->{Dir} }

# ---------------------------------------------------------------------
# ::new( configfilename );
sub new {
    my $this  = shift; 
    my $class = ref($this) || $this;
    my $configfile = shift || 'cfg/world.cfg'; # default
    my $pid   = shift || 0;
    my $temp = { };
    my $self = { }; 
    bless $self, $class;
    driver( $self ); # stores muddriver in global variable.
    restore_config( $temp, $configfile ) || die "Can't read $configfile: $!.\n" ;
    foreach my $key (keys %$temp) {
        $self->{$key} = $temp->{$key} if $key =~ /^Monitor/ or $key =~ /^Dir/;
    }
    $self->{ConfigFile} = $configfile;
    log_file( 'muddrv.log',  "Start ($$)." );
    return $self;
}

# ---------------------------------------------------------------------
# monitor run.
sub run {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $pid     = shift || 0;
    my $time_transient = $this->{MonitorTransientTime} || 5;
    my $time_polling   = $this->{MonitorPollingTime}   || 2;
    my $time_tolerance = $this->{MonitorToleranceTime} || 5;
    my $tolerance_hits = $this->{MonitorToleranceHits} || 4;
    sleep $time_transient; # wait for child to complete startup.
    my $count = 0;
    while ( 1 ) {
        my $now = time();
        my $tt = $this->read_lock_file() || 0;
        $count = ( $tt+$time_tolerance < $now ) ? $count+1 : 0 ;
        log_file( 'muddrv.log', "tolerance hit #$count." ) if $count;
        if ( $count > $tolerance_hits ) {
            last if $tt < 0; # child stopped normally.
            log_file( 'muddrv.log', "**** Parent: $now - $tt: delay too long!" );
            kill("TERM", $pid);
            sleep $time_polling;
            last;
        }
        sleep $time_polling;
    }
    log_file( 'muddrv.log', "**** Parent ($$) is stopping.");
}
    
# ---------------------------------------------------------------------
# ::destroy()
sub destroy {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $pid   = shift || 0;
    my $file = $this->lockfile;
    unlink "$file" if basedepth("$file") > 0 ;
    log_file( 'muddrv.log',  "Stop ($$)." );
}

# ---------------------------------------------------------------------
# reads the "lock file" returns the number.
# used by MudMon to check itself Engine.
sub read_lock_file {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $file = $this->lockfile;
    return 0 unless basedepth("$file") > 0 ;
    if ( open (LOCK, "$file") ) {
        my ($tt,$ts) = split /\t/, <LOCK>;
        close LOCK;
        return $tt;
    }
    return -1; # lock file not found (or just created): driver not running
}

1;


