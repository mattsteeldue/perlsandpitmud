=pod

Per interagire con gli oggetti mobili hai a disposizione i seguenti comandi; alcuni comandi sono disponibili in due lingue, italiano e inglese.

- prendi  - get     - per prendere un oggetto
- lascia  - drop    - per lasciare un oggetto
- dai     - give    - per dare un oggetto a qualcuno
- esamina - examine - per esaminare un oggetto disponibile
- i       - inventory - lista degli oggetti che stai portando.

=cut

# ---------------------------------------------------------------------
sub cmd_examine { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift || 0;
    my $which  = $_[0] || -1;
    my $this   = driver();
    my $pl     = current_user();
    my $room   = $pl->environment;

    unless( $what ) {
        notify_fail( parse_std_msg('Actions_Examine_no_what') );
        return -1;
    }

    if ( $room->light <= 0 ) { 
        tell_object( $pl, parse_std_msg('Actions_it_is_dark' ) );
        return 1 
    }

    if ( $pl->ghost() ) {
        notify_fail( parse_std_msg('NotifyGhost') ) ;
        return -1;
    }
    
    my $ob = 0;
    $which = 1 if $which =~ m/\D/;
    $ob = find_object( $what, $pl, abs($which) - 1) unless ref($ob);
    $ob = find_object( $what, $room, abs($which) - 1) unless ref($ob);

    if( ref($ob) && $ob->isa('Object') ) {   
        my ($me,$ro,$ta) = $ob->examine_object( $what );

        tell_object( $pl, "$me\n" ) if $me;
        say ( $ro, $pl, $ob ) if $ro;
        tell_object( $ob, $ta ) if $ta && $ob != $pl;
        
        return 1;
    }

    $ob = $pl->environment->query_detail( "$what", @_ );
    
    # conventionally EOL is returned by "custom" detail function.
    # that function must display everything to pl and room.
    return 1 if $ob eq "\015\012" or $ob eq "\n"; 
    
    if( $ob ) {
        tell_object( $pl, wrap_string("$ob")."\n" );
        say ( parse_std_msg('Action_Examine_do', $what), $pl );
        return 1;
    }

    notify_fail( parse_std_msg('Actions_Examine_ko', $what) ) if( abs($which) == 1 );
    notify_fail( parse_std_msg('Actions_Examine_ko2', $what) ) unless( abs($which) == 1 );
    return -1   
}

