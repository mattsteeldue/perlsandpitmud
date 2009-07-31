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
sub cmd_say { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();

    unless( scalar @_ ) {
        say( parse_std_msg( 'Actions_Say_less1'), ( $pl ) ) unless $pl->ghost();
        notify_fail( parse_std_msg( 'Actions_Say_less2') );
        return -1;
    }
    if ( $pl->ghost() ) {
        tell_object( $pl, parse_std_msg('Actions_Say_whisper1') ."'@_'\n" ) if current_user()->echo;
        say( parse_std_msg('Actions_Say_whisper2') . "'@_'\n", ( $pl ) );
    }
    else {
        if ( "@_" =~ /\?\s*$/ ) {
            tell_object( $pl, parse_std_msg('Actions_Say_ask1') . "'@_'\n" ) if current_user()->echo;
            say( parse_std_msg('Actions_Say_ask2') . "'@_'\n", ( $pl ) );
        }
        elsif ( "@_" =~ /!\s*$/ ) {
            tell_object( $pl, parse_std_msg('Actions_Say_exclaim1') . "'@_'\n" ) if current_user()->echo;
            say( parse_std_msg('Actions_Say_exclaim2') . "'@_'\n", ( $pl ) );
        }
        else {
            tell_object( $pl, parse_std_msg('Actions_Say_say1') . "'@_'\n" ) if current_user()->echo;
            say( parse_std_msg('Actions_Say_say2') . "'@_'\n", ( $pl ) );
        }
    }
    
    return 1;
}

