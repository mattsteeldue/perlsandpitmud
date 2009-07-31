# Database.pm
# Created Lug 2009
# Author  flogisto

package Database;
use Commons;
use File::Copy;

=pod

=cut

# ---------------------------------------------------------------------
#
# data member methods
#
# ---------------------------------------------------------------------
sub dbidriver      { (@_)>1 ? ($_[0]->{DbiDriver}          = $_[1],$_[0]) : $_[0]->{DbiDriver}         }
sub dbimasterfile  { (@_)>1 ? ($_[0]->{DbiMasterFile}      = $_[1],$_[0]) : $_[0]->{DbiMasterFile}     }
sub dbiusername    { (@_)>1 ? ($_[0]->{DbiUsername}        = $_[1],$_[0]) : $_[0]->{DbiUsername}       }
sub dbipasswd      { (@_)>1 ? ($_[0]->{DbiPasswd}          = $_[1],$_[0]) : $_[0]->{DbiPasswd}         }
sub dbibackup      { (@_)>1 ? ($_[0]->{DbiBackupDatabase}  = $_[1],$_[0]) : $_[0]->{DbiBackupDatabase} }
sub dbh            { (@_)>1 ? ($_[0]->{Dbh}                = $_[1],$_[0]) : $_[0]->{Dbh}               }

# ---------------------------------------------------------------------
# create the database-connection-interface object
# ::new( driver, file, username, passwd );
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $driver  = shift;
    my $file    = shift;
    my $user    = shift;
    my $passwd  = shift;
    my $backup  = $_[0]? 1:0;
    my $self = {};
    bless $self, $class;

    $self->dbimasterfile( $file )
         ->dbidriver  ( $driver )
         ->dbiusername( $user )
         ->dbipasswd  ( $passwd )
         ->dbibackup  ( $backup )
         ;
    return $self;
}

# ---------------------------------------------------------------------
# ::open_database()
sub open_database {
    # open master sqlite database
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $dbiconn = $this->dbidriver();
    my $dbifile = $this->dbimasterfile();
    $dbiconn =~ s/\\t/\t/;
    $dbiconn =~ s/\\n/\n/;
    $dbiconn =~ s/\$0/$dbifile/;
    
    # daily sqlite database backup
    if ( $this->dbibackup() ) {
        my $backupf = basename($dbifile) . '_' .
                      time_to_str($curtime,'YYYYMMDD') . '.' .
                      baseextname($dbifile);
        unless ( -f $backupf ) {
            eval{ copy( $dbifile, $backupf) or die "Copy $backupf failed: $!" }
        }
    }
}

# ---------------------------------------------------------------------
# ::connect_database()
sub connect_database {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $dbiconn = $this->dbidriver();
    my $dbifile = $this->dbimasterfile();
    $dbiconn =~ s/\\t/\t/;
    $dbiconn =~ s/\\n/\n/;
    $dbiconn =~ s/\$0/$dbifile/;
    my $dbh = DBI->connect( $dbiconn, $this->dbiusername, $this->dbipasswd )
       or die "Cannot connect: " . $DBI::errstr;
    $this->dbh( $dbh );
    return $dbh;
}

# ---------------------------------------------------------------------
# ::setup_database()
sub setup_database {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $dbh     = $this->dbh();
    my $world_name = shift;
    my $sth;

    # assumes SQLite.
    log_file( 'engine.log',  "Engine SQLite" . $dbh->{sqlite_version} );

    #$dbh->func( 'now', 0, sub { return time() }, 'create_function' );
    #$dbh->func( 'sql_version', 0, sub { return $dbh->{sqlite_version} }, 'create_function' );

    $sth = $dbh->table_info( '','','parm' );
    if ( $dbh->err || ! $sth->fetch() ) {
        $dbh->do( qq[
            create view parm as
            select sqlite_version() sqlite_version
                 , datetime('now') curdatetime
                    ] ) ;
    }
    $sth = $dbh->table_info( '','','dict' );
    if ( $dbh->err || ! $sth->fetch() ) {
        $dbh->do( qq[
            create view dict as
            select name, type from sqlite_master
             where type in ('table','view')
               and name not like 'sqlite%'
               and name not in ('dict','cat','parm')
                    ]) ;
    }
    $sth = $dbh->table_info( '','','cat' );
    if ( $dbh->err || ! $sth->fetch() ) {
        $dbh->do( qq[
            create view cat as
            select * from dict
                    ]) ;
    }

    # verifies that table exists, otherwise create table
    $sth = $dbh->table_info( '','',"engine_password" );
    if ( $dbh->err || ! $sth->fetch() ) {
        $dbh->do( qq[
            create table engine_password (
            username char(64) not null primary key,
            passwd   char(64),
            newpwd   char(3) )
                    ] );
    }
    # verifies that table exists, otherwise create table
    $sth = $dbh->table_info( '','',"${world_name}_password" );
    if ( $dbh->err || ! $sth->fetch() ) {
        $dbh->do( qq[
            create table ${world_name}_password (
            username char(64) not null primary key,
            passwd   char(64) )
                    ] );
    }
    1;

}

# ---------------------------------------------------------------------
# retrieve a single password (crypted) given the username or the whole password table.
sub password {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $key     = shift || '';
    my $dbh     = $this->dbh();
    my $hpwd    = {};
    my $sql     = qq[ select username, passwd from engine_password ];
    $sql .= qq[ where username = ? ] if $key ne '' ;
    my $sth = $dbh->prepare( $sql );
    unless ( $dbh->err ) {
        $sth->execute( $key ) if $key ne '';
        $sth->execute( ) unless $key ne '';
    };
    unless ( $dbh->err ) {
        while ( my $row = $sth->fetchrow_hashref() ) {
            $hpwd->{ $row->{username} } = $row->{passwd} ;
        }
        my $passw = $hpwd->{ $key };
        $sth->finish();
        return $passw if $key ne '' ;
        return $hpwd;
    }
    $sth->finish();
    return 0;
}

1;

