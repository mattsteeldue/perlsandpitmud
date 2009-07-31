=pod

Per interagire con gli oggetti mobili hai a disposizione i seguenti comandi; alcuni comandi sono disponibili in due lingue, italiano e inglese.

- prendi  - get     - per prendere un oggetto
- lascia  - drop    - per lasciare un oggetto
- dai     - give    - per dare un oggetto a qualcuno
- esamina - examine - per esaminare un oggetto disponibile
- i       - inventory - lista degli oggetti che stai portando.

=cut

# ---------------------------------------------------------------------
# moves an object from the room to the inventory of current_user
sub cmd_get { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift;
    my $which  = shift || 1;
    my $this   = driver();
    my $pl     = current_user();
    my $room   = $pl->environment();

    unless( $what ) {
        notify_fail( parse_std_msg('Actions_Get_no_what') );
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
        my @ary =  @{ $room->inventory } ;
        foreach my $ob ( @ary ) {
            next if $ob->cannot_get(); # asks ob if it can be gotten
            my $result = $ob->move( $pl ) ;
            if ( $result > 0 ) {
                tell_object( $pl, parse_std_msg('Actions_Get_ok', $ob->short) );
                say ( parse_std_msg('Actions_Get_ok2', $ob->short), $pl );
                tell_object( $ob, parse_std_msg('Actions_Get_ok1' ) );
            }
        }
        return 1;
    }
    
    my $ob = find_object( $what, $room, $which - 1 );
    if ( $ob && ref($ob) ) {
        # object will provide notify_fail
        return -1 if $ob->cannot_get(); # asks ob if it can be gotten
        my $result = $ob->move( $pl ) ;
        if ( $result > 0 ) {
            tell_object( $pl, parse_std_msg('Actions_Get_ok', $ob->short) );
            say ( parse_std_msg('Actions_Get_ok2', $ob->short), $pl );
            tell_object( $ob, parse_std_msg('Actions_Get_ok1' ) );
            return 1
        }
        else {
            notify_fail( parse_std_msg('Actions_Get_ko2', $what ) ) if $result == -2;
            notify_fail( parse_std_msg('Actions_Get_ko3', $what ) ) if $result == -3;
            return -1 ;
        }
    }
    notify_fail( parse_std_msg('Actions_Get_ko', $what) ) if( $which == 1 );
    notify_fail( parse_std_msg('Actions_Get_ko1', $what) ) unless( $which == 1 );
    return -1;
}

