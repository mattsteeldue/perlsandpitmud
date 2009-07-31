=pod

Uso: stat
Senza parametri mostra il nome della stanza.
In futuro altre caratteristiche...  

=cut

# ---------------------------------------------------------------------
sub cmd_stat { 
    
    return 0;
    
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift;
    my $pl     = current_user();
    my $ob     = 0;

    ###print "here\n";

    $ob = ($what ? find_object( $what ) : $pl->environment );
    return 0 unless $ob;
    tell_object( $pl, 'Name:     ', $ob->name );
    tell_object( $pl, '  - Light:     ', $ob->light, "\n" );
    tell_object( $pl, 'Bulk:     ', $ob->bulk );
    tell_object( $pl, '  - Capacity: ', $ob->used_capacity, '/', $ob->capacity, "\n" );
    tell_object( $pl, 'Weight:   ', $ob->weight );
    tell_object( $pl, '  - Payload:  ', $ob->used_payload, '/', $ob->payload,"\n" );
    tell_object( $pl, 'Money:     ', $ob->money, "\n" ) if $ob->isa('Living');;
    return 1; 
}
