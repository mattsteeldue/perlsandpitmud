=pod

Uso: annota [ testo ]
Il comando 'annota' consente di lasciare una annotazione nel luogo dove ti trovi mentre esegui l'annotazione. 
Le annotazioni vengono memorizzate in modo permanente ma sono visibili solo agli utenti che hanno un livello uguale o maggiore di chi ha lasciato l'annotazione.
Ciascun utente potrà lasciare la sua "traccia" oppure suggerire miglioramenti e segnalare errori.
Gli amministratori esaminano periodicamente le annotazioni che verranno recepite e rimosse. 
Ogni abuso verrà perseguito e punito.

=cut

# ---------------------------------------------------------------------
# adds an annotation
sub cmd_annota { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = "@_";
    my $pl     = current_user();
    my $this   = driver();
    my $room   = basename($pl->environment->module);
    my $dt     = time_to_str( time(), 'YYMMDD.HHMISS' );
    
    if ( $pl->level < 2 ) {
        notify_fail( parse_std_msg('Actions_Annota_ko2') );
        return -1;
    }
    
    my $msg    = daemon('room_desc')->get_total_annotation( $room );  
    tell_object( $pl, "$msg" . ($msg ? "\n" : "") ) if ( $pl->wizardhood );

    unless( $what ) {
        notify_fail( parse_std_msg('Actions_Annota_ko') );
        return -1;
    }

    if( $pl->wizardhood && $what =~ /^del/i ) {
        write_client( parse_std_msg('Actions_Annota_askdel',std_msg('yes'),std_msg('no')
) );
        $pl->input_to('annota_ask_delete');
        return 1;
    }

    return daemon('room_desc')->add_annotation( $room, $what ) ;
}

# ---------------------------------------------------------------------
sub annota_ask_delete {
    my $reply    = wipe_bs(shift);
    my $pl     = current_user();
    my $this   = driver();
    my $room   = basename($pl->environment->module);

    my $match    = std_msg('yes');
    if ( $reply =~ m/^\s*$match\s*/i ) {
    #if ( $reply =~ m/^\s*S\s*/i ) {
        daemon('room_desc')->delete_annotation( $room );
    }
    return 1
}

