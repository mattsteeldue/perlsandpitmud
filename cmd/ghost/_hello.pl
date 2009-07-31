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
# example
sub cmd_hello { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();
    my $this   = driver();
    if ( scalar @_ ) { 
        say( parse_std_msg('Actions_cmd_hello', $_[0] ) );  
        return 1; 
    }
    notify_fail( parse_std_msg('Actions_cmd_hello_ko') );
    return -1;
}

