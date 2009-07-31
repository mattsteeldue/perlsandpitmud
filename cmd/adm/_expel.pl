=pod

Uso: expel <username> [messaggio]
Espelle definitivamente dal Mondo Emerso l'utente indicato. 
Il nome <username> viene totalmente rimosso da tutti i file, come se non fosse mai esistito. E' eventualmente possibile inviare un messaggio all'utente per comunicar il motivo. Il messaggio gli verra' inviato solo se attualmente on-line. Non è possibile espellere te stesso o altri wizard. 
E' un comando molto drastico e il suo utilizzo viene tracciato. 

=cut

###use Archive; 

# ---------------------------------------------------------------------
sub cmd_expel { 
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

    if ( $ob && $ob->wizardhood() ) {
        notify_fail( parse_std_msg('Actions_Expel_online'));
        return -1;
    }        

    unless ( user_exists( $who ) ) { 
        notify_fail( parse_std_msg('Actions_Expel_no',ucfirst( $who ) ));
        ###arc_erase( '_driver_dbuser', "$who" ); # anyway...
        my $dbh = dbi();
        my $sth = $dbh->prepare( qq[ delete from engine_user_info where name=? ]) ;
        $sth->execute( $who );
        $sth->finish();
        daemon('channel')->channel_off_all( $who );
        return -1;
    }
    
    tell_object( $pl, parse_std_msg('Actions_Expel_confirm',std_msg('yes'),std_msg('no') ) );
    $pl->custom('ExpelUsername',$who) ;
    $pl->custom('ExpelMotivation',"@said") ;
    $pl->input_to('process_expel1');
    return 1;    

}

sub process_expel1 {
    my $reply    = wipe_bs(shift);
    my $this     = driver();
    my $pl       = current_user();
    my $who      = $pl->custom('ExpelUsername') ; 
    my $said     = $pl->custom('ExpelMotivation') ;
    my $ob       = find_object( $who );

    my $match    = std_msg('yes');
    if ( $reply =~ m/^\s*$match\s*/i ) {
    #if ( $reply =~ m/^\s*S\s*/i ) {

        if ( $ob && $ob->status ne 'Logon' ) {    
            tell_object( $ob, parse_std_msg('Actions_Expel_expels',$said) );  
            current_user( $ob );
            quit_client( $ob->client );
            current_user( $pl );
        }
        else {
            if ( user_exists( $who ) ) { 
                tell_object( $pl, parse_std_msg('Actions_Expel_notplay', $who ) );
            }
            else {
                tell_object( $pl, parse_std_msg('Actions_Expel_no',ucfirst($who) ) );
                return 1;
            }
        }
        tell_object( $pl, parse_std_msg('Action_Expel_expel',ucfirst($who) ) ); # if $pl->echo();
        daemon('channel')->channel_off_all( $who );
        log_file "expel.log", $pl->name, " expels $who ($said)";
        my $dbh = dbi();
        my $sth = $dbh->prepare( qq[ delete from engine_password where username=? ]) ;
        $sth->execute( $who );
        $sth->finish();
        ###delete $this->password->{ "$who" }; 
        ###store_config( $this->password(), getdir('dirdbsqlite') . "passwords.cfg" ) ;
        ###arc_erase( '_driver_dbuser', "$who" );
        $sth = $dbh->prepare( qq[ delete from engine_user_info where name=? ]) ;
        $sth->execute( $who );
        $sth->finish();
    }
    return 1;
}
