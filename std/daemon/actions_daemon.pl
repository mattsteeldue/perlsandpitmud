# actions_daemon.pl
# Created May 2007
# Author  flogisto

# sometime it is useful to have a command to be handled by a static object 
# like this.

use Daemon;

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( 'actions_daemon' );
    bless $self, $class ;
    return $self;
}

# ---------------------------------------------------------------------
# wizard only
sub cmd_actions {
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();
    my $this   = driver();

    my @ary = sort( keys( %{ getsetup('Action') }) );
    tell_object( $pl, "@ary\n" );
    return 1;
}

# ---------------------------------------------------------------------
sub cmd_freeze {
    my $me = shift;
    my $ob = shift;
    $ob->input_to( 'frozen' ) ;    
}

sub frozen {
    my $reply    = wipe_bs(shift);
    my $this     = driver();
    my $pl       = current_user();

    if ( $reply =~ m/^tell (.*)/ ) { do_command( 'tell', $1 ) }
    elsif ( $reply =~ m/^quit/ )   { do_command( 'quit' ) }
    elsif ( $reply =~ m/^fine/ )   { do_command( 'fine' ) }
    else {                           do_command( 'say', $reply ) }
    tell_object( $pl, parse_std_msg('Actions_Freeze_msg', $pl->frozen_by ) );
    $pl->input_to( 'frozen' ) ;
}

# ---------------------------------------------------------------------
sub cmd_telnet {
    my $me = shift;
    my $ob = shift;
    $ob->input_to( 'telnet' ) ;    
}

sub telnet {
    my $reply    = wipe_bs(shift);
    my $this     = driver();
    my $pl       = current_user();

    if ( $reply =~ m/^tell (.*)/ ) { do_command( 'tell', $1 ) }
    elsif ( $reply =~ m/^quit/ )   { do_command( 'quit' ) }
    elsif ( $reply =~ m/^fine/ )   { do_command( 'fine' ) }
    else {                           do_command( 'say', $reply ) }
    tell_object( $pl, parse_std_msg('Actions_Freeze_msg', $pl->frozen_by ) );
    $pl->input_to( 'telnet' ) ;
}

