=pod

Usage: back


=cut

# ---------------------------------------------------------------------
# moves to previous room
sub cmd_back { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user() || return -1;;
    my $this   = driver();
    my $room   = $pl->previous_room();
    my $here   = $pl->environment();
    my $result;
    
    unless ( find_object( $room ) ) {
        notify_fail( parse_std_msg('Actions_Back_noroom' ) );
        return -1 ;
    }
    
    $verb = $here->can_reach( $room );
    if ( $verb ) {
        $result = $pl->force_to( $verb );
        unless ( $result > 0 ) {
            notify_fail( parse_std_msg('Actions_Back_ko' ) );
            return -1 ;
        }
        return 1 ;
    }
    return -1;
}

