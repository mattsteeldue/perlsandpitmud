=pod

Uso: update [room|messages|emotes|constants|actions]
Senza argomenti aggiorna la stanza da dove viene invocato, ricaricando in memoria il file sorgente così come eventualmente modificato. Tutti gli oggetti, tutti i mostri e tutti i personaggi vengono "salvati" per un attimo nel "vuoto" e immediatemente ripristinati. 
Se il file sorgente viene caricato correttamente, sembrerà che non sia accaduto nulla, altrimenti, tutti si ritroveranno a fissare il vuoto.
Se viene specificato un parametro consente di aggiornare i messaggi, le emotes e le azioni rileggendo i rispettivi file di configurazione (messages.cfg, emotes.cfg, actions.cfg). 

=cut

# ---------------------------------------------------------------------
sub cmd_update { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift || '';

    my $pl     = current_user();
    my $this   = driver();
    my $here   = $pl->environment();
    my $final  = basename($here->module);
    my $prev   = {} ; # save previous room.

    unless ( 
         $what eq 'room' or
         $what eq '' or
         $what eq 'messages' or
         $what eq 'emotes' or  
         $what eq 'constants' or
         $what eq 'actions' ) {
        notify_fail( parse_std_msg('Actions_Update_room_ko'));
        return -1; 
    }


    # with parameter, reload everything as "config"
    if ( $what eq 'messages' or
         $what eq 'emotes' or  
         $what eq 'constants' or
         $what eq 'actions' ) {

        # set-up an action for each emote: warns for duplications.    
        foreach my $verb (keys %{ getsetup('Emote') } ) { 
            if ( exists getsetup('Action')->{$verb} ) {
                delete getsetup('Action')->{$verb};
            }
        };

        $this->config();
        tell_object( $pl, parse_std_msg('Actions_Update_updated',$what));
        return 1;
    }

    # without parameters, update the room you are.
    my @people;
    foreach my $object ( @{$here->inventory} ) {
        push @people, $object ;
        $prev->{ $object->keyname() } = $object->previous_room();
        $object->move( the_void() );
    }

    $here->destroy();
    my $okload = load_module( $final, 1 );

    foreach my $object ( @people ) {
        $object->move( $final ) if $okload > 0 && !$object->query_property('cloned_unique');
        $object->previous_room( $prev->{ $object->keyname() } );
        call_out( 1, $me, 'force_look', $object ) if $object->isa('User');
    }

    tell_object( $pl, parse_std_msg('Actions_Update_room') ); 
    
    return 1;
}

sub force_look {
    my $me       = shift;
    my $object   = shift;
    $object->force_to('look') if ref($object);
}

