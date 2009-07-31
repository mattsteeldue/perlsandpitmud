# death_daemon.pl
# Created Jan 2008
# Author  flogisto

use Daemon;

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( 'death_daemon' );
    bless $self, $class ;

    return $self;
}

