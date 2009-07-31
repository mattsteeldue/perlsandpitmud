=pod

Uso: fileput [option] <filename> 
Va in append su un file attingendo l'input dal terminale. 
Termina il file la sequenza '***' o per timeout.
E' un metodo rapido per aggiornare un file tramite il terminale in tre passi:
1. Dare il comando 'fileput <filename>': il sistema entra in attesa di righe di testo
2. Incollare in un sol colpo tutto il file sul terminale
3. Dare invio dopo qualche secondo o concludere il file con '***'

=cut

# ---------------------------------------------------------------------
sub cmd_fileput { 
    my $me     = shift;
    my $verb   = shift;
    my $option = '';
       $option = shift if (@_)>1 && substr($_[0],0,1) eq '-';
    my $file   = shift;
    my $pl     = current_user();
    my $pwd    = $pl->custom('CurrentWorkDirectory') || '/home/'.$pl->name;
    $pwd = clean_root($pwd);

    unless( $file ) {
        notify_fail( parse_std_msg('Actions_Fileput_ko') );
        return -1;
    }

    $file = "$pwd/$file" unless( -f $file ) ;
    
    log_file( 'fileput.log',"$file ". $pl->peerhost );
    
    tell_object($pl, parse_std_msg('Actions_Fileput_start', $file) );

    $pl->input_to('fileput_line');
    $pl->custom('FTPfilename',$file);
    $pl->custom('FTPfilecontent', []);
    $pl->custom('FTPtime', time());
    $pl->custom('FTPoption', $option);
    return 1;
}

# ---------------------------------------------------------------------
sub fileput_line { 
    my $line     = shift;
    my $pl       = current_user();
    my $option   = $pl->custom('FTPoption');

    # something has been trasmitted, and timeout has expired or ***.
    if ( scalar(@{$pl->custom('FTPfilecontent')}) && 
        (time() > $pl->custom('FTPtime') + getsetup('FileputTimeout') || $line eq '***' ) ) {
        my $file = $pl->custom('FTPfilename');
        tell_object($pl, parse_std_msg('Actions_Fileput_done', $file) );
        ##pop @{$pl->custom('FTPfilecontent')}; # remove last empty line...
        unlink_file( $file) if $option eq '-l';
        append_file( $file, @{$pl->custom('FTPfilecontent')} );
        return 1;
    }
    
    $pl->input_to('fileput_line');
    $pl->custom('FTPtime', time());
    push @{$pl->custom('FTPfilecontent')}, "$line\n" ;
}

