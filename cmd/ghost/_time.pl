=pod

Uso: time
Visualizza la data e l'ora del sistema.

=cut

# ---------------------------------------------------------------------
sub cmd_time { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();

    tell_object( $pl, time_to_str(time(), "WW DD-MM-YYYY HH.MI.SS") . "\n" );

    return 1
}
