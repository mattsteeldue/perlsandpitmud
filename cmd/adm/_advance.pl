=pod

Uso: advance <username> <level>
Promuove un <username> al livello <level>

=cut

# ---------------------------------------------------------------------
sub cmd_advance { 
    my $me       = shift;
    my $verb     = shift;
    my $who      = shift; 
    my $level    = shift;

    $who = lc($who);
    
    my $this     = driver();
    my $pl       = current_user();
    my $ob       = find_object( $who );
    my $username = $pl->name; 

    # only interactive can
    return -1 unless $pl;
    
    # only wizards can     
    return -1 unless $pl->wizardhood(); # silently returns

    unless ( $who && $level ) {
        notify_fail( parse_std_msg('Actions_Advance_ko') );
        return -1;
    }        

    if ( $ob == $pl ) {
        notify_fail(parse_std_msg('Actions_Advance_self') );
        return -1;
    }

    unless ( user_exists("$who") ) { 
        notify_fail( parse_std_msg('Actions_Advance_nowho', ucfirst( $who ) ) );
        return -1;
    }
    
    tell_object( $pl, parse_std_msg('Actions_Advance_confirm',std_msg('yes'),std_msg('no')) );
    $pl->custom('AdvanceUsername',$who) ;
    $pl->custom('AdvanceLevel',$level) ;
    $pl->input_to('process_advance1');
    return 1;    
}

sub process_advance1 {
    my $reply    = wipe_bs(shift);
    my $this     = driver();
    my $pl       = current_user();
    my $who      = $pl->custom('AdvanceUsername') ; 
    my $level    = $pl->custom('AdvanceLevel') ;
    my $ob       = find_object( $who );

    my $match    = std_msg('yes');
    if ( $reply =~ m/^\s*$match\s*/i ) {
    #if ( $reply =~ m/^\s*S\s*/i ) {

        if ( $ob && $ob->status ne 'Logon' ) {    
            if ( $level == $ob->level() ) {
                tell_object( $pl, parse_std_msg('Actions_Advance_already', ucfirst($who), $ob->level() ) );
            }
            else {
                if ( $level > $ob->level() ) {
                    tell_object( $pl, parse_std_msg('Actions_Advance_ok', ucfirst($who), $level ) );
                }
                else {
                    tell_object( $pl, parse_std_msg('Actions_Advance_ok2', ucfirst($who), $level ) );
                }
                $ob->level( $level ) if $ob->level <= getsetup('LevelMax');
                tell_object( $ob, "Level $level\n");
                save_user( $ob );
            }
        }
        else {
            # during Logon
            if ( user_exists("$who") ) { 
                tell_object( $pl, parse_std_msg('Actions_Advance_notplay', ucfirst($who) ) );
            }
            else {
                tell_object( $pl, parse_std_msg('Actions_Advance_no', ucfirst($who) ) );
            }
        }
    }
    return 1;
}
    