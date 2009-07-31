=pod

Uso: snoop [<username> [why]]
Spia tutto quello che dice, vede e fa l'utente indicato (se può essere spiato). E' possibile aggiungere una nota sul motivo dello snooping in modo che l'amministratore sia un po' più indulgente. Il comando viene tracciato su un log e la nota viene scritta di seguito nel log stesso, quindi attenzione. Per interrompere lo 'snooping' dare 'snoop' senza parametri.
è possibile spiare anche un 'mob' per fini di programmazione e bugfix. Vedi anche il comando 'forcesnoop'.

=cut

# ---------------------------------------------------------------------
sub cmd_snoop { 
    my $me     = shift;
    my $verb   = shift;
    my $who    = shift; $who = lc($who);
    my @said   = @_;
    my $this   = driver();
    my $pl     = current_user();
    my $ob     = find_living( $who );

    # only interactive can
    return -1 unless $pl->isa('User');

    # only wizards can     
    return -1 unless $pl->wizardhood;

    # without argument
    unless ( $who ) {
        # you are snooping, then stop snooping.
        if ( $pl->snoopee() ) {
            $ob = find_living( $pl->snoopee_name() );
            if ( ref($ob) ) {
                remove_from_array( $ob->snooper, $pl );
            }
            $who = $pl->snoopee_name();
            tell_object( $pl, parse_std_msg('Actions_Snoop_stop', ucfirst($who) )) if $pl->echo();
            $pl->snoopee( 0 );
            return 1;
        }
        else {
            notify_fail( parse_std_msg('Actions_Snoop_ko'));
            return -1;
        }
    }
    else {
        if ( $pl->snoopee() ) {
            $who = $pl->snoopee_name();
            notify_fail( parse_std_msg('Actions_Snoop_already', ucfirst($who) ));
            return -1;
        }
    }        
    
    unless ( ref($ob) ) {
        notify_fail( parse_std_msg('Actions_Snoop_nowho', ucfirst($who) ));
        return -1;
    }

    if ( $ob == $pl ) {
        notify_fail( parse_std_msg('Actions_Snoop_self'));
        return -1;
    }
    
    unless ( $ob->can_be_snooped ) {
        notify_fail( parse_std_msg('Actions_Snoop_cannot',$ob->short));
        return -1;
    }
    
    push @{$ob->snooper}, $pl;
    $pl->snoopee_name( $who );
    $pl->snoopee( $ob );

    tell_object( $pl, parse_std_msg('Actions_Snoop_ok', ucfirst($who) )) if $pl->echo();
    log_file "snoop.log", $pl->name, " snoops $who @said";

    return 1;    
}

sub stop_snooping {
    my $who      = shift; 
    my $this     = driver();
    my @said     = @_;
    my $pl       = current_user();
    my $ob       = find_object( $who );

    #delete $ob->snooper->{ $pl->name } if exists $ob->snooper->{ $pl->name };
    remove_from_array( $ob->snooper, $pl );
    #my $i = pos_array( $ob->snooper, $pl );
    #splice @{$ob->snooper}, $i, 1 unless $i < 0;
    tell_object( $pl, parse_std_msg('Actions_Snoop_stop', ucfirst($who) )) if $pl->echo();
    $pl->snoopee( 0 );
}
