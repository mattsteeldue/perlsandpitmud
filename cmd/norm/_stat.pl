=pod

Uso: stat
Senza parametri mostra il nome della stanza.
In futuro altre caratteristiche...  

=cut

# ---------------------------------------------------------------------
sub cmd_stat { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();
    my $who    = shift || $pl->name; $who = lc($who);
    my $this   = driver();
    my $ob = ($who ? find_living( $who ) : $pl );

    unless ( ref($ob) ) { 
        notify_fail( parse_std_msg('Actions_Stat_no_user', ucfirst($who) ) );
        return 0;
    }

    ###print $ob->name if ref($ob);
    
    unless ( $pl->environment == $ob->environment ) {
        notify_fail( parse_std_msg('Actions_Stat_ko', $who) );
        return -1 unless $pl->wizardhood();
    }
    

    my $fmt = <<'END';
    
    Nome:  @<<<<<<<<<<<<<<<<<<<<<<<<   Level: @<<    
    Razza: @<<<<<<<<<<<<<<<<<<<<<<<<   Punti ferita: @>> / @<<
    Terra: @<<<<<<<<<<<<<<<<<<<<<<<<   Abilita`:   @>> 
    Money: @>>>>>        Light: @<<<   Resistenza: @>>
    Capacity: @>>>>> / @<<<<<          Bulk:   @>>>>>     
    Payload:  @>>>>> / @<<<<<          Weight: @>>>>>     
    
END

    $^A = "";
    formline( $fmt,
        $ob->short(), $ob->level,  
        $ob->race(),     $ob->wounds, $ob->hit_points,
        $ob->land(),     $ob->weapon_skill(),
        ($ob->isa('Living')?$ob->money:0),  $ob->light,      $ob->strength,  
        $ob->used_capacity, $ob->capacity,  $ob->bulk,
        $ob->used_payload,  $ob->payload,   $ob->weight,
        );

    tell_object( $pl, "$^A" );

    return 1;
    
    tell_object( $pl, daemon('level')->stats( $ob->level, $ob ) );
    return 1;
    
    tell_object( $pl, 'Name:     ', $ob->name );
    tell_object( $pl, '  - Light:     ', $ob->light, "\n" );
    tell_object( $pl, 'Bulk:     ', $ob->bulk );
    tell_object( $pl, '  - Capacity: ', $ob->used_capacity, '/', $ob->capacity, "\n" );
    tell_object( $pl, 'Weight:   ', $ob->weight );
    tell_object( $pl, '  - Payload:  ', $ob->used_payload, '/', $ob->payload,"\n" );
    tell_object( $pl, 'Money:     ', $ob->money, "\n" ) if $ob->isa('Living');;
    return 1; 
}



