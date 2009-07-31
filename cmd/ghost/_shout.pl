=pod

Per comunicare hai a disposizione i seguenti comandi, alcuni comandi sono disponibili in due lingue, italiano e inglese.

- di     - tell   - comunica con un singolo utente.
- parla  - say    - comunica con ciscun personaggio della stanza.
- urla   - shout  - comunica con l'intero Mondo Emerso.
- mail            - accede alla casella di posta 
- annota          - consente di lasciare delle annotazioni.
- channel         - comunica sui canali di chat interna.

Un apostrofo (') all'inizio della linea, equivale a "parla".
Vedi anche "emotes". Oltre a comunicare verbalmente è disponibile una grande quantità di "emote" cioè di atteggiamenti, espressioni del viso, rumori, etc. che consentono di interagire sotto numerosi punti di vista.
Un punto-e-virgola (;) all'inizio della linea, equivale a "emote".

=cut

# ---------------------------------------------------------------------
sub cmd_shout { 
    my $me    = shift;
    my $verb  = shift;
    my $pl    = current_user();
    my $this   = driver();
    
    if ( $pl->level() < getsetup('Level2Shout') ) {
        notify_fail( parse_std_msg('Actions_Shout_level'));
        return -1;
    }
    
    if ( $pl->silenced() ) {
        notify_fail( parse_std_msg('Actions_Shout_silence', $pl->silenced_by ) );
        return -1;
    }

    unless( scalar @_ ) {
        notify_fail( parse_std_msg('Actions_Shout_none'));
        return -1;
    }

    if ( $pl->ghost() ) {
        notify_fail( parse_std_msg('NotifyGhost') ) ;
        return -1;
    }

    # this uses driver->clients.
    while ( my ($key,$user) = each %{$this->clients} ) { 
        if ( ref($user) && $user->isa('User') && ref($user->client()) ) {
            my $cl = $user->client;
            if ($cl == current_client()) {
                tell_object( $pl, parse_std_msg('Actions_Shout_shout1') ."'@_'\n" ) if $pl->echo() ;
                tell_object( $pl, parse_std_msg('Actions_Shout_shout2') ) if $pl->echo() ;
            }
            else {
                if ( $cl && $user->status ne 'Logon' ) {    
                    tell_object( $user, parse_std_msg('Actions_Shout_shout3') . "'@_'\n" ) unless $user->earmuffed; 
                }
            }
        }
    }
    return 1;    
}
    
