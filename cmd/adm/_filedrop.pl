=pod

Uso: filedrop <filename> 
elimina un file

=cut

# ---------------------------------------------------------------------
sub cmd_filedrop { 
    my $me     = shift;
    my $verb   = shift;
    my $file   = shift;
    my $pl     = current_user();
    my $pwd    = $pl->custom('CurrentWorkDirectory') || '/home/'.$pl->name;
    $pwd = clean_root($pwd);

    unless( $file ) {
        notify_fail( parse_std_msg('Actions_Filedrop_ko') );
        return -1;
    }

    $file = "$pwd/$file" unless( -f $file ) ;
    
    unless( basedepth($file) > 0 ) {
        notify_fail( parse_std_msg('Actions_Filedrop_illegal', $file) );
        return -1;
    }
    
    unless( -f $file ) {
        notify_fail( parse_std_msg('Actions_Filedrop_notfound', $file) );
        return -1;
    }
    
    log_file( 'filedrop.log',"$file ". $pl->peerhost );
    
    tell_object($pl, parse_std_msg('Actions_Filedrop_ask', $file, std_msg('yes'), std_msg('no')) );

    $pl->input_to('filedrop_yes');
    $pl->custom('Unlinkfilename',$file);
    return 1;
}

# ---------------------------------------------------------------------
sub filedrop_yes { 
    my $reply    = wipe_bs(shift);
    my $pl       = current_user();
    my $match    = std_msg('yes');
    my $file     = $pl->custom('Unlinkfilename');
    if ( $reply =~ m/^\s*$match\s*/i ) {
        tell_object($pl, parse_std_msg('Actions_Filedrop_done', $file) );
        log_file( 'filedrop.log',"$file ". $pl->peerhost );
        unlink_file( $file );
    }
    else {
        tell_object($pl, parse_std_msg('Actions_Filedrop_dont', $file, $match) );
    }
}

