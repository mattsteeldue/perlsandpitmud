=pod

Usage: terrazza
Uso: terrazza
Chi ha appena iniziato a girare da queste parti (newbie) tendono a perdersi facilmente.
Il comando 'terrazza' consente di essere teletrasportati sulla terrazza di Salazar (il luogo di inizio non appena si entra nel Mondo Emerso).

=cut

# ---------------------------------------------------------------------
# moves to previous room
sub cmd_terrazza { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user() || return -1;;
    my $this   = driver();
    my $here   = $pl->environment();
    my $result;
    
    if ( $pl->level() > 1 && !$pl->wizardhood() ) {
        notify_fail( parse_std_msg('Actions_Terrazza_ko' ) );
        return -1 ;
    }
    $result = $pl->move( $this->initial_room() ) ;
    return -1 if $result < 1;
    tell_object( $pl, parse_std_msg('Actions_Terrazza_ok' ) );    
    $pl->force_to('look');
    return 1;
}

