=pod

Uso: save
Salva la configurazione dell'utente.
Uscendo con 'quit' questo salvataggio avviene automaticamente.
Periodicamente viene forzato un 'autosave' per tutti gli utenti.

=cut

# ---------------------------------------------------------------------
sub cmd_save { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();

    if ($pl) {
        if ( save_user( $pl ) ) {
            tell_object( $pl, parse_std_msg('Actions_Save_saved'));
        }
        else {
            tell_object( $pl, parse_std_msg('Actions_Save_notsaved'));
            log_file( "cmd_norm_save.log", $pl->name, " wasn't saved.\n"); 
        }
    }
    else {
        tell_object( $pl, parse_std_msg('Actions_Save_notuser'));
        log_file( "cmd_norm_save.log", $pl->name, ". Non-user tryed to save itself\n"); 
    }
    
    return 1;
}

