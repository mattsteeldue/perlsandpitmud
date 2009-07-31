=pod

Uso: switch <username>
Consente di impersonare l'utente <username> purche' non sia connesso.
Usare il comando 'return' per ritornare indietro.

=cut

# ---------------------------------------------------------------------
sub cmd_switch { 
    my $me     = shift;
    my $verb   = shift;
    my $who      = shift; 

    $who = lc($who);

    my $this     = driver();
    my $pl       = current_user();
    my $ob       = find_user( $who );

    # only interactive can
    return -1 unless $pl->isa('User');

    # only wizards can     
    return -1 unless $pl->wizardhood;

    unless ( $who ) { 
        notify_fail( parse_std_msg('Actions_Switch_ko'));
        return -1; 
    }

    if ( $ob == $pl ) {
        notify_fail( parse_std_msg('Actions_Switch_self'));
        return -1;
    }

    if ( $ob ) {
        notify_fail( parse_std_msg('Actions_Switch_online'));
        return -1;
    }        

    # already switched by someone else?
    while ( my ($key,$user) = each %{$this->clients} ) { 
        next unless $user->switchee_user; # custom
        if ( $user->switchee_user eq $who ) { # custom
            notify_fail( parse_std_msg('Actions_Switch_online'));
            return -1;
        }
    }

    # save current
    $pl->store( getdir('dircfgusers') . $pl->name . '.cfg' );
    
    # Security: save some data... and call standard config.    
    my $environment = $pl->environment;
    my $keyname     = $pl->keyname;

    if ( user_exists("$who") ) { 
        $pl->config( getdir('dircfgusers') . $who . '.cfg' );
    }
    else {
        $ob = find_living( $who ) ;
        if ( ref($ob) && $ob->isa('Mobile') ) {
            my @config = store_string( $ob );
            restore_string( $pl, @config ); 
            tell_object($pl, "Done\n" );
        }
        else {
            notify_fail( parse_std_msg('Actions_Switch_nomob'));
            return 0;
        }
    }

    # restore.
    $pl->environment($environment);
    $pl->keyname    ($keyname    ); 

    $pl->switched_by($pl->name);
    $pl->switchee_user($who);

    $pl->name($who);
    
    tell_object($pl, "Done\n" );

    return 1; 
}
