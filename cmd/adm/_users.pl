=pod

Uso: users
Presenta a video l'elenco degli utenti attualmente collegati.

Per gli admin accetta i parametri: band

=cut

# ---------------------------------------------------------------------
###use Archive;
sub cmd_users { 
    my $me     = shift;
    my $verb   = shift;
    my $param  = shift || return 0;
    my $filter = shift || 0;
    my $this   = driver();
    my $pl     = current_user();
    my @header = ();
    my @output = ();
    my @footer = ();
    my $ob;
    my $time   = time();
    
    if ( $param eq "band" && $pl->wizardhood() && $pl->administrator() ) {

        ###my $dbusers = arc_open( '_driver_dbuser' );
        ####my $dbusers = {};
        ####restore_config( $dbusers, getdir('dirdbsqlite') . "_driver_dbuser.cfg" ) || return 0;
        my $totbandup = 0;
        my $totbanddn = 0;
        ###while ( my($key,$row) = each %$dbusers ) { 
        my $dbh = dbi();
        my $sth = $dbh->prepare( qq[ select * from engine_user_info ] );
        $sth->execute() unless $dbh->err;
        unless (  $dbh->err ) {
            while ( my $row = $sth->fetchrow_hashref() ) {
                my $key = $row->{ name };
                ###next if $key =~ m/^#.$/;
                next if $filter && $key !~ m/$filter/i;
                my $ipaddr = $row->{ peerhost      } || '<unknown>' ;
                my $banddn = $row->{ bandwidthdown } || 0;
                my $bandup = $row->{ bandwidthup   } || 0;
                $totbanddn += $banddn;
                $totbandup += $bandup;
                push @output, sprintf( "%3s %-15s %10.2f %10.2f", 
                    $row->{ level }, 
                    ucfirst($key), 
                    $banddn / 1048576, # band down
                    $bandup / 1048576, # band up
                     ) 
                    . "\n"  ;
            }
        } 
        $sth->finish();
        push @header, "\n"  ;
        push @header, "-"x $pl->wrap_col . "\n" ;
        push @header, "Ci sono " . scalar(@output) . " utenti.\n";
        push @header, "-"x $pl->wrap_col . "\n"  ;
        push @header, sprintf( "%3s %-15s %10s %10s %s", 
            "Liv" , # $ level, 
            "Nome", 
            "Band down" , 
            "Band up",
            "(MB)",
             ) 
            . "\n"  ;
        push @header, "-"x $pl->wrap_col . "\n"  ;
        push @footer, "-"x $pl->wrap_col . "\n"  ;
        push @footer, sprintf( "%-19s %10.2f %10.2f", 
            'Total bandwidth',
            $totbanddn/ 1048576, # band down 
            $totbandup/ 1048576, # band up
            ) . "\n";
        ###undef $dbusers; 
        tell_object( $pl, @header );
        tell_object( $pl, sort @output );
        tell_object( $pl, @footer );
    
        return 1;
    }
    return 0;
}

