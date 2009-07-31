=pod

Vedi: attack, remove

=cut

# ---------------------------------------------------------------------
# wear
sub cmd_wear { 
    my $this   = driver();
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift;  
    my $which  = shift || 1;
    my $pl     = current_user();
    my $room   = $pl->environment();

    unless( $what ) {
        notify_fail( parse_std_msg('Actions_Wear_no_what') );
        return -1;
    }

    if ( $pl->ghost() ) {
        notify_fail( parse_std_msg('NotifyGhost') ) ;
        return -1;
    }
    
    if ( $which =~ /\D/ ) { return -1 }
    
    my $ob = find_object( $what, $pl, $which - 1 );

    unless( $ob && ref($ob) ) { 
        notify_fail( parse_std_msg('Actions_Wear_ko', $what) ) if( $which == 1 );
        notify_fail( parse_std_msg('Actions_Wear_ko1', $what) ) unless( $which == 1 );
        return -1;
    }
    
    unless ( $ob->isa('Garment') ) {
        notify_fail( parse_std_msg('Actions_Wear_ko2') );
        return -1
    }

    # weapon_type [Body, Shield, Cloak, Boots, Gloves, Helmet, Ring, Amulet, Earring, Belt]

    if ( $ob->isa('Body') ) {
        if( ref($pl->armour_body) ) {
            notify_fail( parse_std_msg('Actions_Wear_body') );
            return -1
        }
        $pl->armour_body( $ob );
    }

    if ( $ob->isa('Shield') ) {
        if( ref($pl->armour_shield) ) {
            notify_fail( parse_std_msg('Actions_Wear_shield') );
            return -1
        }
        $pl->armour_shield( $ob );
    }

    if ( $ob->isa('Cloak') ) {
        if( ref($pl->armour_cloak) ) {
            notify_fail( parse_std_msg('Actions_Wear_cloak') );
            return -1
        }
        $pl->armour_cloak( $ob );
    }

    if ( $ob->isa('Boots') ) {
        if( ref($pl->armour_boots) ) {
            notify_fail( parse_std_msg('Actions_Wear_boots') );
            return -1
        }
        $pl->armour_boots( $ob );
    }

    if ( $ob->isa('Gloves') ) {
        if( ref($pl->armour_gloves) ) {
            notify_fail( parse_std_msg('Actions_Wear_gloves') );
            return -1
        }
        $pl->armour_gloves( $ob );
    }

    if ( $ob->isa('Helmet') ) {
        if( ref($pl->armour_helmet) ) {
            notify_fail( parse_std_msg('Actions_Wear_helmet') );
            return -1
        }
        $pl->armour_helmet( $ob );
    }

    ##if ( $ob->isa('Ring') ) {
    ##    if( ref($pl->armour_ring) ) {
    ##        notify_fail( parse_std_msg('Actions_Wear_ring') );
    ##        return -1
    ##    }
    ##    $pl->armour_ring( $ob );
    ##}
    ##
    ##if ( $ob->isa('Amulet') ) {
    ##    if( ref($pl->armour_amulet) ) {
    ##        notify_fail( parse_std_msg('Actions_Wear_amulet') );
    ##        return -1
    ##    }
    ##    $pl->armour_amulet( $ob );
    ##}
    ##
    ##if ( $ob->isa('Earring') ) {
    ##    if( ref($pl->armour_earring) ) {
    ##        notify_fail( parse_std_msg('Actions_Wear_earring') );
    ##        return -1
    ##    }
    ##    $pl->armour_earring( $ob );
    ##}
    ##
    ##if ( $ob->isa('Belt') ) {
    ##    if( ref($pl->armour_belt) ) {
    ##        notify_fail( parse_std_msg('Actions_Wear_belt') );
    ##        return -1
    ##    }
    ##    $pl->armour_belt( $ob );
    ##}
    
    $ob->wearing( 1 );
    
    tell_object( $pl, parse_std_msg('Actions_Wear_ok', $what) );
    say ( parse_std_msg('Actions_Wear_ok1', $what), $pl );
    return 1;
}

