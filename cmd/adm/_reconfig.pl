=pod

Uso: reconfig [username]
Rilegge il file di configuarazione di un certo utente.

=cut

# ---------------------------------------------------------------------
sub cmd_reconfig { 
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
        notify_fail( parse_std_msg('Actions_Reconfig_ko') );  
        return -1; 
    }

    my $environment = $ob->environment;
    $ob->config( getdir('dircfgusers') . $who . '.cfg' );
    $ob->environment($environment);

    tell_object( $pl, parse_std_msg('Actions_Reconfig_ok', $pl->short ) ) unless $pl == $ob;
    tell_object( $ob, parse_std_msg('Actions_Reconfig_ok1') ) ;
    
    return 1; 
}
