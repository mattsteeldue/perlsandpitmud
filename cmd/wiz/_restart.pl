=pod

Uso: restart
Richiama la function 'restart' della stanza dove ti trovi. Il restart avviene periodicamente ogni tot minuti, questo comando consente di anticiparlo. Di solito questo consente di azzerare la stanza e ripristinare gli oggetti come all'avvio.  

=cut

# ---------------------------------------------------------------------
sub cmd_restart { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift;
    my $which  = shift || 1;
    my $pl     = current_user();
    my $ob;

    # only interactive can
    return -1 unless $pl->isa('User');

    # only wizards can     
    return -1 unless $pl->wizardhood;

    unless ( $what ) { 
        notify_fail( parse_std_msg('Actions_Restart_ko'));
        return -1; 
    }

    $ob = find_object( $what, 0, $which - 1);
    
    if ( $ob && ref($ob) ) {
        
        tell_object( $pl, parse_std_msg('Actions_Restart_ok1',$what));
        say ( parse_std_msg('Actions_Restart_ok2',$what) , $pl, $ob );
        tell_object( $ob, parse_std_msg('Actions_Restart_ok3'));
        # synchro-reset. For this object, from now on, the reset is phased at this time
        $ob->restart();
        return 1
    }
    elsif ( $what eq 'here' ) {
        tell_object( $pl, parse_std_msg('Actions_Restart_ok1',$what));
        say ( parse_std_msg('Actions_Restart_ok2',$what) , $pl );
        my $delta = driver()->time_restart();
        $pl->environment->last_restart( $pl->environment->last_restart - $delta );
        return 1;
    }
    elsif ( $what eq 'all' ) {
        tell_object( $pl, parse_std_msg('Actions_Restart_ok1',$what));
        say ( parse_std_msg('Actions_Restart_ok2',$what) , $pl );
        my $delta = driver()->time_restart();
        my @people = values %{ driver()->objects() };
        # simply move backward last_restart time, so next heartbeat will trigger.
        # this preserve the synchro of any object.
        foreach my $el ( @people ) {
            $el->last_restart( $el->last_restart - $delta );
        }
        return 1;
    }

    notify_fail( parse_std_msg('Actions_Restart_notfound',$what));
    return -1; 
}
