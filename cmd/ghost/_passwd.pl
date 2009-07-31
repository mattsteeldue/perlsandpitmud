=pod

Uso: passwd
Comando per cambiare password. Viene richiesto di digitare la vecchia password, e di seguito la nuova password, due volte, per conferma. Se la vecchia password non viene data correttamente oppure la seconda conferma non corrisponde con la prima, il cambio viene interrotto.

=cut

# ---------------------------------------------------------------------
sub cmd_passwd { 
    my $me       = shift;
    my $verb   = shift;
    my $this     = driver();
    my $pl       = current_user();
    write_client( parse_std_msg( 'Actions_Passwd_old' ) );
    $pl->input_to('process_passwd1');
    return 1;    
}

sub process_passwd1 {
    my $password = wipe_bs(shift);
    my $this     = driver();
    my $pl       = current_user();
    my $username = $pl->name();

    $salt = length($username).length($password) ^ '@_';
    if ( $this->password( "$username" ) eq crypt($password,$password) # old-style
      or $this->password( "$username" ) eq crypt($password,$salt)) { 
        write_client( parse_std_msg('Actions_Passwd_new') );
        $pl->input_to('process_passwd2');
    }
    else {
        write_client( parse_std_msg('Actions_Passwd_wrong') );
    }
    return 1;
}

sub process_passwd2 {
    my $password = wipe_bs(shift);
    my $this     = driver();
    my $pl       = current_user();
    my $username = $pl->name();
    
    if( 0 == length($password) ) {
        write_client( parse_std_msg('Actions_Passwd_notmod'));
        return 1;
    }
    
    $salt = length($username).length($password) ^ '@_';
    $pl->password( crypt($password,$salt) ); 
    write_client( parse_std_msg('Actions_Passwd_confirm') );
    $pl->input_to('process_passwd3');
    return 1;
}

sub process_passwd3 {
    my $password = wipe_bs(shift);
    my $this     = driver();
    my $pl       = current_user();
    my $username = $pl->name();

    $salt = length($username).length($password) ^ '@_';
    if ( $pl->password() eq crypt($password,$salt) ) { 
        my $dbh = dbi();
        my $sth = $dbh->prepare( 
            qq[ update engine_password set passwd=?, newpwd='NEW' where username=? ] );
        unless ( $dbh->err ) {
            $sth->execute( $pl->password(), $username );
            $sth->finish();
            write_client( parse_std_msg('Actions_Passwd_modified'));
            return 1;
        }
    }

    write_client( parse_std_msg('Actions_Passwd_notmod'));

    return 1;
}
