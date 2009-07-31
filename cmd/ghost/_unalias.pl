=pod

Uso: unalias
Serve per eliminare un 'alias' precedentemente definito con 'alias'.
Insieme a 'alias' consente di definire dei nuovi comandi.

=cut

# ---------------------------------------------------------------------
sub cmd_unalias { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift || 0;
    my $pl     = current_user();

    unless( $what ) {
        notify_fail( parse_std_msg('Actions_Unalias_ko'));
        return -1;
    }

    if ( exists( $pl->alias->{$what}) ) {
        delete $pl->alias->{ $what };
        notify_fail( parse_std_msg('Actions_Unalias_drop', $what) );
        return -1;
    }
    else {    
        notify_fail( parse_std_msg('Actions_Unalias_none',$what ) );
        return -1;
    }

    return 1
}
