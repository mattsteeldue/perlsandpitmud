=pod

Uso: zap <oggetto> [numero]
Distrugge l'oggetto o mob specificato che viene rimosso completamente. Nel caso esistano numerosi oggetti con lo stesso nome, il numero consente di distinguere quale dev'essere rimosso. Per evitare ambiguità è opportuno utilizzare il nome completo di numero seriale. Non è possibile zappare gli utenti. 

=cut

# ---------------------------------------------------------------------
sub cmd_zap { 
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
        notify_fail( parse_std_msg('Actions_Zap_ko'));
        return -1; 
    }

    $ob = find_object( $what, 0, $which - 1);

    if ( ref($ob) && $ob->isa('User') ) {
        notify_fail( parse_std_msg('Actions_Zap_notfound',$what));
        return -1;
    }
    

    
    if ( $ob && ref($ob) ) {
        return -1 if $ob->cannot_zap();
        
        tell_object( $pl, parse_std_msg('Actions_Zap_ok1',$what));
        say ( parse_std_msg('Actions_Zap_ok2',$ob->name) , $pl, $ob );
        tell_object( $ob, parse_std_msg('Actions_Zap_ok3'));
        $ob->destroy();
        return 1
    }
    else {
        if ( $what eq 'all' ) {
            tell_object( $pl, parse_std_msg('Actions_Zap_ok1',$what));
            say ( parse_std_msg('Actions_Zap_ok2',$what) , $pl );
            tell_object( $ob, parse_std_msg('Actions_Zap_ok3'));
            foreach my $el ( $room->recursive_inventory ) {
                $el->destroy() unless $el->isa('User');
            }
            return 1;
        }
    }

    notify_fail( parse_std_msg('Actions_Zap_notfound',$what));
    return -1; 
}
