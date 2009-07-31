=pod

Uso: return
Return from "switch <username>"

=cut

# ---------------------------------------------------------------------
sub cmd_return { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();

    if ( $pl->switched_by ) { 
        
        my $who         = $pl->switched_by;
        my $environment = $pl->environment;
        my $keyname     = $pl->keyname;
        
        $pl->config( getdir('dircfgusers') . "$who" . '.cfg' );
        
        $pl->environment($environment);
        $pl->keyname    ($keyname    ); 
    
        $pl->switched_by(0); # custom
        $pl->switchee_user(0); # custom
        
        $pl->name($who);
        tell_object($pl, parse_std_msg('Actions_Return_from') );
        return 1;
    }
    else {
     
        return 0 ;
    }
}
