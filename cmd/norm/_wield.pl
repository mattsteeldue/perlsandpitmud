=pod

Vedi: attack, remove

=cut

# ---------------------------------------------------------------------
# wield
sub cmd_wield { 
    my $this   = driver();
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift;  
    my $which  = shift || 1;
    my $pl     = current_user();
    my $room   = $pl->environment();

    unless( $what ) {
        notify_fail( parse_std_msg('Actions_Wield_no_what') );
        return -1;
    }

    if ( $pl->ghost() ) {
        notify_fail( parse_std_msg('NotifyGhost') ) ;
        return -1;
    }
    
    if ( $which =~ /\D/ ) { return -1 }
    
    my $ob = find_object( $what, $pl, $which - 1 );

    unless( $ob && ref($ob) ) { 
        notify_fail( parse_std_msg('Actions_Wield_ko', $what) ) if( $which == 1 );
        notify_fail( parse_std_msg('Actions_Wield_ko1', $what) ) unless( $which == 1 );
        return -1;
    }

    unless ( $ob->isa('Weapon') ) {
        notify_fail( parse_std_msg('Actions_Wield_ko2') );
        return -1
    }

    if ( $ob->isa('Weapon') ) {
        if( ref($pl->armour_righthand) ) {
            notify_fail( parse_std_msg('Actions_Wield_already', $pl->armour_righthand) );
            return -1
        }
        $pl->armour_righthand( $ob );
    }
    
    $ob->wielding( 1 );
    
    tell_object( $pl, parse_std_msg('Actions_Wield_ok', $what) );
    say ( parse_std_msg('Actions_Wield_ok1', $what), $pl );
    return 1;
}

