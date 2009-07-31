=pod

Uso: permanent <object> [numero]
Rende l'oggetto permanente: alla prossima connessione lo ritroverai nell'inventario. 

=cut

# ---------------------------------------------------------------------
sub cmd_permanent { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift;
    my $which  = shift || 1;
    my $pl     = current_user();
    my $room   = $pl->environment();
    my $ob;

    # only interactive can
    return -1 unless $pl->isa('User');

    # only wizards can     
    return -1 unless $pl->wizardhood;

    unless ( $what ) { 
        notify_fail( parse_std_msg('Actions_Permanent_ko'));
        return -1; 
    }

    $ob = find_object( $what, 0, $which - 1);
    
    if ( $ob && ref($ob) ) {
        if ( $ob->query_property('permanent') ) {
            tell_object( $pl, parse_std_msg('Actions_Permanent_ok2',$what));
            $ob->remove_property('permanent');
        }
        else {
            tell_object( $pl, parse_std_msg('Actions_Permanent_ok1',$what));
            $ob->set_property('permanent');
        }
        return 1
    }

    notify_fail( parse_std_msg('Actions_Permanent_notfound',$what));
    return -1; 
}
