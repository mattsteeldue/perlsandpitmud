=pod

Uso: tail <filename> [num]
Mostra le ultime n righe di un file.

=cut

# ---------------------------------------------------------------------
sub cmd_tail { 
    my $me     = shift;
    my $verb   = shift;
    my $file   = clean_root(shift);
    my $num    = shift || 10;
    my $pl     = current_user();

    unless( $file ) {
        notify_fail( parse_std_msg('Actions_Cat_ko'));
        return -1;
    }

    # cat returns 1:ok, 0:ko
    cat_wrap( $file, -$num ) ? 1 : -1;
    
}

