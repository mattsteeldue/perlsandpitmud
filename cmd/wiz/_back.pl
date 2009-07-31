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
    
    if ( $pl->wizardhood() ) {
        $result = $pl->move( $room ); 
        if ( $result > 0 ) {
            tell_room( $here, parse_string( '$n torna indietro.\n' ) );
            say( parse_string( $pl->message_in(), $verb ), $pl );
            $pl->force_to('look');
            return 1 ;     
        }
    }
    
    notify_fail( parse_std_msg('Actions_Back_ko' ) );
    return -1 ;
}

