=pod

Mostra le news iniziali

=cut

# ---------------------------------------------------------------------
# example
sub cmd_wiznews { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();
    my $this   = driver();

    if ( $pl->level > 0 ) {
        write_client( "\n" ) ;
        cat( getdir('dirdoc') . 'wiznews.txt' ) ;
        return 1; 
    }

    return -1;
}

