=pod

Uso: users
Presenta a video l'elenco degli utenti attualmente collegati.

Per i wizard accetta i parametri: all, logon

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
    my $tt     = time();
    
    if ( $param eq "all" && $pl->wizardhood() ) {

        ###my $dbusers = arc_open( '_driver_dbuser' );
        ###while ( my($key,$row) = each %$dbusers ) { 
        my $dbh = dbi();
        my $sth = $dbh->prepare( qq[ select * from engine_user_info ] );
        $sth->execute() unless $dbh->err;
        unless ( $dbh->err ) {
            while ( my $row = $sth->fetchrow_hashref() ) {
                my $key = $row->{ name };
                ###next if $key =~ m/^#.$/;
                next if $filter && $key !~ m/$filter/i;
                push @output, sprintf( "%-15s %3s %-15s %-16s", 
                    $row->{ peerhost   },
                    $row->{ level      }, 
                    ucfirst($key), 
                    $row->{ clientname },
                     ) 
                    . "\n"  ;
            }
        } 
        $sth->finish();
        push @header, "\n"  ;
        push @header, "-"x $pl->wrap_col . "\n" ;
        push @header, "Ci sono " . scalar(@output) . " utenti.\n";
        push @header, "-"x $pl->wrap_col . "\n"  ;
        push @header, sprintf( "%-15s %3s %-15s %-16s", 
            "IP address" , # peerhost(),
            "Liv" , # level, 
            "Nome", 
            "Host", # clientname(),
             ) 
            . "\n"  ;
        push @header, "-"x $pl->wrap_col . "\n"  ;
        push @footer, "-"x $pl->wrap_col . "\n"  ;
        ###undef $dbusers; 
    }

    elsif ( $param eq "logon" && $pl->wizardhood() ) {

        ###my $dbusers = arc_open( '_driver_dbuser' );
        ###while ( my($key,$row) = each %$dbusers ) { 
        my $dbh = dbi();
        my $sth = $dbh->prepare( qq[ select * from engine_user_info ] );
        $sth->execute() unless $dbh->err;
        unless ( $dbh->err ) {
            while ( my $row = $sth->fetchrow_hashref() ) {
                my $key = $row->{ name };
                ###next if $key =~ m/^#.$/;
                next if $filter && $key !~ m/$filter/i;
                my $dt = time_to_str( $row->{ logontime }, "YYYY-MM-DD HH.MI.SS" );
                push @output, sprintf( "%-19s %3s %-15s %-8s %-17s", 
                    $dt     ,
                    $row->{ level }, 
                    ucfirst($key)  , 
                    $row->{ race  },
                    $row->{ land  },
                     ) 
                    . "\n"  ;
            }
        } 
        $sth->finish();
        push @header, "\n"  ;
        push @header, "-"x $pl->wrap_col . "\n" ;
        push @header, "Ci sono " . scalar(@output) . " utenti.\n";
        push @header, "-"x $pl->wrap_col . "\n"  ;
        push @header, sprintf( "%-19s %3s %-15s %-8s %-17s",
            "Last logon" , 
            "Liv"    , # $ level, 
            "Nome"  , 
            "Razza" , # race
            "Terra" , # land,
             ) 
            . "\n"  ;
        push @header, "-"x $pl->wrap_col . "\n"  ;
        push @footer, "-"x $pl->wrap_col . "\n"  ;
        ###undef $dbusers; 
    }

    tell_object( $pl, @header );
    tell_object( $pl, sort @output );
    tell_object( $pl, @footer );

    return 1;
}

