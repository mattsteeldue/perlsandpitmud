=pod

Uso: look
Comando base per ottenere la descrizione dell'ambiente ove ti trovi. Si può abbreviare con "l".

=cut

# ---------------------------------------------------------------------
# displays the description of the room you are.
# giving the "Title" of the room (short), the long description,
# the obvious exits, the objects, the mobiles and the users present.
sub cmd_look { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift || 0;
    $what = shift if $what eq 'at';
    my $which  = shift || 1;
    my $this   = driver();
    my $pl     = current_user();
    my $room   = $pl->environment;
    
    
    
    unless( $room ) { 
        notify_fail( parse_std_msg('Actions_no_environment') );
        return -1 
    }

    # look at object
    if ( $what ) {
        if ( $room->light <= 0 ) { 
            tell_object( $pl, parse_std_msg('Actions_it_is_dark' ) );
            return 1 
        }
        my $ob = $room->query_detail( "$what" ) ;
        if ( $ob ) {
            tell_object( $pl, "$ob\n" );
            return 1;
        }
        
        $which = 1 if $which =~ m/\D/;
        
        $ob = find_object( $what, 0, $which - 1 );
        if( ref($ob) && $ob->isa('Object') ) {   
            my ($me,$ro,$ta) = $ob->examine_object( $what );
            tell_object( $pl, wrap_string($me)."\n" ) if $me;
            say ( $ro, $pl, $ob ) if $ro;
            tell_object( $ob, $ta ) if $ta;
            return 1;
        }
        else { 
            notify_fail( parse_std_msg('Actions_Look_no_obj', $what) );
            return -1;
        }
    }

    # room.
    my ($room_desc, $ot, $ta) = $room->examine_object() ; 
    
    # send all to the client
    tell_object( $pl, $room_desc );
    
    if ( $pl->debugging & 256 ) { 
        look_navigate( $room, 0 ) 
    }
   
    return 1;
}

sub look_navigate {
    my $cont = shift;
    my $n = shift;
    my $pl = current_user();
    while ( my ($key,$value) = each %{$cont} ) { 
        if ( ref($value) eq 'HASH' ) { 
            if ( $key eq 'Inventory' ) { 
                tell_object( $pl, "$key=((" );
                look_navigate ( $value, $n + 1 ) ;
                tell_object( $pl, ")); " );
            }
        }
        else {
            tell_object( $pl, "$key=$value; " );
        }
    }    
}
