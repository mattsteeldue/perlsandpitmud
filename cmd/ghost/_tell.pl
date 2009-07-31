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
sub cmd_tell { 
    my $me     = shift;
    my $verb   = shift;
    my $who    = shift; $who = lc($who);
    my $this   = driver();
    my $pl     = current_user();

    my $cl_who = username_to_client( $who );
    my $pl_who = client_to_user( $cl_who );

    unless ( $who ) {
        notify_fail( parse_std_msg('Actions_Tell_ko') );
        return -1;
    }        

    if ( $pl->level() <= getsetup('Level2Tell') &&
         $pl_who->environment != $pl->environment) {
        notify_fail( parse_std_msg('Actions_Tell_level') );
        return -1;
    }
    
    if ( ref($cl_who) && $cl_who == current_client() ) {
        notify_fail( parse_std_msg('Actions_Tell_self') );
        return -1;
    }

    if ( ref($cl_who) && $pl_who->status ne 'Logon' ) {    
        unless ( scalar @_ ) {
            notify_fail( parse_std_msg('Actions_Tell_nowhat', ucfirst($who) ));
            return -1;
        }        
        if ( "@_" =~ /\?\s*$/ ) {
            tell_object( $pl, parse_std_msg('Actions_Tell_ask1', ucfirst($who) ). "'@_'\n" ) if $pl->echo();
            tell_object( $pl_who, parse_std_msg('Actions_Tell_ask2') . "'@_'\n" );  
        }
        else {
            tell_object( $pl, parse_std_msg('Actions_Tell_say1', ucfirst($who) ). "'@_'\n" ) if $pl->echo();
            tell_object( $pl_who, parse_std_msg('Actions_Tell_say2') . "'@_'\n" );  
        }
        return 1;    
    }
    else {
        if ( user_exists("$who") ) { 
            notify_fail( parse_std_msg('Actions_Tell_notpresent', ucfirst($who) ) );
        }
        else {
            notify_fail( parse_std_msg('Actions_Tell_nosuch', ucfirst($who)) );
        }
        return -1;
    }
}

