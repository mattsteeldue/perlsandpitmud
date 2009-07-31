=pod

Uso: wrap [n]
Definisce il numero di colonne da usare per la formattazione del testo.
Tipicamente wrap 72 offre una buona resa. Dato da solo visualizza l'attuale impostazione.

=cut

# ---------------------------------------------------------------------
sub cmd_wrap { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();
    my $what   = shift || 0;

    if ( $what < 32 || $what > 132 ) {
        notify_fail( parse_std_msg('Actions_Wrap_ko', $pl->wrap_col()) );
        return 0;
    }
    $pl->wrap_col( $what );
    tell_object( $pl, parse_std_msg('Actions_Wrap_ok', $what) );

    return 1
}
