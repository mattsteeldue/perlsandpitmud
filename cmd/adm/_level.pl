=pod

Uso: level <mobname> <level>
Effettua il setup di un oggetto al livello <level>

=cut

# ---------------------------------------------------------------------
sub cmd_level { 
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
        notify_fail( parse_std_msg('Actions_Level_ko') );
        return -1;
    }        

    unless ( find_living("$who") ) { 
        notify_fail( parse_std_msg('Actions_Level_nowho', ucfirst($who) ) );
        return -1;
    }
    
    tell_object( $pl, parse_std_msg('Actions_Level_confirm',std_msg('yes'),std_msg('no')) );
    $pl->custom('LevelUsername',$who) ;
    $pl->custom('LevelLevel',$level) ;
    $pl->input_to('process_level1');
    return 1;    
}

sub process_level1 {
    my $reply    = wipe_bs(shift);
    my $this     = driver();
    my $pl       = current_user();
    my $who      = $pl->custom('LevelUsername') ; 
    my $level    = $pl->custom('LevelLevel') ;
    my $ob       = find_object( $who );

    my $match    = std_msg('yes');
    if ( $reply =~ m/^\s*$match\s*/i ) {
    #if ( $reply =~ m/^\s*S\s*/i ) {
        
        # effectively change level only if original level was not wizard or admin.
        $ob->level( $level ) if $ob->level <= getsetup('LevelMax');
        daemon('level')->set_stats( $level, $ob );
        #call_other( getdaemon('level'), 'set_stats', $pl->level(), $ob );
        
        tell_object( $ob, parse_std_msg('Actions_Level_ok', ucfirst($who), $level ) ) unless $ob == $pl;
        tell_object( $pl, parse_std_msg('Actions_Level_ok', ucfirst($who), $level ) );
    }
    return 1;
}
