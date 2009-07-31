=pod
Uso: sql
=cut

sub new { }

# ---------------------------------------------------------------------
sub do_help {
    my $dbh  = shift;
    my $what = shift;

    if ( $what =~ /\*/ ) {
        write_client <<EOT
*table_info('','','','%'); -> elenco dei tipi di oggetto presenti.
*table_info('','','%');    -> elenco degli oggetti.
*table_info('','%','');    -> elenco degli schema.
*table_info('','','P%');   -> elenco tabelle iniziano con P
*table_info('','','CAT');  -> describe
*table_info('','master','%','VIEW'); -> elenco delle VIEW master
*column_info('','TRAIN','CAT',''); -> describe tabella
*column_info('','','CAT','%'); -> describe tabella
*primary_key_info('','TRAIN','CAT'); -> describe tabella
*foreign_key_info('','TRAIN','ENTITA','','TRAIN','ENTITA_ENTITA');
*foreign_key_info('','TRAIN','','','TRAIN','ENTITA_ENTITA');
*foreign_key_info('','','','','TRAIN','ENTITA_ENTITA');
EOT
;
        return;      
    }

    write_client <<EOF
The <statement> must be a one-row-only SQL statement.
The following statemente are also recognized:
help        shows this page
version     shows SQLite version
desc <ob>   shows the "create" SQL statement of <ob>
func <arg>  does a DBI perl command \$dbh->func( <arg> )
*<xxx>      does a DBI perl command \$dbh->xxx try 'sql help *'
export <t>  table t -> t.txt
import <f>  a file f.txt -> table f
<any>       interprets an SQL statement.
   
EOF

}

# ---------------------------------------------------------------------
sub do_version {
    my $dbh  = shift;
    my $what = shift;
    write_client "SQLite ", $dbh->{sqlite_version}, "\n";
}

# ---------------------------------------------------------------------
sub do_func {
    my $dbh  = shift;
    my $what = shift;
    my $fun = $1 if $what =~ /func\s+(.*)/;
    my $sth;
    if ($fun) {
        # $dbh->func( 'inc', 1, sub { return 1+$_ }, 'create_function' );
        write_client qq{ \$sth = \$dbh->func( $fun ) } ;
        eval  qq{ \$sth = \$dbh->func( $fun ) } ;
        write_client "\n";
    }
}

# ---------------------------------------------------------------------
sub do_export {
    my $dbh  = shift;
    my $what = shift;
    my $tab = $1 if $what =~ /export\s+(.*)/;

    # ask describe
    my $sth = $dbh->table_info( '','',$tab );
    if ( $dbh->err || ! $sth->fetch() ) {
        write_client "Not found.\n";
        return 0;
    }

    my $file = getdir('dircfgcsv') . "$tab.txt" ;

    # select rows    
    $sth = $dbh->prepare( "select * from $tab" );
    $sth->execute();
    unless ( $dbh->err ) {
        my @outp = ();
        my $row = $sth->fetchrow_hashref();
        if ($row) {
            my @col = @{$sth->{NAME}};
            #print HF join("\t",@col) . "\n" unless -s "$file";
            push @outp, join("\t",@col) . "\n" unless -s "$file";
            while ($row) {
                my @val = ();
                for( my $i=0; $i<=$#col; $i++ ) {
                    push @val, $row->{ $col[$i] } ;
                }
                #print HF join("\t",@val) . "\n" ;
                push @outp, join("\t",@val) . "\n" ;
                $row = $sth->fetchrow_hashref();
            }
        } 
        ###unless ( open( HF , ">> $file" ) ) {
        ###    print "Cannot open $file.";
        ###    return 0;
        ###}
        append_file( $file, @outp ); 
    }    
    $sth->finish();
    ###close HF;
}

# ---------------------------------------------------------------------
sub do_import {
    my $dbh  = shift;
    my $what = shift;
    my $tab = $1 if $what =~ /import\s+(.*)/;

    # select rows    
    my $sth = $dbh->table_info( '','',$tab );
    if ( $dbh->err || ! $sth->fetch() ) {
        print "Destination not present";
        return;
    }

    my $file = getdir('dircfgcsv') . "$tab.txt" ;
    my @inp = cat_array( $file );
    #unless ( open( HF , "$file" ) ) { 
    unless( scalar @inp ) {
        write_client "File not found $file.\n"; 
        return 0; 
    }
    my $line = shift @inp; #<HF>;
    chomp($line);
    my @col = split(/\t/, $line);
    my $sql = "insert into $tab values ( " . ( '?, 'x$#col ) . '? ) ' ;
    $sth = $dbh->prepare( $sql );
    while ( $line = shift @inp ) { #<HF>;
        chomp($line);
        my @ary = split( /\t/, $line);
        $sth->execute( @ary );
         
    }
    #close( HF ) ;
    $sth->finish();
}

# ---------------------------------------------------------------------
sub do_select {
    my $dbh  = shift;
    my $what = shift;
    my $sth = $dbh->prepare( $what );
    $sth->execute() unless $dbh->err;
    unless ( $dbh->err ) {
        my $row = $sth->fetchrow_hashref();
        my @outp = ();
        if ($row) {
            my @col = @{$sth->{NAME}};
            push @outp, join("\t",@col), "\n";
            while ($row) {
                for( my $i=0; $i<=$#col; $i++ ) {
                    push @outp, $row->{ $col[$i] } ; 
                    push @outp, "\t" if $i < $#col;
                }
                push @outp, "\n";
                $row = $sth->fetchrow_hashref();
            }
            write_client ( @outp );
            $sth->finish();
        }
        else {    
            write_client( 'No data found.\n');
            $sth->finish();
        }
    }
}

# ---------------------------------------------------------------------
sub describe {
    my $dbh  = shift;
    my $what = shift;
    my $tab = $1 if $what =~ /desc\s+(.*)/;

    # Sqlite.
    return do_select($dbh,
       "select sql from sqlite_master where lower(name) = lower('$tab')");
    
    # Oracle.    
    my $sth = $dbh->column_info('','',uc($tab),'%');
    if ( $sth && !$dbh->err ) {
        my $row = $sth->fetchrow_hashref();
        my @outp = ();
        if ($row) {
            push @outp, $row->{ TABLE_SCHEM }, "\t";
            push @outp, $row->{ TABLE_NAME }, "\n";
            while ($row) {
                push @outp, $row->{ COLUMN_NAME }, "\t";
                push @outp, $row->{ TYPE_NAME }, "\t";
                push @outp, $row->{ COLUMN_SIZE }, "\t";
                push @outp, $row->{ DECIMAL_DIGITS }, "\t";
                push @outp, $row->{ IS_NULLABLE }, "\n";
                $row = $sth->fetchrow_hashref();
            }
            write_client ( @outp );
            $sth->finish();
        }
    }
}

# ---------------------------------------------------------------------
sub catalog_info {
    # * table_info('','','','%');     -> elenco dei tipi di oggetto presenti.
    # * table_info('','%','');        -> elenco degli schema.
    # * table_info('','','%');        -> elenco degli oggetti.
    # * table_info('','TRAIN','P%');  -> elenco tabelle di TRAIN che iniziano con P
    # * table_info('','','CAT');      -> describe
    # * table_info('','TRAIN','%','VIEW'); -> elenco delle VIEW di TRAIN
    # * column_info('','TRAIN','CAT','%'); -> describe tabella
    # * column_info('','','CAT','%'); -> describe tabella
    # * primary_key_info('','TRAIN','CAT'); -> describe tabella
    # * foreign_key_info('','TRAIN','ENTITA','','TRAIN','ENTITA_ENTITA');
    # * foreign_key_info('','TRAIN','','','TRAIN','ENTITA_ENTITA');
    # * foreign_key_info('','','','','TRAIN','ENTITA_ENTITA');
    my $dbh  = shift;
    my $what = shift;
    my $fun = $1 if $what =~ /\s*\*(.*)/;
    my $sth;
    if ($fun) {
        write_client qq{ \$sth = \$dbh->$fun }, "\n";
        eval  qq{ \$sth = \$dbh->$fun } ;
    }
    if ( $sth && !$dbh->err ) {
        my $row = $sth->fetchrow_hashref();
        my @outp = ();
        if ($row) {
            my @col = @{$sth->{NAME}};
            push @outp, join(",",@col), "\n\n";
            while ($row) {
                for( my $i=0; $i<=$#col; $i++ ) {
                    next unless $row->{ $col[$i] };
                    push @outp, $col[$i] . "=";
                    push @outp, "'".$row->{ $col[$i] }."'" ; 
                    push @outp, "\n";# if $i < $#col;
                }
                push @outp, "\n";
                $row = $sth->fetchrow_hashref();
            }
            write_client ( @outp );
            $sth->finish();
        }
        else {    
            write_client( 'No data found.\n');
            $sth->finish();
        }
    }
}

# ---------------------------------------------------------------------
sub cmd_sql { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = "@_" || '';
    my $pl     = current_user();
    
    notify_fail( 'Usage: sql <one-row-statement>\n       \'sql help\'  for help.' );
    return 0 unless $what;

    my $rc = 1;    
    my $dbh = dbi();

    {
        local $SIG{__WARN__} = sub { 
                eval { $rc = 0; notify_fail( $dbh->err . ' - ' . $dbh->errstr ) } ; 
            };
        if    ( $what =~ /^\s*help/i )   { do_help( $dbh, $what ) }
        elsif ( $what =~ /^\s*version/i ) { do_version( $dbh, $what ) }
        elsif ( $what =~ /^\s*import/i ) { do_import( $dbh, $what ) }
        elsif ( $what =~ /^\s*export/i ) { do_export( $dbh, $what ) }
        elsif ( $what =~ /^\s*select/i ) { do_select( $dbh, $what ) }
        elsif ( $what =~ /^\s*desc/i )   { describe( $dbh, $what ) }
        elsif ( $what =~ /^\s*\*/ )      { catalog_info( $dbh, $what )  }
        elsif ( $what =~ /^\s*func/ )    { do_func( $dbh, $what ) }
        else { $dbh->do( qq[ $what ] ) }
    }

    if ( $rc && $dbh->err ) {
        $rc = ( $dbh->err ? 0 : 1 );
        notify_fail( $dbh->err . ' - ' .$dbh->errstr ) ;
    }

    return $rc;
}

