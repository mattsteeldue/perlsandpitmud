=pod

Per farsi seguire da qualcuno

=cut

# ---------------------------------------------------------------------
sub cmd_party { 
    my $me     = shift;
    my $verb   = shift;
    my $who    = shift || 0;
    my $this   = driver();
    my $pl     = current_user();
    my $plwho  = find_user( $who );

    if ( $who eq $pl->name ) {
        notify_fail( parse_std_msg('Actions_Party_leader') );
        return -1;
    }

    unless ( $who ) {
        tell_object( $pl, parse_std_msg('Actions_Party_list') );
        my @ary = sort( @{ $pl->party } );
        tell_object( $pl, wrap_string( "@ary") );
        tell_object( $pl, "\n" );
        notify_fail( parse_std_msg('Actions_Party_usage') );
        return -1;    
    }

    if ( -1 != pos_array( $pl->party, $who ) ) {
        remove_from_array( $pl->party, "$who" ) ;
        if (ref($plwho)) {
            tell_object( $plwho, parse_std_msg('Actions_Party_remove') ) ;
            tell_object( $pl, parse_std_msg('Actions_Party_removed', $plwho->short ) );
            if ( $plwho->following eq $pl->name ) {
                tell_object( $plwho, parse_std_msg('Actions_Follow_stop',$pl->short ) ) ;
                $plwho->following( 0 );
            }
        }
        else {
            tell_object( $pl, parse_std_msg('Actions_Party_removed', ucfirst($who) ) );
        }
    }
    else {
        push @{ $pl->party }, $who ;
        if (ref($plwho)) {
            tell_object( $plwho, parse_std_msg('Actions_Party_add' ) ) ;
            tell_object( $pl, parse_std_msg('Actions_Party_added', $plwho->short ) );
        }
        else {
            tell_object( $pl, parse_std_msg('Actions_Party_added', ucfirst($who) ) );
        }
    }

    return 1;
}

