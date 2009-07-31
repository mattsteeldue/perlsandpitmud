# patch_daemon.pl
# Created May 2007
# Author  flogisto

use Daemon;

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( 'patch_daemon' );
    bless $self, $class ;
    return $self;
}

# ---------------------------------------------------------------------
sub do_patch {
    my $me     = shift;
    #my $verb   = shift;
    my $pl     = current_user();
    my $this   = driver();

    # forza il ritorno da switch a chi ti stava switchando
    while ( my ($key,$user) = each %{$this->clients} ) { 
        next unless $user->switchee_user;
        $user->force_to( 'return' ) if $user->switchee_user eq $pl->name();
    }

    # ripristino dei livelli di statistica
    #call_other( getdaemon('level'), 'set_stats', $pl->level() );
    daemon('level','set_stats', $pl->level() );

    # eccessivo max-idle-time ridotto a 1800 sec, a meno che tu non sia wizard.
    $pl->maxidletime(1800) unless $pl->wizardhood();
    $pl->stand_prompt( '[' . $pl->cap_name . '] $' ) if '$ ' eq $pl->stand_prompt;
    
    # correzione ChannelColor in ColorChannel
    if ( exists $pl->{ChannelColor} ) {
        #while ( my ($chan,$color) = each %{$pl->{ChannelColor}} ) { 
        foreach my $chan ( keys %{$pl->{ChannelColor}} ) {
            my $color = $pl->{ChannelColor}->{$chan};
            $pl->color("ColorChannel_$chan",$color) unless $pl->color("ColorChannel_$chan");
        }
        delete $pl->{ChannelColor} ;
    }
    
    # Correzione Channels
    if ( exists $pl->{Channels} ) {
        #while ( my ($chan,$stato) = each %{$pl->{Channels}} ) { 
        foreach my $chan ( keys %{$pl->{Channels}} ) {
            my $stato = $pl->{Channels}->{$chan};
            $pl->channel_switch("Channel_$chan",$stato) unless $pl->channel_switch("Channel_$chan");
        }
        delete $pl->{Channels} ;
    }

    # display finali.
    $pl->force_to( 'channel' ) ;
    $pl->force_to( 'look' ) ;

    return 1;
}

