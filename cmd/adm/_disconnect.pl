# ---------------------------------------------------------------------
sub cmd_disconnect { 
    my $me     = shift;
    my $verb   = shift;
    my $who      = shift; 

    $who = lc($who);

    my $this     = driver();
    my $pl     = current_user();
    my $ob       = find_object( $who );
    my $username = $pl->name; 

    # only interactive can
    return -1 unless $pl->isa('User');

    # only wizards can     
    return -1 unless $pl->wizardhood;

    unless ( $who ) { 
        notify_fail( parse_std_msg('Actions_Disconnect_ko'));  
        return -1; 
    }

    if ( $ob == $pl ) {
        notify_fail( parse_std_msg('Actions_Disconnect_self'));
        return -1;
    }

    if ( $ob && $ob->status ne 'Logon' ) {    
        current_user( $ob );
        quit_client( $ob->client );
        current_user( $pl );
    }
    else {
        if ( user_exists("$who") ) { 
            notify_fail( parse_std_msg('Actions_Disconnect_notplay', ucfirst($who) ));
            return -1;
        }
        else {
            notify_fail( parse_std_msg('Actions_Disconnect_no',ucfirst($who) ));
            return -1;
        }
    }
    return 1; 
}
