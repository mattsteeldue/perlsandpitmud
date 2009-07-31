=pod

Uso: restore [username]
Ripristina le statistiche di un certo utente.

=cut

# ---------------------------------------------------------------------
sub cmd_restore { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();
    my $who    = shift || $pl->name;
    
    # only interactive can
    return -1 unless $pl->isa('User');

    # only wizards can     
    return -1 unless $pl->wizardhood;

    $who = lc($who);
    my $ob = find_user( $who );

    unless ( $ob ) { 
        notify_fail( parse_std_msg('Actions_Restore_ko') );  
        return -1; 
    }

    $ob->wounds( $ob->hit_points() ); 

    tell_object( $pl, parse_std_msg('Actions_Restore_ok', $ob->short ) ) unless $pl == $ob;
    tell_object( $ob, parse_std_msg('Actions_Restore_ok1') ) ;
    
    return 1; 
}
