=pod

Uso: cat <filename> [ inizio [num] ]
Mostra il contenuto di un file o di una parte di esso. è possibile visualizzare solo <num> righe a partire da una certa riga <inizio>. 

=cut

# ---------------------------------------------------------------------
sub cmd_cat { 
    my $me     = shift;
    my $verb   = shift;
    my $file   = clean_root(shift);
    my $pl     = current_user();
    my $pwd    = $pl->custom('CurrentWorkDirectory') || '/home/'.$pl->name;
    $pwd = clean_root($pwd);

    unless( $file ) {
        notify_fail( parse_std_msg('Actions_Cat_ko'));
        return -1;
    }

    $file = "$pwd/$file" unless( -f $file ) ;
    
    unless( basedepth($file) > 0 ) {
        notify_fail( parse_std_msg('Actions_Cat_illegal', $file) );
        return -1;
    }

    # cat returns 1:ok, 0:ko
    cat_wrap( $file, @_ ) ? 1 : -1;
    
}

