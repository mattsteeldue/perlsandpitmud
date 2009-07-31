=pod

Uso: home
Equivale a goto <workroom>

=cut

# ---------------------------------------------------------------------
sub cmd_home { 
    my $me      = shift;
    my $verb    = shift;
    my $pl      = current_user();
    my $where   = getdir('dirhome') . $pl->name . '/workroom';

    my $result = $pl->move( $where );
    
    if ( $result > 0 ) {
        tell_room( 
            find_object($pl->previous_room), 
            parse_string( $pl->message_home ) . "\n" );
        say( parse_string( $pl->message_tin() ), $pl );
        $pl->force_to( 'look' );
    }
    else {
        notify_fail( parse_std_msg('Actions_Home_ko'));
        return -1;
    }
}
