=pod

Uso: source [filename]
Mostra il sorgente della stanza.

=cut

# ---------------------------------------------------------------------
sub cmd_source { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();
    my $room   = $pl->environment;
    
    return -1 unless ref($room);
    
    cat_wrap($room->module) ? 1 : -1;
    
}

