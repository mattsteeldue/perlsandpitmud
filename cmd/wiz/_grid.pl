=pod

Uso: grid <x> <y> <z> <grid>
Muove l'utente verso il luogo indicato. 
La destinazione viene espressa in coordinate e nome della griglia.

=cut

# ---------------------------------------------------------------------
sub cmd_grid { 
    my $me      = shift;
    my $verb    = shift;
    my $x       = shift;
    my $y       = shift;
    my $z       = shift || 1;
    my $grid    = shift;
    my $direct  = std_msg('away');
    my $this    = driver();
    my $pl      = current_user();
    my $dest;
    my $result;
    
    my $room = here();
    if ( ref($room) && $room->isa('VirtualRoom') ) {
        $grid = $room->grid_name();
    }

    unless ( $grid && $x && $y ) {
        notify_fail( parse_std_msg('Actions_Grid_ko'));
        return -1;
    }        
  
    if ( $x < 0 or $y < 0 ) {
        $x = abs($x) * 4 - 2;
        $y = abs($y) * 4 - 2;
    }

    if ( $x < 1 || $x > $room->max_coord_x ||
         $y < 1 || $y > $room->max_coord_y ||
         $z < 1 || $z > $room->max_coord_z ) {
        notify_fail( parse_std_msg('Actions_Grid_ko2', $room->grid_name,
            $room->max_coord_x, $room->max_coord_y, $room->max_coord_z ) );
        return -1;
    }        

    my $where = basedirname( $room->module() ) . "/${grid}_${x}_${y}";
    tell_object( $pl, "$where\n" );
    
    # search via effective object name 
    $dest = find_object(effective_file_name( $where )) unless $dest;
    
    if ( $dest == $pl->environment ) {
        notify_fail( parse_std_msg('Actions_Grid_here'));
        return -1;
    }

    $result = $pl->move( $where );
    
    if ( $result > 0 ) {
        tell_room( 
            find_object($pl->previous_room), 
            parse_string( $pl->message_tout(), $direct ) );
        say( parse_string( $pl->message_tin(), $direct ), $pl );
        $pl->force_to( 'look' );
        return 1;
    }

    notify_fail(parse_std_msg('Actions_Grid_dest'));
    return -1;
}
