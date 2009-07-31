=pod

Uso: resetpassword <username>
Resetta la password dell'utente indicato. La password sarà uguale allo username.

=cut

# ---------------------------------------------------------------------
sub cmd_resetpassword { 
    my $me       = shift;
    my $verb   = shift;
    my $who      = shift; 
    my @said     = @_;

    $who = lc($who);
    
    my $this     = driver();
    my $pl       = current_user();
    my $ob       = find_object( $who );

    # only interactive can
    return -1 unless $pl;
    
    # only wizards can     
    return -1 unless $pl->wizardhood(); # silently returns

    unless ( $who ) {
        notify_fail( parse_std_msg('Actions_Expel_ko'));
        return -1;
    }        

    if ( $ob == $pl ) {
        notify_fail( parse_std_msg('Actions_Expel_self'));
        return -1;
    }

    if ( $ob ) {
        notify_fail( parse_std_msg('Actions_Expel_online'));
        return -1;
    }        

    unless ( user_exists( $who ) ) { 
        notify_fail( parse_std_msg('Actions_Expel_no',ucfirst( $who ) ));
        return -1;
    }
    
    tell_object( $pl, parse_std_msg('Actions_Expel_confirm',std_msg('yes'),std_msg('no') ) );
    $pl->custom('ResetpasswordUsername',$who) ;
    $pl->input_to('process_resetpassword1');
    return 1;    

}

sub process_resetpassword1 {
    my $reply    = wipe_bs(shift);
    my $this     = driver();
    my $pl       = current_user();
    my $who      = $pl->custom('ResetpasswordUsername') ; 
    my $ob       = find_object( $who );

    my $match    = std_msg('yes');
    if ( $reply =~ m/^\s*$match\s*/i ) {

        my $username = lc($who);
        my $password = lc($who);
        $salt = length($username).length($password) ^ '@_';
        $pl->password( crypt($password,$salt) ); 
        my $dbh = dbi();
        my $sth = $dbh->prepare( 
            qq[ update engine_password set passwd=?, newpwd='NEW' where username=? ] );
        unless ( $dbh->err ) {
            $sth->execute( $pl->password(), $username );
        }

    }
    return 1;
}
