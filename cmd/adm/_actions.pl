=pod

Uso: actions
Mostra l'elenco di tutti i comandi disponibili in questo momento. La lista risulta in ordine alfabetico, tutta impaccata. 

=cut

# ---------------------------------------------------------------------
sub cmd_actions { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift;
    
    # E' possibile anche questo...
    #std::Actions::cmd_actions( $verb, $what );
    # Oppure questo.
    daemon('actions')->cmd_actions( $verb, $what );

    #my @ary = sort( keys( %{ getsetup('Action') }) );
    #tell_object( $pl, "@ary\n" );

    return 1;
}
