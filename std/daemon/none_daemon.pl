# none_daemon.pl
# Created Nov 2007
# Author  flogisto

# ---------------------------------------------------------------------
use Daemon;

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( 'none_daemon' );
    bless $self, $class ;
    return $self;
}
