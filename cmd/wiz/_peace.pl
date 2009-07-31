=pod

Vedi attack.
Impone la pace immediatamente

=cut

# ---------------------------------------------------------------------
sub cmd_peace { 
    my $me     = shift;
    my $verb   = shift;

    my $this   = driver();
    my $pl     = current_user();
    my $room   = $pl->environment;

    say( parse_std_msg('Actions_Peace_now') );
    
    my %combat = ();
    # search combat object pointed by any living object in the room
    foreach my $ob ( @{$room->inventory} ) { 
        if ( ref($ob) && $ob->isa('Living') && ref($ob->combat) ) {
            $combat{ $ob->combat } = $ob->combat();
        }
    }   
    # for safety, reset living object pointers anyway.
    foreach my $ob ( @{$room->inventory} ) { 
        if ( ref($ob) && $ob->isa('Living') ) {
            $ob->attacking( 0 ) ;
            $ob->combat( 0 );
        }
    }   
    # destroy every combat object
    foreach my $combat ( values %combat ) { 
        print "$combat\n";
        $combat->destroy() if ref( $combat );
    }
    return 1;    
}

