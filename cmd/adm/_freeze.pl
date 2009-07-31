=pod

Uso: freeze <username>
Blocca la funzionalità di un utente.
Per sbloccarlo devi ridare freeze <username>.

=cut

# ---------------------------------------------------------------------
sub cmd_freeze { 
    my $me     = shift;
    my $verb   = shift;
    my $who      = shift; 

    $who = lc($who);

    my $this     = driver();
    my $pl       = current_user();
    my $ob       = find_user( $who ) ;

    # only interactive can
    return -1 unless $pl->isa('User');

    # only wizards can     
    return -1 unless $pl->wizardhood;

    unless ( $who ) { 
        my @output = ();
        while ( my ($k,$v) = each %{$this->user_names} ) { 
            $ob = $this->objects->{ $k } ;
            push @output, $ob->short . "\n" if $ob->frozen eq $pl->short;
        }
        tell_object( $pl, sort @output );
        notify_fail( parse_std_msg('Actions_Freeze_ko'));
        return -1; 
    }

    unless ( ref($ob) ) { 
        notify_fail( parse_std_msg('Actions_Freeze_no', ucfirst($who)) );
        return -1; 
    }

    if ( $ob == $pl ) {
        notify_fail( parse_std_msg('Actions_Freeze_self'));
        return -1;
    }

    if ( $ob && $ob->wizardhood() ) {
        notify_fail( parse_std_msg('Actions_Freeze_online'));
        return -1;
    }        

    $pl->emote_target( $ob );
    if ( $ob->query_input_to !~ /frozen/ ) {
        $ob->frozen( $pl->short );
        $ob->frozen_by( $pl->short );    
        tell_object( $ob, parse_std_msg('Actions_Freeze_frozen', $pl->short) );
        tell_object( $pl, parse_std_msg('Actions_Freeze_freeze', ucfirst($who) ) );
        daemon('actions')->cmd_freeze( $ob );
        ##$ob->input_to( 'frozen' ) ;
    }
    else {
        tell_object( $ob, parse_std_msg('Actions_Freeze_defrozen', $pl->short) );
        tell_object( $pl, parse_std_msg('Actions_Freeze_defreeze', ucfirst($who) ) );
        $ob->frozen( '' );
        $ob->input_to( 0 ) ;
    }
    
    save_user($ob);
    return 1; 
}

