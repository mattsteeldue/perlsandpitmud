=pod

Uso: mail [ user | n [del] ]
Il comando 'mail' consente di esaminare la tua casella di posta, di leggere e spedire messaggi agli altri utenti (o a te stesso).
 - 'mail' da solo, offre la lista dei messaggi presenti; quelli ancora da leggere sono preceduti da un asterisco (*).
 - 'mail n' per leggere il messaggio indicato dal numero 'n'.
 - 'mail n del' per leggere e cancellare il messaggio.
 - 'mail user' per iniziare a scrivere un messaggio all'utente 'user'; inizia una fase di immissione dati che si puo concludere solo inserendo un puntino singolo a capo riga. Una volta dato il puntino su una riga vuota, viene proposta l'anteprima del messaggio e chiesta conferma per l'inoltro.

=cut

# ---------------------------------------------------------------------
sub cmd_mail { 
    my $me     = shift;
    my $verb   = shift;
    my $who    = shift || 0;
    my $pl     = current_user();
    my $envi   = $pl->environment ;
    my $office = $envi->query_property('postoffice') || 0;
    
    unless ( $office || $pl->wizardhood ) {
        notify_fail( parse_std_msg('Actions_Mail_no_office') );
        return 0 ;
    }
       
    return daemon('mail')->mail_list() unless $who ;
    return daemon('mail')->mail_read( $1, shift ) if $who =~ m/^(\d+)/ ;
    
    $who = lc($who);
    unless ( user_exists("$who") ) { 
        notify_fail( parse_std_msg('Actions_Mail_no_user', ucfirst($who) ) );
        return 0;
    }
    
    my $cl_who   = username_to_client( $who );
    my $pl_who   = client_to_user( $cl_who );
    
    write_client( parse_std_msg('Actions_Mail_username' ,ucfirst($who) ) );
    write_client( parse_std_msg('Actions_Mail_Subject','' ) ) ;  # prompt
    $pl->custom('MailAddressee', $who) ;
    $pl->custom('MailSubject', '');
    $pl->status('Mail'); 
    #$pl->input_to('mail_subject');
    daemon('mail')->mail_init();
    return 1;    
}

