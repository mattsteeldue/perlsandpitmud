=pod

Uso: help <voce>    per avere una pagina di help su una certa <voce>
     help voci      per avere la lista di tutte le voci di questo help

 com       come comunicare con gli altri utenti.
   *- annota          - consente di lasciare delle annotazioni.
   *- channel         - comunica sui canali di chat interna.
   *- di     - tell   - comunica con un singolo utente. 
   *- mail            - accede alla casella di posta 
   *- parla  - say    - comunica con ciscun personaggio della stanza. (')
   *- urla   - shout  - comunica con l'intero Mondo Emerso.
 combat    come combattere.
   *- attacca - attack  - per iniziare un combattimento
  +*- fuggi   - flee    - per fuggire
  +*- indossa - wear    - per indossare un pezzo di armatura
  +*- lontano - far     - per allontanarsi 
  +*- togli   - remove  - per togliere un pezzo di armatura
  +*- vicino  - near    - per avvicinarsi
 emote     uso delle "emotions" per aggiungere emozioni. (;)
 mondo     comandi per il set-up nel Mondo Emerso.
   *- aiuto  - help   - per ottenere le pagine di help.
   *- alias/unalias   - per creare "alias" di altri comandi
   *- ansi            - per attivare/disattivare la colorazione del testo
   *- brief           - stabilisce il grado di dettaglio delle descrizioni
   *- color           - comando per personalizzare i colori
   *- fine   - quit   - per terminare il collegamento.
   *- kal             - per informazioni di calendario del Mondo Emerso
   *- guarda - look   - comando standard per guardare una stanza
   *- news            - per vedere le "news"
   *- passwd          - cambia password dell'utente.
   *- prompt          - per cambiare il "prompt" di comando
   *- salva  - save   - salva la configurazione del personaggio.
   *- score           - score
   *- time            - per conoscere l'ora del sistema
  +*- users           - lista degli utenti collegati
   *- wrap            - per regolare il numero di colonne visualizzate
 mov       muoversi nel Mondo Emerso.
   *back
 obj       interazione con il Mondo Emerso.
   *- i       - inventory - lista degli oggetti che stai portando.
   *- esamina - examine   - per esaminare un oggetto disponibile
   *- lascia  - drop      - per lasciare un oggetto
   *- prendi  - get       - per prendere un oggetto
   *- dai     - give      - per dare un oggetto a qualcuno
  +*- party               - per consentire a qualcuno di seguirci
  +*- segui   - follow    - per seguire un utente o un mob
 razze     quali sono le razze.
 shop      comandi normalmente disponibili in uno "shop"
  +*- lista    per vedere la lista degli articoli disponibili
  +*- compra   per comprare un articolo in lista
  +*- vendi    per vendere un articolo al prezzo di mercato
  +*- valuta   per chiedere a quale prezzo riesci a rivendere
 terre     inquadramento delle terre del Mondo Emerso.

=cut

# ---------------------------------------------------------------------
sub cmd_help { 
    my $me     = shift;
    my $verb   = shift;
    my $voce   = shift || 'help';
    my $this   = driver();
    my $pl     = current_user();
    my $fil    = getdir('dirdochelp') . "${voce}.txt" ;

    unless( -f $fil ) { 
        $fil = getdir('dirdochelpnorm') . "${voce}.txt" ;
        unless( -f $fil ) { 
            notify_fail( parse_std_msg('Actions_Help_ko', $voce ) );
            return -1;
        }
    };
    tell_object( $pl, "$fil\n" ) if $voce && $pl->wizardhood();
    tell_object( $pl, parse_color("{BOLD}  -- $voce --\n" ) ) if $voce;

    cat_wrap( $fil );    

    tell_object( $pl, parse_color("{BOLD}  -- --\n" ) ) if $voce;
    return 1;
}

