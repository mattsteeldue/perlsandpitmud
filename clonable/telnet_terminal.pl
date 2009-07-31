# money.pl
# Created Dec 2006
# Author  flogisto

use Object;
use IO::Socket;
use IO::Select;
use Net::hostent;
use Socket;

# ---------------------------------------------------------------------
sub telnet_selector {(@_)>1 ? ($_[0]->{TelnetSelector} = $_[1],$_[0]) : $_[0]->{TelnetSelector} } 
sub telnet_handle   {(@_)>1 ? ($_[0]->{TelnetHandle}   = $_[1],$_[0]) : $_[0]->{TelnetHandle}   } 
sub telnet_user     {(@_)>1 ? ($_[0]->{TelnetUser    } = $_[1],$_[0]) : $_[0]->{TelnetUser    } } 

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $user  = shift || 0;
    my $host  = shift || 'localhost';
    my $port  = shift || 23;
    my $self  = $this->SUPER::new( ); 
    $self->short( 'Terminal' );
    $self->desc( 'A telnet terminal' );

    my $handle = IO::Socket::INET->new(
        Proto    => 'tcp',
        PeerAddr => $host,
        PeerPort => $port,
        Blocking => 0 );
    my $sel = new IO::Select( $handle );
    $handle->autoflush(1);

    $self->telnet_selector( $sel );
    $self->telnet_handle( $handle );
    $self->telnet_user( $user );

    bless $self, $class;
    return $self;
}

# ---------------------------------------------------------------------
sub heart_beat  { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $pl      = $this->telnet_user();
    
    my @ready = $this->telnet_selector->can_read ( 0 ) ; 
    foreach my $client (@ready) {
        my $num = sysread $client, $out, 1024;
        write_other( $pl->client, $out );
    }
    
    return $this;
} 

# ---------------------------------------------------------------------
sub stdin  { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $handle  = $this->telnet_handle();
    print $handle @_;
    return $this;
}

# ---------------------------------------------------------------------
sub destroy {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $handle  = $this->telnet_handle();
    close $handle;
    $this->SUPER::destroy; 
}

