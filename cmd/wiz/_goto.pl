=pod

Uso: goto <where>
Muove l'utente verso il luogo indicato. Il parametro <where> deve individuare un file completo di path. 

=cut

# ---------------------------------------------------------------------
sub cmd_goto { 
    my $me      = shift;
    my $verb    = shift;
    my $where   = shift;
    my $direct  = shift || std_msg('away');
    my $this    = driver();
    my $pl      = current_user();
    my $dest;
    my $result;
    
    unless ( $where ) {
        notify_fail( parse_std_msg('Actions_Goto_ko'));
        return -1;
    }        

    $dest = find_user( $where );
    $dest = find_living( $where ) unless $dest;
    # search via effective object name (or username)
    $dest = find_object(effective_file_name( $where )) unless $dest;
    
    # search among all living objects: useful for mobs
    unless ( ref( $dest ) ) {
        my @people = values %{ $this->objects };
        foreach my $object ( @people ) {
            next unless $object->living();
            if ( $object->id( $where) ) {
                $dest = $object;
                last;
            }
        }
    }

    if ( ref($dest) && $dest->isa('Living') ) {
        $dest = $dest->environment;
    }

    if ( $dest == $pl->environment ) {
        notify_fail( parse_std_msg('Actions_Goto_here'));
        return -1;
    }
    
    if ( ref($dest) && $dest->isa('Room') ) {
        $result = $pl->move( $dest );
    }
    else {
        $result = $pl->move( $where );
    }
    
    if ( $result > 0 ) {
        tell_room( 
            find_object($pl->previous_room), 
            parse_string( $pl->message_tout(), $direct ) );
        say( parse_string( $pl->message_tin(), $direct ), $pl );
        $pl->force_to( 'look' );
        return 1;
    }

    notify_fail(parse_std_msg('Actions_Goto_dest'));
    return -1;
}
