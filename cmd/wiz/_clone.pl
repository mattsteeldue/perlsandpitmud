=pod

Uso: clone <filename> [silenzioso]
Crea un oggetto o un mob a partire dal <filename> indicato. Il filename deve individuare un file comprensivo di path. L'oggetto appena clonato viene messo nel tuo inventario, ma un mostro viene mosso nella stanza in cui ti trovi. 

=cut

# ---------------------------------------------------------------------
sub cmd_clone { 
    my $me      = shift;
    my $verb   = shift;
    my $file    = shift; # file name
    my $pl      = current_user();

    # only interactive can
    return -1 unless $pl->isa('User');

    # only wizards can     
    return -1 unless $pl->wizardhood;

    unless( $file ) {
        notify_fail( parse_std_msg('Actions_Clone_ko'));
        return -1;
    }
    
    # call creation of the object
    my $ob = clone_object( $file, @_ );
    if( ref($ob) ) {
        my $what = $ob->short() || $file;
        my $result;
        say( parse_std_msg('Actions_Clone_clones', $what), $pl ) ;
        tell_object( $pl, parse_std_msg('Actions_Clone_clone', $what ) ) ;
        $result = $ob->move( $pl ) unless $ob->cannot_get();
        $result = $ob->move( $pl->environment() ) if $ob->cannot_get();
        if ( $result < 1 ) {
            $ob->trans_object_in( the_void() );
            notify_fail( parse_std_msg('Actions_Clone_wrong', $file, $result));
            return -1;
        }
        return 1;
    }
    else {
        notify_fail( parse_std_msg('Actions_Clone_cannot', $file));
        return -1
    }
}

1;
