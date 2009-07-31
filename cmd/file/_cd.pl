=pod

Uso: cd <directory>
Cambia directory di lavoro.

=cut

# ---------------------------------------------------------------------
sub cmd_cd { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();
    my $newdir = shift || '/home/'.$pl->name;
    my $dir    = $pl->custom('CurrentWorkDirectory') || '/home/'.$pl->name ;

    unless( $newdir ) {
        notify_fail( parse_std_msg('Actions_Cd_ko'));
        return -1;
    }

    # directory begins with / --> set directly
    if ($newdir =~ /^\// ) {
        $dir = $newdir ;
    }
    else {    
        $dir .= '/' unless ($dir eq '/' || $dir eq '~');
        $dir .= $newdir;
    }
    
    my $normdir = basenavdir($dir);
    my $depth   = basedepth($dir);
    
    if ( $dir && $normdir && $depth >=0 && ! -d $normdir ) {
        notify_fail( parse_std_msg('Actions_Cd_illegal', $dir, 
         $pl->custom('CurrentWorkDirectory')));
        return -1;
    }
    
    if ( '/'.$normdir eq $pl->custom('CurrentWorkDirectory') ) {
        notify_fail( parse_std_msg('Actions_Cd_stay', $pl->custom('CurrentWorkDirectory')));
        return -1;
    }
    
    $pl->custom('CurrentWorkDirectory', '/'.$normdir) ;
    tell_object($pl,parse_std_msg('Actions_Cd_ok','/'.$normdir)); 
    return 1;
}
