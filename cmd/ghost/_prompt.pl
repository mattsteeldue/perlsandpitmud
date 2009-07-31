=pod

Uso: prompt [testo]
Definisce il testo da visualizzare come "prompt" all'inizio di ogni nuova riga, per indicare che il sistema è pronto per accettare un nuovo comando. Alla creazione del personaggio il prompt è il segno "$".

=cut

# ---------------------------------------------------------------------
sub cmd_prompt { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();
    
    if (@_) { 
        my $arg = $pl->inputline;
        $arg =~ s/$verb //;
        $pl->stand_prompt( $arg ); 
    } 
    else    { 
        tell_object( $pl, parse_std_msg('Actions_Prompt_is', $pl->stand_prompt )); 
    };
    return 1;
}
