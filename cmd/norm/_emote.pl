=pod

Il comando "emote" senza argomenti presenta a video la lista delle "emote" e ognuna delle parole elencate rappresenta un comando "emote".
Quando si dà "emote eee" viene visualizzato il messaggio caratteristico di questa emote.
La maggior parte delle emote ammette un destinatario usando il comando "emote eee nome" si fa di 'nome' il destinatario della emote 'eee'. 
In alcuni casi è possibile specificare un avverbio di seguito al nome per modificare l'effetto finale. Ogni "emote" può essere data anche senza specificare il comando "emote" stesso, ma dando direttamente "eee nome".
Per ottenere l'elenco completo delle "emote" disponibili digitare "emote" da solo.

=cut

# ---------------------------------------------------------------------
sub cmd_emote { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift || 0;
    my $target = shift || 0;
    my $pl     = current_user();
    my $key    = 0;

    # without parameters gives current status
    unless( $what ) {
        tell_object( $pl, parse_std_msg('Actions_Emote_list') );
        my @ary = sort( keys( %{ getsetup('Emote') }) );
        tell_object( $pl, wrap_string( "@ary") );
        tell_object( $pl, "\n" );
        return 1;    
    }
    
    # in fact all emotes have its own verb.
    return daemon('emote')->do_emote( $what, $target );
}
