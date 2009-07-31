=pod

Per interagire con gli oggetti mobili hai a disposizione i seguenti comandi; alcuni comandi sono disponibili in due lingue, italiano e inglese.

- prendi  - get     - per prendere un oggetto
- lascia  - drop    - per lasciare un oggetto
- dai     - give    - per dare un oggetto a qualcuno
- esamina - examine - per esaminare un oggetto disponibile
- i       - inventory - lista degli oggetti che stai portando.

=cut

# ---------------------------------------------------------------------
# moves an object from the inventory of current_user to the room.
sub cmd_drop { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift;
    my $which  = shift || 1;
    my $pl     = current_user();
    my $room   = $pl->environment();

    unless( $what ) {
        notify_fail( parse_std_msg('Actions_Drop_no_what') );
        return -1;
    }
    if ( ! $room ) { 
        notify_fail( parse_std_msg('Actions_no_environment') );
        return -1 
    }

    if ( $pl->ghost() ) {
        notify_fail( parse_std_msg('NotifyGhost') ) ;
        return -1;
    }

    if ( $what eq 'all' || $what eq std_msg('all') ) {
        my @ary =  @{ $pl->inventory } ;
        foreach my $ob ( @ary ) {
            next if $ob->cannot_drop(); # asks ob if it can be dropped
            my $result = $ob->move( $room ) ;
            if ( $result > 0 ) {
                tell_object( $pl, parse_std_msg('Actions_Drop_ok', $ob->short) ) ;
                say ( parse_std_msg('Actions_Drop_ok2', $ob->short), $pl );
                tell_object( $ob, parse_std_msg('Actions_Drop_ok1') );
            }
        }
        return 1;
    }
    
    my $ob = $what;
    $ob = find_object( $what, $pl, $which - 1 ) unless ref($what);
    if ( $ob && ref($ob) ) {
        # object will provide notify_fail
        return -1 if $ob->cannot_drop() ; # ask ob if it can be dropped
        my $result = $ob->move( $room );
        if ( $result > 0 ) {
            tell_object( $pl, parse_std_msg('Actions_Drop_ok', $ob->short) );
            say ( parse_std_msg('Actions_Drop_ok2', $ob->short), $pl );
            tell_object( $ob, parse_std_msg('Actions_Drop_ok1' ) );
            return 1
        }
        else {
            notify_fail( parse_std_msg('Actions_Drop_ko2', $what ) ) if $result == -2;
            notify_fail( parse_std_msg('Actions_Drop_ko3', $what ) ) if $result == -3;
            return -1 ;
        }
    }
    notify_fail( parse_std_msg('Actions_Drop_ko', $what) ) if( $which == 1 );
    notify_fail( parse_std_msg('Actions_Drop_ko1', $what) ) unless( $which == 1 );
    return -1;
}

