=pod

Uso: cp <filename> <dest>

=cut

# ---------------------------------------------------------------------
sub cmd_cp { 
    my $me     = shift;
    my $verb   = shift;
    my $file   = clean_root(shift);
    my $dest   = clean_root(shift);
    my $pl     = current_user();
    my $pwd    = $pl->custom('CurrentWorkDirectory') || '/home/'.$pl->name;
    $pwd = clean_root($pwd);

    unless( $file ) {
        notify_fail( parse_std_msg('Actions_Cp_ko'));
        return -1;
    }

    unless( $dest ) {
        notify_fail( parse_std_msg('Actions_Cp_ko'));
        return -1;
    }

    unless( basedepth($file) > 0 ) {
        notify_fail( parse_std_msg('Actions_Cp_illegal', $file) );
        return -1;
    }

    unless( basedepth($dest) > 0 ) {
        notify_fail( parse_std_msg('Actions_Cp_illegal', $dest) );
        return -1;
    }

    $file = "$pwd/$file" unless( -f $file ) ;
    unless ( -s $file ) {
        notify_fail( parse_std_msg('Actions_Cp_ko2',$file));
        return -1;
    }
       
    $dest = "$pwd/$dest" unless( -f $dest ) ;
    if ( -s $dest ) {
        notify_fail( parse_std_msg('Actions_Cp_ko3',$dest));
        return -1;
    }
    
    # cat returns 1:ok, 0:ko
    append_file( $dest, cat_str( $file ) );
    return 1;    
}

