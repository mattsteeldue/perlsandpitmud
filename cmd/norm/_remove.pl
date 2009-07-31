=pod

Vedi: attack, wear

=cut

# ---------------------------------------------------------------------
# wear
sub cmd_remove { 
    my $this   = driver();
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift;  
    my $which  = shift || 1;
    my $pl     = current_user();
    my $room   = $pl->environment();

    unless( $what ) {
        notify_fail( parse_std_msg('Actions_Remove_no_what') );
        return -1;
    }

    if ( $pl->ghost() ) {
        notify_fail( parse_std_msg('NotifyGhost') ) ;
        return -1;
    }
    
    if ( $which =~ /\D/ ) { return -1 }
    
    my $ob = find_object( $what, $pl, $which - 1 );

    unless( $ob && ref($ob) ) { 
        notify_fail( parse_std_msg('Actions_Remove_ko', $what) ) if( $which == 1 );
        notify_fail( parse_std_msg('Actions_Remove_ko1', $what) ) unless( $which == 1 );
        return -1;
    }

    unless ( $ob->isa('Garment') ) {
        notify_fail( parse_std_msg('Actions_Remove_ko2') );
        return -1
    }

    # weapon_type [Body, Shield, Cloak, Boots, Gloves, Helmet, Ring, Amulet, Earring, Belt]

    if ( $ob->isa('Body') ) {
        unless( ref($pl->armour_body) ) {
            notify_fail( parse_std_msg('Actions_Remove_body') );
            return -1
        }
        $pl->armour_body( 0 );
    }

    if ( $ob->isa('Shield') ) {
        unless( ref($pl->armour_shield) ) {
            notify_fail( parse_std_msg('Actions_Remove_shield') );
            return -1
        }
        $pl->armour_shield( 0 );
    }

    if ( $ob->isa('Cloak') ) {
        unless( ref($pl->armour_cloak) ) {
            notify_fail( parse_std_msg('Actions_Remove_cloak') );
            return -1
        }
        $pl->armour_cloak( 0 );
    }

    if ( $ob->isa('Boots') ) {
        unless( ref($pl->armour_boots) ) {
            notify_fail( parse_std_msg('Actions_Remove_boots') );
            return -1
        }
        $pl->armour_boots( 0 );
    }

    if ( $ob->isa('Gloves') ) {
        unless( ref($pl->armour_gloves) ) {
            notify_fail( parse_std_msg('Actions_Remove_gloves') );
            return -1
        }
        $pl->armour_gloves( 0 );
    }

    if ( $ob->isa('Helmet') ) {
        unless( ref($pl->armour_helmet) ) {
            notify_fail( parse_std_msg('Actions_Remove_helmet') );
            return -1
        }
        $pl->armour_helmet( 0 );
    }

    ##if ( $ob->isa('Ring') ) {
    ##    unless( ref($pl->armour_ring) ) {
    ##        notify_fail( parse_std_msg('Actions_Remove_ring') );
    ##        return -1
    ##    }
    ##    $pl->armour_ring( 0 );
    ##}
    ##
    ##if ( $ob->isa('Amulet') ) {
    ##    unless( ref($pl->armour_amulet) ) {
    ##        notify_fail( parse_std_msg('Actions_Remove_amulet') );
    ##        return -1
    ##    }
    ##    $pl->armour_amulet( 0 );
    ##}
    ##
    ##if ( $ob->isa('Earring') ) {
    ##    unless( ref($pl->armour_earring) ) {
    ##        notify_fail( parse_std_msg('Actions_Remove_earring') );
    ##        return -1
    ##    }
    ##    $pl->armour_earring( 0 );
    ##}
    ##
    ##if ( $ob->isa('Belt') ) {
    ##    unless( ref($pl->armour_belt) ) {
    ##        notify_fail( parse_std_msg('Actions_Remove_belt') );
    ##        return -1
    ##    }
    ##    $pl->armour_belt( 0 );
    ##}
    
    $ob->wearing( 0 );
    
    tell_object( $pl, parse_std_msg('Actions_Remove_ok', $what) );
    say ( parse_std_msg('Actions_Remove_ok1', $what), $pl );
    return 1;
}

