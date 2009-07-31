=pod

Per interagire con gli oggetti mobili hai a disposizione i seguenti comandi; alcuni comandi sono disponibili in due lingue, italiano e inglese.

- prendi  - get     - per prendere un oggetto
- lascia  - drop    - per lasciare un oggetto
- dai     - give    - per dare un oggetto a qualcuno
- esamina - examine - per esaminare un oggetto disponibile
- i       - inventory - lista degli oggetti che stai portando.

=cut

# ---------------------------------------------------------------------
# moves an object from the inventory of current_user to another's one.
sub cmd_give { 
    my $this   = driver();
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift;  
    my $who    = shift;      
       $who    = shift if $who eq std_msg('to') ;
    my $which  = shift || 1;
    my $pl     = current_user();
    my $room   = $pl->environment();

    unless( $what ) {
        notify_fail( parse_std_msg('Actions_Give_no_what') );
        return -1;
    }
    if ( $pl->ghost() ) {
        notify_fail( parse_std_msg('NotifyGhost') ) ;
        return -1;
    }
    
    if ( $which =~ /\D/ ) { return -1 }
    
    ###print $what, $pl->name, $which, "\n";
    my $ob = find_object( $what, $pl, $which - 1);
    unless( $ob && ref($ob) ) { 
        notify_fail( parse_std_msg('Actions_Give_ko', $what, $who) ) if( $which == 1 );
        notify_fail( parse_std_msg('Actions_Give_ko1', $what, $who) ) unless( $which == 1 );
        return -1;
    }
    unless( $who ) {
        notify_fail( parse_std_msg('Actions_Give_no_who' , $what ) );
        return -1;
    }
    if ( ! $room ) { 
        notify_fail( parse_std_msg('Actions_no_environment') );
        return -1 
    }
    my $other = find_object( $who, $room );
    
    if ( $other == $pl ) {
        notify_fail( parse_std_msg('Actions_Give_ko4', $what, $who) );
        return -1;
    }
    unless( $other ) {
        notify_fail( parse_std_msg('Actions_Give_no_who' , $what ) );
        return -1;
    }
    
    if ( $ob && ref($ob) ) {
        return -1 if $ob->cannot_drop() ; # ask ob if it can be given
        my $result = $ob->move( $other );
        if ( $result > 0 ) {
            tell_object( $pl, parse_std_msg('Actions_Give_ok', $ob->short, $who) );
            say ( parse_std_msg('Actions_Give_ok2', $pl->short(), $ob->short, $who), $pl, $other );
            tell_object( $other, parse_std_msg('Actions_Give_ok3', $ob->short, $pl->short) );
            tell_object( $ob, parse_std_msg('Actions_Give_ok1', $who ) );
            return 1
        }
        else {
            notify_fail( parse_std_msg('Actions_Give_ko2', $what ) ) if $result == -2;
            notify_fail( parse_std_msg('Actions_Give_ko3', $what ) ) if $result == -3;
            return -1 ;
        }
    }
    return -1
}

