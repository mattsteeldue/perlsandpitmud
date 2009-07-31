=pod

Uso: channel <canale> [ /on | /off | /rev | /color c |testo ]
Il comando 'channel' consente di comunicare su determinati canali specifici.
è consigliabile di usare opportuni "alias" per usare agevolmente i vari canali. Per esempio il canale "tag" è stato definito come alias: in questo modo puoi digitare solo "tag xxxx" anziché "channel tag xxxx".

=cut

# ---------------------------------------------------------------------
sub cmd_channel { 
    my $me     = shift;
    #my $verb   = shift;
    return daemon('channel')->cmd_channel( @_ ); 
    return 1;
}

