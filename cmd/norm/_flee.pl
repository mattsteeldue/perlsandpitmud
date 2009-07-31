=pod

Vedi: attack

=cut

# ---------------------------------------------------------------------
# moves an object from the inventory of current_user to the room.
sub cmd_flee { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();
    my $this   = driver();
    my $room   = find_object($pl->previous_room());
    
    # attacking check.
    return -1 unless $pl->attacking ;
    
    my $result = $pl->move( $room );
    if ( $result > 0 ) {
        $pl->force_to('look');
        return 1 ;
    }
    return -1 ;
}

