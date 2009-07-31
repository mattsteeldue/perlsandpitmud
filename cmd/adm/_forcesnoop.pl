=pod

Uso: forcesnoop <commands...>
Questo comando è legato al comando snoop. Una volta applicato il comando snoop verso un utente o un mob è possibile forzare il mob con questo comando di abbreviazione che equivale al comando 'force <mob> <commands...>' dove all'oggetto <mob> è stato applicato in precedenza il comando 'snoop <mob>'.

=cut

# ---------------------------------------------------------------------
sub cmd_forcesnoop { 
    my $me     = shift;
    my $verb   = shift;
    my @said   = @_;
    my $this   = driver();
    my $pl     = current_user();

    # only interactive can
    return -1 unless $pl->isa('User');

    # only wizards can     
    return -1 unless $pl->wizardhood;
    
    unless ( ref($pl->snoopee()) ) {
        notify_fail( parse_std_msg('Actions_Forcesnoop_not'));
        return -1;
    }
    
    unless ( scalar @said ) {
        notify_fail( parse_std_msg('Actions_Forcesnoop_ko'));
        return -1;
    }
    
    my $ob = $pl->snoopee();
    unless ( $ob->force_to( "@said" ) ) {
        notify_fail( $ob->error_message() );
        return -1;
    }
    
    return 1;
}

