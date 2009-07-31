=pod

Uso: teleport <oggetto> <destinazione|here>
Trasporta qualunque <oggetto> nella <destinazione> oppure nella stanza dove ti trovi se viene specificato 'here'. L'oggetto viene ricercato nel seguente ordine:
1. fra tutti gli oggetti registrati, l'oggetto dev'essere identificato anche dal numero di sequenza.
2. fra gli oggetti dell'inventario dell'utente chiamante.
3. fra gli oggetti della stanza dell'utente chiamante.

=cut

# ---------------------------------------------------------------------
sub cmd_teleport { 
    my $me      = shift;
    my $verb   = shift;
    my $who     = shift;
    my $where   = shift || 'here';
    my $pl      = current_user();

    # only interactive can
    return -1 unless $pl->isa('User');

    # only wizards can     
    return -1 unless $pl->wizardhood;

    unless( $who && $where ) {
        notify_fail( parse_std_msg('Actions_Teleport_ko'));
        return -1;
    }

    my $ob      = find_object($who);

    unless ( $ob ) {
        notify_fail( parse_std_msg('Actions_Teleport_who'));
        return -1;
    }

    $where = $pl->environment() if $where eq 'here';
    
    my $result = $ob->move( $where );
    if ( $result > 0 ) {
        my $msg; 
        my $prev = find_object($ob->previous_room);
        my $room = $ob->environment;
        my $shrt = $ob->short;
        $pl->emote_target( $ob );

        $msg = parse_std_msg('Actions_Teleport_ok1', $shrt);
        tell_room( $prev, $msg, $ob );

        $msg = parse_std_msg('Actions_Teleport_ok2');
        tell_object( $ob, $msg);
 
        $msg = parse_std_msg('Actions_Teleport_ok3',$shrt);
        tell_room( $room, $msg, $ob );
        
        $ob->force_to( 'look');
        return 1;
    }
    else {
        notify_fail( parse_std_msg('Actions_Teleport_fail', $result));
        return -1;
    }
}
