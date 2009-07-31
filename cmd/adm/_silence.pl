=pod

Uso: silence <username>
Impedisce ad un utente di usare "shout".
Per sbloccarlo devi ridare silence <username>.

=cut

# ---------------------------------------------------------------------
sub cmd_silence { 
    my $me     = shift;
    my $verb   = shift;
    my $who      = shift; 

    $who = lc($who);

    my $this     = driver();
    my $pl       = current_user();
    my $ob       = find_object( $who );

    # only interactive can
    return -1 unless $pl->isa('User');

    # only wizards can     
    return -1 unless $pl->wizardhood;

    unless ( $who ) { 
        notify_fail( parse_std_msg('Actions_Silence_ko' ) );
        return -1; 
    }

    if ( $ob == $pl ) {
        notify_fail( parse_std_msg('Actions_Silence_self' ) );
        return -1;
    }

    if ( $ob && $ob->wizardhood() ) {
        notify_fail( parse_std_msg('Actions_Silence_online' ) );
        return -1;
    }        

    $pl->emote_target( $ob );
    if ( $ob->silenced) {
        tell_object( $ob, parse_std_msg('Actions_Silence_stop',$pl->short));
        $ob->silenced( 0 )
    }
    else {
        tell_object( $ob, parse_std_msg('Actions_Silence_silence',$pl->short));
        $ob->silenced( 1 )
    }

    $ob->silenced_by( $pl->short );
    save_user($ob);
    return 1; 
}
