=pod

Uso: score

=cut

# ---------------------------------------------------------------------
sub cmd_score { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift;
    my $pl     = current_user();
    my $ob     = 0;

    do_command( "examine " . $pl->name );
    return 1; 
}
