=pod

Per seguire qualcuno

=cut

# ---------------------------------------------------------------------
sub cmd_follow { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift || 0;
    my $which  = shift || 1;
    my $this   = driver();
    my $pl     = current_user();
    my $room   = $pl->environment;

    if ( $what eq $pl->name ) {
        notify_fail( parse_std_msg('Actions_Follow_self') );
        return -1;
    }

    if ( $pl->following ) {
        my $leader = find_living( $pl->following );

        if ( ref($leader) && $pl->isa('Living') ) {
            if ( $what eq $leader->name ) {
                notify_fail( parse_std_msg('Actions_Follow_already', $leader->short ) );
                return -1;
            }
            tell_object( $pl, parse_std_msg('Actions_Follow_stop',$leader->short ) ) ;
            tell_object( $leader, parse_std_msg('Actions_Follow_stop2' ) );
            remove_from_array( $leader->follower, $pl->name );
        }

        $pl->following( 0 );
        return 1 unless ( $what );

    }

    unless ( $what ) {
        notify_fail( parse_std_msg('Actions_Follow_arent') );
        return -1;
    }

    if ( ref($room) && $room->light <= 0 ) { 
        tell_object( $pl, parse_std_msg('Actions_it_is_dark' ) );
        return 1 
    }

    #if ( $pl->ghost() ) {
    #    notify_fail( parse_std_msg('NotifyGhost') ) ;
    #    return -1;
    #}
    
    my $ob = 0;
    $ob = find_object( $what, $room, $which - 1) if $which =~ m/\d/ ;

    if( ref($ob) && $ob->isa('Living') ) {   

        unless ( $pl->wizardhood ) {
            if ( -1 == pos_array( $ob->party, $pl->name ) ) {
                notify_fail( parse_std_msg('Actions_Follow_noparty') );
                return -1;
            }
        }

        $pl->following( $ob->name );
        push @{$ob->follower}, $pl->name if -1 == pos_array( @{$ob->follower}, $pl->name );
        tell_object( $pl, parse_std_msg('Actions_Follow_start', $ob->short ) ); 
        tell_object( $ob, parse_std_msg('Actions_Follow_start2' , $pl->short ) );   
        return 1;
    }

    notify_fail( parse_std_msg('Actions_Follow_ko', ucfirst($what) ) ) if( $which == 1 );
    notify_fail( parse_std_msg('Actions_Follow_ko2', ucfirst($what) ) ) unless( $which == 1 );
    return -1   
}

