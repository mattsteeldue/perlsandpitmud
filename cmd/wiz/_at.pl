=pod

Uso: at <username> <command>
Esegue <command> come se fossi nella stessa stanza di <username>

=cut

# ---------------------------------------------------------------------
sub cmd_at { 
    my $me    = shift;
    my $verb  = shift;
    my $who   = shift; 
    my @said  = @_;

    $who = lc($who);
    
    my $this     = driver();
    my $pl       = current_user();
    my $ob       = find_object( $who );

    # only interactive can
    return -1 unless $pl->isa('User');
    
    # only wizards can     
    return -1 unless $pl->wizardhood(); # silently returns

    unless ( $who && (@_)>0 ) {
        notify_fail( parse_std_msg('Actions_At_ko'));
        return -1;
    }        

    if ( $ob == $pl ) {
        notify_fail( parse_std_msg('Actions_At_self'));
        return -1;
    }

    unless ( ref($ob) ) {
        notify_fail( parse_std_msg('Actions_At_nowho',ucfirst($who) ));
        return -1;
    }

    my $saved_environment = $pl->environment;

    $pl->environment( $ob->environment );
    do_command( @said );
    $pl->environment( $saved_environment );

    return 1;    

}
