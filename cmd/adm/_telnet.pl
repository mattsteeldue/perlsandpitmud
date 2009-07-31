=pod

Uso: telnet host port

=cut

# ---------------------------------------------------------------------
sub cmd_telnet { 
    my $me     = shift;
    my $verb   = shift;
    my $host   = shift;
    my $port   = shift || 23;

    unless( $host ) {
        notify_fail( parse_std_msg('Actions_Telnet_ko') );
        return -1;
    }

    my $pl = current_user();
    my $term = clone_object( 'clonable/telnet_terminal', $pl );

    unless( $term ) {
        notify_fail( parse_std_msg('Actions_Telnet_ko2') );
        return -1;
    }

    $pl->custom('TelnetTerminal',$term);
    $pl->input_to('main_telnet');
    return 1;
}

# ---------------------------------------------------------------------
sub main_telnet { 
    my $pl     = current_user();
    my $line   = $pl->inputline();
    my $term   = $pl->custom('TelnetTerminal');

    if ( ref($term) && $term->isa('Object') ) {
        $pl->input_to('main_telnet');
        $term->stdin( $line );
        return 1;
    }
    return -1;
}

    
