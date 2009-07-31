=pod

Uso: alias <verb> [ <command> ]
Consente di definire dei nuovi comandi formati da altri comandi già definiti. Tipicamente gli 'alias' si usano per creare delle abbreviazioni di altri comandi oppure per effettuare una sequenza di azioni racchiudendole in un unico comando. è consentito definire alias di altri alias. Per eliminare un alias si usa il comando 'unalias'. Per modificare un alias è necessario prima eliminarlo.
Il comando 'alias' dato da solo, mostra l'elenco degli attuali alias che l'utente ha definito. Il comando 'alias <verb>' mostra l'attuale definizione del <verb>, oppure un messaggio di errore. Il comando 'alias <verb> <comand>' crea effettivamente un nuovo alias, oppure dichiara che già esiste.
Esempio: alias ch channel rpg
Quando l'utente digita 'ch xxx yyy' è come se fosse stato digitato 'channel rpg xxx yyy'.
E' ammisibile usare @_ nella definizione dell'alias per individuare il resto della riga: p.es. 

alias chiedi say @_ ?



La possibilità di sostituzione è un po' limitata visto che sostituisce solo l'inizio della frase: in futuro magari si potrà fare una sostituzione per parti nel mezzo.

=cut

# ---------------------------------------------------------------------
sub cmd_alias { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift || 0;
    my $pl     = current_user();

    # no parameters: show current alias list
    unless( $what ) {
        tell_object( $pl, parse_std_msg('Actions_Alias_list') );
        while ( my ($key,$value) = each %{ $pl->alias() } ) { 
            tell_object( $pl, " $key -> $value\n" );
        }
        # anyway tell me the syntax (as ko)
        notify_fail( parse_std_msg('Actions_Alias_ko') );
        return -1;
    }

    # there is some words after the 'what'
    if ( scalar(@_) ) {
        # cannot define same alias before removing it first
        if ( exists( $pl->alias->{$what}) ) {
            notify_fail( parse_std_msg('Actions_Alias_already', $what) );
            return -1;
        }
        # definition
        else {
            $pl->inputline =~ m/$what\s+/ ;
            $pl->alias->{ $what } = $';
            $pl->inputline( '' );
            return 1;
        }
    }
    # show the current definition of 'what'
    elsif ( exists( $pl->alias->{$what}) ) {
        tell_object( $pl, "$what : ", $pl->alias->{$what}, "\n" );
    }
    # there is no such an alias
    else {    
        notify_fail( parse_std_msg('Actions_Alias_not_def', $what) );
        return -1;
    }

    return 1
}
