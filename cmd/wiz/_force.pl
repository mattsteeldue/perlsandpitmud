=pod

Uso: force <target> <commands...>
Consente di forzare un altro utente oppure un mob ad eseguire i comando specificato, come se fosse stato inserito da terminale.

=cut

# ---------------------------------------------------------------------
sub cmd_force { 
    my $me    = shift;
    my $verb  = shift;
    my $who   = shift; 
    my @said  = @_;

    $who = lc($who);
    
    my $this     = driver();
    my $pl       = current_user();
    my $ob       = find_object( $who );

    # only interactive can
    return -1 unless $pl->isa('User');
    
    # only wizards can     
    return -1 unless $pl->wizardhood(); # silently returns

    unless ( $who && (@_)>0 ) {
        notify_fail( parse_std_msg('Actions_Force_ko'));
        return -1;
    }        

    if ( $ob == $pl ) {
        notify_fail( parse_std_msg('Actions_Force_self'));
        return -1;
    }

    unless ( ref($ob) ) {
        notify_fail( parse_std_msg('Actions_Force_nowho'));
        return -1;
    }

    ##if ( $ob->level > $pl->level ) {
    ##    notify_fail( parse_std_msg('Actions_Force_higher'));
    ##    return -1;
    ##}        

    $ob->force_to( "@said" );

    return 1;    

}
