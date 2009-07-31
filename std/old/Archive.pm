# Archive.pm
# Created Oct 2007
# Author  flogisto

package Archive;

=pod

This exporter-package provide a simple basic database structure access.

 arc_msg         given a code returns the error message
 
 arc_filename    low-level: returns the filename that contains a tablename
+arc_absent      returns 0 if tablename exists, else -1 (-1712 if called without parameters).
+arc_open        low-level, returns a hash-ref from a filename (not just a tablename)
+arc_commit      low-level, closes an arc_open-ed and commit
+arc_close       low-level, closes an arc_open without commit
+arc_create      creates a tablename. args: filename, option, column list.
+arc_drop        drops a tablename. args: filename
 
*arc_set         given a tablename and a key stores the value passed.
 arc_get         given a tablename and a key returns the value. Negative integer means error.
*arc_erase       given a tablename and a key erases the entry. Last erased entry is still accessible via arc_value.
 arc_value       retains the value just referred with arc_get, arc_query or arc_erase (not with arc_set).

=cut

use strict;
##use diagnostics;
use Commons;

require Exporter;
our (
    @ISA, @EXPORT, 
);

@ISA = qw(Exporter);
@EXPORT = qw( 
    arc_msg 
    
    arc_filename
    arc_absent
    arc_create
    arc_drop
    
    arc_set
    arc_get
    arc_erase
    arc_value
    
    arc_open
    arc_commit
    arc_close
    
    arc_read
    arc_write
    arc_meta
    arc_backup

    ); 

my %opened = ();
my %hashes = ();

# ---------------------------------------------------------------------
# message list.
sub arc_msg {
    my $code = shift || 0;
    my $fun = int(-$code / 100 - 9);
    my $err = -$code % 100;
    
    my @err = ( 'unknown error',
                'duplicated key',            # -01
                'duplicated column',         # -02
                'cannot store table',        # -03
                'cannot store index',        # -04
                'cannot restore table',      # -05
                'cannot restore index',      # -06
                'table does not exist',      # -07
                'not a table file',          # -08
                'no key given',              # -09
                'table already exists',      # -10
                'too many values',           # -11
                'missing table name',        # -12
                'no column given',           # -13
                'column does not exist',     # -14
                'invalid key',               # -15
                'no value given',            # -16
                'key not found',             # -17
                'missing value',             # -18
                'insufficient privileges',   # -19
                'table under lock',          # -20
                'invalid file',              # -21
                'not an hash given',         # -22
                'file is read-only',         # -23
                'table was not under lock',  # -24
              );
              
    my @fun = (   'arc_unknown'  ,   
                  'arc_create'   ,  # 10
                  'arc_drop'     ,  # 11
                  'arc_erase'    ,  # 12
                  'arc_get'      ,  # 13
                  'arc_set'      ,  # 14
                  'arc_open'     ,  # 15
                  'arc_commit'   ,  # 16
                  'arc_absent'   ,  # 17
                  'arc_write'    ,  # 18
                  'arc_read'     ,  # 19
                  'arc_close'    ,  # 20
                  'arc_meta'     ,  # 21
                  'arc_backup'   ,  # 22
                ) ;
                
    $err = 0 if $err > $#err or $err < 0 ;
    $fun = 0 if $fun > $#fun or $fun < 0 ;
    return "$code $err[$err] ($fun[$fun]) ";
}

# ---------------------------------------------------------------------
# arc_errmsg()
my $errmsg ;
sub arc_errmsg { return $errmsg }

# ---------------------------------------------------------------------
# arc_value()
my $value ;
sub arc_value { return $value }

# ---------------------------------------------------------------------
# arc_log()
sub arc_log { 
    my $code = shift || 0;
    $errmsg = arc_msg($code);
    print "$errmsg\n";
    log_file( "archive.log", $errmsg );
    return $code;
}

# ---------------------------------------------------------------------
# arc_filename( table )
# low-level: returns the filename that contains a tablename
# filename that begins with "_" are stored in dirdbsqlite, otherwise in dirdbcsv directory
sub arc_filename { 
    my $table = shift||'dummy';
    my $dir = getdir('dirdbcsv');
    $dir = getdir('dirdbsqlite') if $table =~ /^_/ ;
    return clean_root("${dir}${table}.txt") ;
}

# ---------------------------------------------------------------------
# arc_create( table, option, fields... )
# create a file 
# arguments: filename, option, array of columns.
# column name which begins with "*" is assumed as primary-key.
# if no primary-key is specified, then the first column is assumed.
sub arc_create { 
    my $table   = shift || return -10_12;
    my $opt     = shift || 0;
    my $file    = arc_filename( $table );
    return arc_log( -10_10 ) if -e $file ; # already exists.
    my @cols    = @_ ; # list of column names.
    my %cols    = ();
    my $pkey     = '';
    foreach my $v ( @cols ) { 
        if ($v =~ /^\*(.*)/) { $v=$1; $pkey = $v }
        $v =~ s/\s+/_/g;
        $v =~ s/\W+/_/g;
        if ( defined $cols{$v} ) { 
            $errmsg = $v;
            return arc_log( -10_02 ) ; # duplicated column name
        }
        $cols{$v} = 1;
    }
    $pkey = $cols[0] if '' eq $pkey ;
    # any index ?
    my $db = { } ;
    $db->{ '#!' } = [ 'do not delete me' ];
    $db->{ '#@' } = [ 'protected with password' ] if $opt & 0x02; 
    $db->{ '#cols' } = \@cols;    
    return arc_write( $file, $db );
}

# ---------------------------------------------------------------------
# arc_drop( table )
sub arc_drop { 
    my $table   = shift || return arc_log( -11_12 );
    my $file    = arc_filename( $table ) ;
    return arc_log( -11_07 ) unless -e $file ;
    my $db = arc_read( $file );
    return arc_log( -11_05) unless ref($db) eq 'HASH' ;
    # cannot drop files that has not the special #! entry.
    return arc_log( -11_08 ) unless exists $db->{'#!'} ;
    return arc_log( -11_19 ) if exists $db->{'#@'} ;
    return arc_log( -11_20 ) if exists $opened{$file} ;
    unlink $file if basedepth("$file") > 0 ;
    # drop any index file also.
    return 0;
}

# ---------------------------------------------------------------------
# arc_erase( table, key, fieldkey )
# given a "key" and a hash-reference delete the key
# Coding/decoding is done via store_string/restore_string
sub arc_erase { 
    my $table   = shift || return arc_log( -12_12 );
    my $file    = arc_filename( $table ) ;
    return arc_log( -12_07 ) unless -e $file ;
    my $key     = shift || return -12_09; # string key
    my $db = arc_open( $table, 'u' );
    return arc_log( -12_05) unless ref($db) eq 'HASH' ;
    return arc_log( -12_19 ) if $key =~ /^#/;
    $value = 0; # global
    if ( exists $db->{$key} ) {
        $value = $db->{$key};
        delete $db->{$key} ;
        if ( arc_commit( $db ) <= -1 ) {
            arc_close( $db );
            return arc_log( -12_03 ); 
        }
        return 0;
    }
    arc_close( $db );
    return $value;
}

# ---------------------------------------------------------------------
# arc_get( table, key, filedkey )
# given a "key" returns as value the hash-reference in the dbuser
# the value hash can be nested with sub-hash and sub-arrays
# Coding/decoding is done via store_string/restore_string
sub arc_get { 
    my $table   = shift || return arc_log( -13_12 );
    my $file    = arc_filename( $table ) ;
    return arc_log( -13_07 ) unless -e $file ;
    my $key     = shift || return arc_log( -13_09 ); # string key
    my $field   = shift || '';
    my $db = arc_read( $file, '^'.$key.'$' );
    return arc_log( -13_05) unless ref($db) eq 'HASH' ;
    return arc_log( -13_17 ) unless exists $db->{$key} ;
    my $row = $db->{$key};
    $value = $row; # global
    if ( $field ) {
        return $row->{$field} if exists $row->{$field};
        return arc_log( -13_14 );
    }
    return $row ;
} 

# ---------------------------------------------------------------------
# arc_set( table, key, hash, fieldkey )
# given a "key" and a hash-reference store a "string" corresponding to
# the value of the hash.
# There are two ways: 
#  arc_set($tt,$kk,{...}) -> same as $db->{$kk} = {...}
#  arc_set($tt,$kk,$ff,$vv) -> same as $db->{$kk}->{$ff} = $vv
sub arc_set { 
    my $table   = shift || return arc_log( -14_12 );
    my $file    = arc_filename( $table ) ;
    my $key     = shift || return arc_log( -14_09 ); # string key
    my $temp    = shift || return arc_log( -14_16 ); # hash list of value
    my $val     = shift || '';
    return arc_log( -14_07 ) unless -e $file ;
    return arc_log( -14_20 ) if exists $opened{$file} ;
    my $db = arc_meta( $file, {} );
    return arc_log( -14_08) unless exists $db->{'#cols'} ;
    my @cols = @{ $db->{'#cols'} };
    if ( ref($temp) eq 'HASH' ) {
        $temp->{$cols[0]} = $key unless $temp->{$cols[0]}; # default.
        $db->{$key} = {};
        foreach my $field ( keys %{$temp} ) {
            $db->{$key}->{$field} = $temp->{$field};
        }
    }
    else { # $temp is a key-string
        unless ($val) { arc_close( $db ); return arc_log( -14_14 ) }
        $db->{$key}->{"$temp"} = $val;
    }
    arc_write( $file, $db, 'a' ); # for append!
    
    # rebuild file...
    if ( exists $db->{'#!'} && $db->{'#!'}->[1] > 1 / (1+$db->{'#!'}->[0]) ) {
        arc_backup( $file );
        arc_write( $file, arc_read( $file ) );
    }
    
    return 0;
}

# ---------------------------------------------------------------------
# arc_open()
# read a filename and returns the hash that represent.
sub arc_open { 
    my $table    = shift || return arc_log( -15_12 );
    my $file     = arc_filename( $table );
    return arc_log( -15_07 ) unless -e $file; 
    my $opt      = shift || ''; 
    $opt = 'u' if $opt eq 'w';
    $opt = 'r' if !$opt or $opt ne 'u';
    return arc_log( -15_20 ) if $opt eq 'u' && exists $opened{$file};
    return arc_log( -15_21 ) unless ( basedepth($file) > 0 && open ( HF, "$file" ) );
    my $line = <HF>;
    chomp($line);
    my @cols = split(/\t/, $line);
    my $db = {};
    while ( $line = <HF> ) {
        chomp($line);
        my @ary = split( /\t/, $line);
        my $key = $ary[0];
        next if ( $key =~ /^#/ );
        $db->{$key} = {};
        foreach my $col (@cols) { 
            $db->{$key}->{$col} = shift @ary || ''
        }
    }
    close( HF ) ;
    if ( $opt eq 'u' ) {
        $opened{$file} = "$db" ;
        $hashes{$db} = $file;
    } 
    return $db;
}

# ---------------------------------------------------------------------
# arc_commit()
# closes an arc_open committing to disk
sub arc_commit { 
    my $db       = $_[0] || return 0;
    my $file     = $hashes{$db} || 0;
    return arc_log( -16_22 ) unless ref($db) eq 'HASH';
    return arc_log( -16_24 ) unless exists $opened{$file} ;
    return arc_log( -16_07 ) unless -e $file;
    arc_backup( $file );
    arc_write( $file, $db ) ;
    delete $opened{$file} if exists $opened{$file};
    delete $hashes{$db}   if exists $hashes{$db};
    undef $_[0];
    return 0;
}

# ---------------------------------------------------------------------
# arc_absent( table )
# returns 0 if tablename exists, else -1 (-1612 if called without parameters).
sub arc_absent { -e arc_filename( shift||return arc_log( -17_12 ) ) ? 0 : -1 }

# ---------------------------------------------------------------------
# arc_write()
# data is an hash: each key is also in the first column of the table.
# value is an another hash-reference coupling columns-names to field-values
# value of a key beginning with # is an array-reference
sub arc_write{ 
    my $file = clean_root(shift); # filename
    my $db = shift; # hash of data 
    my $opt = shift || '>'; # 'a' for append.
    return arc_log( -18_03 ) unless ref($db) eq 'HASH' ;
    return arc_log( -18_21 ) unless basedepth($file) > 0 ;
    $opt = '>>' if $opt eq 'a';
    my @cols = ();
    $db = arc_meta( $file, $db ) unless exists $db->{'#cols'};
    @cols = @{ $db->{'#cols'} };
    return arc_log( -18_23 ) unless open ( HF, "$opt $file" );
    print  HF join("\t",@cols) . "\n" unless $opt eq '>>';
    foreach my $key ( sort keys %{$db} ) {
        my $row = $db->{$key};
        my @ary = ();
        if ( $key =~ /^#/ ) { 
            @ary = @{$row};
            unshift @ary, $key;
        }
        else {
            foreach my $col (@cols) { 
                push ( @ary, $row->{$col} || '' )
            }
        }
        next if $opt eq '>>' && $key =~ /^#/ ;
        print HF join("\t",@ary) . "\n" unless $key eq '#cols';
    }
    close( HF ) ;
}

# ---------------------------------------------------------------------
# arc_read
sub arc_read{
    my $file = clean_root(shift); # filename
    my $filter = shift || ''; # filter;
    return arc_log( -19_21 ) unless ( basedepth($file) > 0 && open ( HF, "$file" ) );
    my $db = {};
    my $line = <HF>;
    chomp($line);
    my @cols = split(/\t/, $line);
    $db->{'#cols'} = \@cols unless $filter && '#cols' !~ /$filter/;
    my $count = 0;
    while ( $line = <HF> ) {
        chomp($line);
        my @ary = split( /\t/, $line);
        my $key = $ary[0];
        next if $filter && $key !~ /$filter/;
        if ( $key =~ /^#/ ) {
            shift @ary; 
            $db->{$key} = \@ary unless $key eq '#cols';
        }
        else {
            $db->{$key} = {} unless exists $db->{$key};
            foreach my $col (@cols) { 
                $db->{$key}->{$col} = shift @ary || ''
            }
        }
    }
    close( HF ) ;
    return $db;
}

# ---------------------------------------------------------------------
# arc_close()
# closes an arc_open without committing to disk
sub arc_close { 
    my $db       = $_[0] || return 0;
    my $file     = $hashes{$db} || 0;
    return arc_log( -20_22 ) unless ref($db) eq 'HASH';
    delete $opened{$file} if exists $opened{$file};
    delete $hashes{$db}   if exists $hashes{$db};
    undef $_[0];
    return 0;
}

# ---------------------------------------------------------------------
# arc_meta
# file sould not already open from elsewhere.
sub arc_meta{
    my $file = clean_root(shift); # filename
    return arc_log( -21_21 ) unless ( basedepth($file) > 0 && open ( HF, "$file" ) );
    my $db = shift || {};
    my $line = <HF>;
    chomp($line);
    my @cols = split(/\t/, $line);
    $db->{'#cols'} = \@cols;
    my $count = 0;
    my $aux = {};
    while ( $line = <HF> ) {
        chomp($line);
        my @ary = split( /\t/, $line);
        my $key = shift @ary;
        next if $key eq '#cols'; # since it is read from first row of file.
        $count++ if exists $aux->{$key};
        if ( $line =~ /^#/ ) { $db->{$key} = \@ary } 
        else { $aux->{$key} = 1 }
    }
    $db->{ '#!' } = [ $. , $count ];
    close( HF ) ;
    return $db;
}

# ---------------------------------------------------------------------
# arc_backup
sub arc_backup{
    my $file = clean_root(shift); # filename
    return arc_log( -22_21 ) unless ( basedepth($file) > 0 && open ( HF, "$file" ) );
    my $newname = basedirname($file) . '/' . basefilename($file) . '.bak';
    my $rc1 = open ( HF, "$file" );
    my $rc2 = open( BK, ">$newname" );
    if ( $rc1 && $rc2 ) { print BK while <HF> }
    close ( HF ) if $rc1;
    close( BK ) if $rc2;
}

1;
