# Commons.pm
# Created Aug 2006
# Author  flogisto

package Commons;

=pod

=head1 NAME

Commons - Basic library

=head1 DESCRIPTION

This package offers all basic function needed by any other object in the mud.


=head2 Utility

ansi_clear              gives \e[0m 
getcolor                Returns the color named by parameter
getdaemon               Returns the name of a named daemon
getdir                  Returns the directory named by parameter
getsetup                Returns a setup value.
max                     useful max
min                     useful min
number_in_letter        gives the number in letter
pos_array               returns the index of the element in the array or -1 for not found.
remove_from_array       tries to remove element from array.
roll_dice
std_msg                 return a standard message (language configurable in message.cfg)
time_to_str             converts a time in string

=head2 File 

append_file             append data to a file
append_file_trim        append data to a file
rename_file             rename a file
unlink_file             unlink a file, always saves a backup
basedirname             given a filename extracts the directory part:  /dd/nn.ee -> /dd
baseextname             given a filename extracts the extension part: /dd/nn.ee -> ee
basefilename            given a filename extracts the name part: /dd/nn.ee --> nn
basefileextname         given a filename extracts the name part without extension: /dd/cc/nn.ee --> nn
basename                given a filename extracts the part before the dot-extension: /dd/nn
basenavdir              given a filename and a relpath, resolves any leading '..' 
basedepth               given a filename gives the effective depth.
cat                     sends a file (or a part of it) to the client
cat_array               sends a file to an array
cat_str                 sends a file to a string
cat_wrap                sends a file to the client wrapped 
clean_root              removes any / in the beginning of pathname
effective_file_name     gives the true filename, relative to somewhat
log_file                append a string to the logfile specified.

=head2 Config

restore_config          configure the object passed by reference using the data that follows
restore_string          configure the object passed by reference using the data that follows
restore_string_deep     recursive called by restore_string.
restore_element         single element restore, called by restore_string_deep 
store_config            given an hash-reference stores it to a file. (reverse of restore_config)
store_string            given an hash-reference returns an array representing its config file
store_string_deep       recursive called by store_string.
store_element           given an hash-reference returns an element representing it in the config file

=head2 User-Client related

client_to_user          given a ref-to-client returns the ref-to-user that own it.
current_client          the client currently being served
current_user            the user currently being served
quit_all_clients        quits everybody
quit_client             given a ref-client quits and cleans up the user  
save_all_users          stores all users' configuration
save_user               stores user's configuration
user_exists             true if username exists
username_to_client      given a user-name returns the ref-to-client used by.

=head2 Core

call_other              call function in other object
call_out                make a delayed call_other. First parameter is the delay in seconds.
remove_call_out         tries to remove a previous call_out
connections             ref list of clients
cx                      experimental 
daemon                  returns a reference to a named daemon; calls func within a daemon
dbi                     reference to current DBI connection
csv                     experimental
driver                  pointer to the Engine object
load_module             load a module in memory.
register_object         register the object in the muddriver  
showcomperr             prepare message of last compile error to client
stack_frame             return the stack frame image.
unload_module           reverse of load_module
unregister_object       reverse of register_object

=head2 Parsing and I/O

notify_fail             set the current user fail-message
parse_alias             parses user's alias definitions
parse_color             replaces {colors} to Ansi colors
parse_std_msg           parse_string of std_msg.
parse_string            parse string susbstituting some symbols with their values.   
wipe_accent             removes accented vouels
wipe_ansi               removes ANSI escape characters
wipe_bs                 remove BS from the string applying them to it
wipe_crlf               removes all CR or LF
wrap_at                 given an array returns another array wrapped within n col (keeps into account escape char)
wrap_parse              wrap_string of parse_string
wrap_string             given a string, reformats for current users wrap col.
wrap_string_user        given a string, reformat it using wrap_at and specified user's wrap col
write_client            this function is not snooped
write_debug             same of write_client for debugging purpose
write_other             same of write_client but must specify which client.
write_parsed            uses parse_string and sends result to write_client
write_snoopees          sends string to snoopees

=head2 Object Interface Library

clone_object            clones an object given the filename.
do_command              tries to execute a command as given by the user
find_user               given an user-name returns its ref-object
find_living             given an living-name returns its ref-object
find_object             given an object-name returns its ref-object 
here                    The room you are.
myself                  this player
say
shout
tell_object
tell_room
the_void                pointer to the void room

=head2 Private

alert_antivirus
alert_admin
include_file
ztest

=cut


#use strict qw(subs vars refs);

##use diagnostics;
require Exporter;
our (
    @ISA, @EXPORT, 
);


# EOL, Ansi constants.
my (    
    $EOL, 
    $RESET, $NORMAL, 
    $BOLD, $FAINT, $ITALIC, $UNDERLINE, $UNDERSCORE, $BLINK, $BLINKFAST, $NEGATIVE, $CONCEALED, 
    $UNDERLINE2, $NOBOLD, $NOFAINT, $NOUNDERLINE, $NOBLINK, $POSITIVE, $REVEAL,
    $BLACK,    $RED,    $GREEN,    $YELLOW,    $BLUE,    $MAGENTA,    $CYAN,    $WHITE,
    $Black,    $Red,    $Green,    $Yellow,    $Blue,    $Magenta,    $Cyan,    $White,
    $black,    $red,    $green,    $yellow,    $blue,    $magenta,    $cyan,    $white,
    $ON_BLACK, $ON_RED, $ON_GREEN, $ON_YELLOW, $ON_BLUE, $ON_MAGENTA, $ON_CYAN, $ON_WHITE, 
    $CLS,
) ;

    # LF-CR.
    $EOL = "\015\012";

    # Ansi colors.
    $RESET       = "\e[0m" ;       $NORMAL      = "\e[0m" ;
    $BOLD        = "\e[1m" ;       $NOBOLD      = "\e[22m" ; 
    $FAINT       = "\e[2m" ;       $NOFAINT     = "\e[22m" ; 
    $ITALIC      = "\e[3m" ;       
    $UNDERLINE   = "\e[4m" ;       $UNDERSCORE  = "\e[4m" ;   # unsupported.     
    $UNDERLINE2  = "\e[21m" ;      $NOUNDERLINE = "\e[24m" ;  # unsupported.
    $BLINK       = "\e[5m" ;       $NOBLINK     = "\e[25m" ;  # unsupported.
    $BLINKFAST   = "\e[6m" ;       
    $NEGATIVE    = "\e[7m" ;       $POSITIVE    = "\e[27m" ;
    $CONCEALED   = "\e[8m" ;       $REVEAL      = "\e[28m" ;  # unsupported.
    
    $BLACK      = "\e[30m" ;       $ON_BLACK   = "\e[40m" ;
    $RED        = "\e[31m" ;       $ON_RED     = "\e[41m" ; 
    $GREEN      = "\e[32m" ;       $ON_GREEN   = "\e[42m" ; 
    $YELLOW     = "\e[33m" ;       $ON_YELLOW  = "\e[43m" ; 
    $BLUE       = "\e[34m" ;       $ON_BLUE    = "\e[44m" ; 
    $MAGENTA    = "\e[35m" ;       $ON_MAGENTA = "\e[45m" ; 
    $CYAN       = "\e[36m" ;       $ON_CYAN    = "\e[46m" ; 
    $WHITE      = "\e[37m" ;       $ON_WHITE   = "\e[47m" ; 
    
    $Black      = "\e[1m\e[30m" ;  $black      = "\e[0m\e[30m" ;
    $Red        = "\e[1m\e[31m" ;  $red        = "\e[0m\e[31m" ;
    $Green      = "\e[1m\e[32m" ;  $green      = "\e[0m\e[32m" ;
    $Yellow     = "\e[1m\e[33m" ;  $yellow     = "\e[0m\e[33m" ;
    $Blue       = "\e[1m\e[34m" ;  $blue       = "\e[0m\e[34m" ;
    $Magenta    = "\e[1m\e[35m" ;  $magenta    = "\e[0m\e[35m" ;
    $Cyan       = "\e[1m\e[36m" ;  $cyan       = "\e[0m\e[36m" ;
    $White      = "\e[1m\e[37m" ;  $white      = "\e[0m\e[37m" ;
    
    $CLS        = "\e[2J" ;


# ---------------------------------------------------------------------
#
# Export
#
# ---------------------------------------------------------------------
@ISA = qw(Exporter);
@EXPORT = qw( 
    ansi_clear append_file  
    basedepth basedirname baseextname basefileextname basefilename basename basenavdir 
    call_other call_out cat cat_array cat_str cat_wrap client_to_user 
    clone_object connections current_client current_user clean_root cx csv
    daemon dbi  do_command  driver 
    effective_file_name  
    find_living find_object find_user 
    getcolor getdaemon  getdir getsetup 
    here  
    load_module log_file 
    max min myself  
    notify_fail number_in_letter  
    parse_alias  parse_color parse_std_msg parse_string pos_array 
    quit_all_clients quit_client 
    register_object remove_from_array restore_config restore_element  
    restore_string roll_dice rename_file remove_call_out
    save_all_users save_user say shout showcomperr showwarnerr 
    stack_frame  std_msg store_config store_element store_string 
    tell_object tell_room the_void time_to_str 
    unlink_file unload_module unregister_object user_exists username_to_client 
    wipe_accent wipe_ansi wipe_bs wipe_crlf wrap_at wrap_parse wrap_string 
    write_client write_debug  write_other write_parsed write_snoopees 
    ztest  
);


# ---------------------------------------------------------------------
my $muddriver ;               # accessible only via driver()
my $databasehandle ;          # accessible only via database()
my $csvdatabasehandle ;       # accessible only via database()
my $include_progr = 0;        # sequence for temporary pl
my $included_filename = {} ;  # temp file mapped "realfilename" in temporary mode 1.
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
#
# Utility
#
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
# returns the ANSI code to reset to default.
sub ansi_clear {
    return $RESET; #parse_color('{RESET}');
}

# ---------------------------------------------------------------------
# getcolor()
# Returns player's ansi-color-code named by a parameter.
# the name like "ColorNotifyFail" defined in constants.cfg
# but without the leading "Color", e.g. "NotifyFail" instead.
# TODO!
sub getcolor {
    my $colorname = shift; 
    my $this      = driver();
    my $pl        = current_user();
    my $keycolor  = '';
    my $ansicolor = '';
    $colorname = 'Color' . $colorname if $colorname !~ /^Color/; 
    if ( ref($pl) && $pl->isa('Living') && $pl->color($colorname) ) {
        $keycolor = $pl->color($colorname) ;
    }
    else {
        $keycolor = $this->constants->{$colorname} if exists $this->constants->{$colorname} ;
    }
    $ansicolor = parse_color("{$keycolor}") if $keycolor;
    return $ansicolor;
}

# ---------------------------------------------------------------------
# getdaemon()
# Returns the filename of a named daemon
# See configuration file .cfg for a directory map
sub getdaemon {
    my $name = shift || 'none';
    return getdir('dirstddaemon') . $name . '_daemon';
}

# ---------------------------------------------------------------------
# getdir()
# Returns the directory named by parameter
# See configuration file .cfg for a directory map
sub getdir {
    my $name = shift;
    my $this = driver();
    my $dir = 'log/'; # default
    unless ( ref($this->dir) ) {
        warning( "No dir setup" );
        return $dir;
    }
    unless ( exists $this->dir->{$name} ) {
        warning( "No such dir $name" );
        return $dir;
    }
    $dir = $this->dir->{$name} if exists $this->dir->{$name};
    return $dir ;
}

# ---------------------------------------------------------------------
# getsetup()
# Returns a constant by name defined in configuration file constant.cfg
sub getsetup {
    my $name = shift; # a name like "ColorNotifyFail" defined in constants.cfg
    my $this = driver();
    my $setup = shift || ''; # default
    unless ( ref($this->constants) eq 'HASH' ) {
        warning( "No constant setup" );
        return $setup;
    }
    unless ( exists $this->constants->{$name} ) {
        ##warning( "No such constant $name" ) unless $setup;
        return $setup;
    }
    $setup = $this->constants->{$name} if exists $this->constants->{$name};
    return $setup;
}

# ---------------------------------------------------------------------
# useful max
sub max { (($_[0])<($_[1])?($_[1]):($_[0])) }

# ---------------------------------------------------------------------
# useful min
sub min { (($_[0])<($_[1])?($_[0]):($_[1])) }

# ---------------------------------------------------------------------
# gives the number in letter.
sub number_in_letter {
    my $num = shift;
    my $this = driver();
    $num = 0 if $num < 0;
    $num = 12 if $num > 12;
    $num = $this->constants->{Number}->[$num] ;
    return $num;
}

# ---------------------------------------------------------------------
# pos_array(  @array, $elt ) or 
# pos_array( \@array, $elt )
# returns the index of the element in the array or -1 for not found.
sub pos_array {
    my @array = @_ ;
    my $elt = pop @array ; # value to be matched
    my $array = $_[0] ; 
    my $result = -1;
    $array = \@array unless ( ref($array) eq 'ARRAY' ) ;
    my $len = scalar ( @{$array} ) ;
    foreach my $i ( 0 .. $len-1 ) {
        if ( ref($elt) && ref($array->[$i]) ) {
            $result = $i if $elt == $array->[$i] ;
        }
        else {
            $result = $i if defined $array->[$i] && $elt eq $array->[$i] ;
        }
        last unless $result < 0;
    }
    return $result ;
}

# ---------------------------------------------------------------------
# remove_from_array( @ary, $element )
# remove_from_array( \@ary, $element )
# tries to remove element from array.
sub remove_from_array {
    my @array = @_ ;
    my $elt = pop @array ; # value to be matched
    my $array = $_[0] ; 
    my $i = pos_array( $array, $elt );
    unless ( $i < 0 ) {
        if ( ref($array) eq 'ARRAY' ) { 
            splice @{$array}, $i, 1 ;
            return $array;
        }
        else { 
            splice @array, $i, 1 ;
            return @array;
        }
    }
}

# ---------------------------------------------------------------------
sub roll_dice {
    my $dicesize = getsetup('DiceSize') || 6 ;
    return int(1 + rand($dicesize));
}

# ---------------------------------------------------------------------
# Returns a standard message (language configurable in message.cfg)
sub std_msg {
    my $arg     = shift ;
    my $this    = driver();
    my $msg = ''; # default
    unless ( ref($this->message) ) {
        warning( "No message setup" );
        return $msg;
    }
    unless ( exists $this->message->{$arg} ) {
        warning( "No such msg $arg" );
        return $msg;
    }
    return $this->message->{$arg} if exists $this->message->{$arg} ;
    return '';
}

# ---------------------------------------------------------------------
# convert a time in string; 
# if no time is given then uses current time().
# if no format is given then uses a default format YYYY-MM-DD HH.MI.SS
sub time_to_str {
    my $this = driver();
    my $tm = shift || time() ;
    my $fm = shift || 'YYYY-MM-DD HH.MI.SS' ;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime( $tm );
    my $centuryear = $year+1900;
    my $yy = $year; $yy -= 100 while $yy > 100; 
    my $ssec = 0;
    my $mary = getsetup('MonthShort') || [1..12];
    my $dmon = $mary->[$mon];
    $yy = '0'.$yy if $yy < 10;
    $mon++; $mon = '0'.$mon if $mon < 10;
    $mday = '0'.$mday if $mday < 10;
    $hour = '0'.$hour if $hour < 10;
    $min = '0'.$min if $min < 10;
    $sec = '0'.$sec if $sec < 10;
    my $wary = getsetup('WeekDayShort') || ['Sun','Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    my $weekday = $wary->[$wday];
    #no strict;
    #my $weekday = $this->constants->{WeekDay}->[$wday];
    #use strict;
    $ssec = $sec + 60 * $min + $hour*3600;
    my $dt = $fm;
    $dt =~ s/YYYY/$centuryear/gi;
    $dt =~ s/YY/$yy/gi;
    $dt =~ s/MM/$mon/gi;
    $dt =~ s/DDD/$yday/gi;
    $dt =~ s/DD/$mday/gi;
    $dt =~ s/D/$wday/gi;
    $dt =~ s/HH/$hour/gi;
    $dt =~ s/MI/$min/gi;
    $dt =~ s/SSS/$ssec/gi;
    $dt =~ s/SS/$sec/gi;
    $dt =~ s/WW/$weekday/gi;
    $dt =~ s/MON/$dmon/gi;
    return $dt;
}

# ---------------------------------------------------------------------
#
# File
#
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
# append data to a file
sub append_file {
    my $filename = clean_root(shift);
    my $output   = @_;

    if ( basedepth($filename) > 0 && open ( AFILE , ">> $filename" ) ) {
        print AFILE @_ ;
        close AFILE;
    }
    else {
        warning( "Can't write for append $filename: $!.\n" ) ;
    }
}
 
# ---------------------------------------------------------------------
# append data to a file with a newline
sub append_file_trim {
    my $filename = clean_root(shift);
    my $output   = @_;
    if ( -s $filename > getsetup('Action')) { 
        ; # TODO!
    }
    
    if ( basedepth($filename) > 0 && open ( AFILE , ">> $filename" ) ) {
        print AFILE @_,"\n" ;
        close AFILE;
    }
    else {
        warning( "Can't write for append $filename: $!.\n" );
    }
}
 
# ---------------------------------------------------------------------
# rename a file
sub rename_file {
    my $file = shift;
    my $newfile = shift;
    
    if ( basedepth("$file") > 0 && basedepth("$newfile")) {
        rename $file, $newfile;
    }
    else {
        warning( "Can't rename filename: $!.\n" );
    }
}
 
# ---------------------------------------------------------------------
# unlink a file, always saves a backup
sub unlink_file {
    my $file = shift;
    
    if ( basedepth("$file") > 0 ) {
        my @statfile = stat($file);
        my $dir  = getdir('dirtrashcan');
        my $name = basefilename($file); $name =~ s/\//_/;
        my $ext  = baseextname($file);
        my $tt = time_to_str( time(), 'YYYYMMDD.HHMISS');
        my $newfile = "$dir$name.$tt.$ext";
        rename $file, $newfile;
    }
    else {
        warning( "Can't unlink filename: $!.\n" );
    }
}
 
# ---------------------------------------------------------------------
# given a filename extracts the directory part:  /dd/cc/nn.ee -> /dd/cc
sub basedirname {
    my $dirname = shift || return 0;
    $dirname = $1 if $dirname =~ m|^(.+)/.+$|;
    return $dirname;
}

# ---------------------------------------------------------------------
# given a filename extracts the extension part: /dd/cc/nn.ee -> ee
sub baseextname {
    my $filename = shift || return 0;
    $filename = $1 if $filename =~ m|^.+\.(.+)$|;
    return $filename;
}

# ---------------------------------------------------------------------
# given a filename extracts the name part without extension: /dd/cc/nn.ee --> nn
sub basefilename {
    my $filename = shift || return 0;
    return $1 if $filename =~ m|^.+/(.+)\..+$| ;
    return $1 if $filename =~ m|^.+/(.+)$| ;
    return $1 if $filename =~ m|^(.+)\..+$| ;
    return $filename;
}

# ---------------------------------------------------------------------
# given a filename extracts the name part without extension: /dd/cc/nn.ee --> nn
sub basefileextname {
    my $filename = shift || return 0;
    return basefilename($filename) . '.' . baseextname($filename);
}

# ---------------------------------------------------------------------
# given a filename extracts the part before the dot-extension: /dd/cc/nn
sub basename {
    my $filename = shift || return 0;
    $filename = $1 if $filename =~ m|^(.+)\.\w+$|;
    return $filename;
}

# ---------------------------------------------------------------------
# given a filename and a relpath, resolves any '../' 
sub basenavdir {
    my $filename = shift ; 
    my @list = split( /\//, $filename );
    my @result = ();
    my $pl = current_user();
    if ($#list>0 && $list[0] eq '~' && ref($pl) && $pl->isa('Object')) { 
        $list[0] = $pl->name;
        unshift @list, getdir('dirhome');
    }
    foreach my $item ( @list ) {
        next if $item eq '.' or $item eq '';
        return '' if -1 == $#result && $item eq '..';
        pop  @result if $item eq '..' ;
        push @result, $item unless $item eq '..' ;
    }
    return join ('/',@result);
}

# ---------------------------------------------------------------------
# given a path/filename returns the lawfulness 
sub basedepth {
    my $filename = shift; 
    my @list = split( /\//, $filename );
    my $depth = 0;
    foreach my $item ( @list ) { 
        next if $item eq '.' or $item eq '';
        $depth-- if $item eq '..' ;
        $depth++ unless $item eq '..' ;
    }
    log_file( 'engine.log', "Illegal path for $filename" ) unless $depth > 0;
    log_file( 'basedepth.log', "Illegal path for $filename" ) unless $depth > 0;
    return $depth;
}

# ---------------------------------------------------------------------
# sends a file (or a part of it) to the client
sub cat{ 
    my $file   = shift || return 0;
    my $startl = shift || 0;
    my $numl   = shift || 0;
    my $pl     = current_user();
    my @string = ();

    unless( -f $file ) {
        notify_fail( parse_std_msg('NotifyFileNotFound', $file ) );
        return 0; # Not found
    };
    
    @string = cat_array( $file, $startl, $numl );       
    tell_object( $pl, 
        parse_color( join "\n", @string ) .
        "\n" );
    return 1;
}

# ---------------------------------------------------------------------
# sends a file (or a part of it) to an array
sub cat_array { 
    my $file   = clean_root(shift) || return 0;
    my $startl = shift || 0;
    my $numl   = shift || 0;
    my $pl     = current_user();
    my @string = ();

    unless( -f $file ) {
        notify_fail( parse_std_msg('NotifyFileNotFound', $file ) );
        return @string; # Not found
    };
    
    if ( basedepth($file) > 0 && open( AFILE , $file ) ) {
        while ( my $line = <AFILE> ) { 
            $line =~ s/[\015\012]// ; 
            push @string , $line if $. >= $startl+1 && (0 == $numl || $. < $startl+1 + $numl ) ;
            shift @string if $startl < 0 && scalar(@string) > -$startl;
        }
        close( AFILE );
    }
    return @string; # OK
}

# ---------------------------------------------------------------------
# sends a file (or a part of it) to a string
sub cat_str { 
    my $file   = shift || return 0;
    my $startl = shift || 0;
    my $numl   = shift || 0;
    my $pl     = current_user();
    my @string = ();

    unless( -f $file ) {
        notify_fail( parse_std_msg('NotifyFileNotFound', $file ) );
        return ''; # Not found
    };
    
    @string = cat_array( $file, $startl, $numl );       
    return join "\n", @string; # OK
}

# ---------------------------------------------------------------------
# sends a file to the client wrapped 
sub cat_wrap { 
    my $file   = shift || return 0;
    my $startl = shift || 0;
    my $numl   = shift || 0;
    my $pl     = current_user();
    my @string = ();

    unless( -f $file ) {
        notify_fail( parse_std_msg('NotifyFileNotFound', $file ) );
        return 0; # Not found
    };
    
    @string = cat_array( $file, $startl, $numl );   
    map {$_ = parse_color($_)} @string;
    tell_object( $pl, 
        wrap_string( @string ) );
    return 1; # OK
}

# ---------------------------------------------------------------------
# removes any / in the beginning of pathname
sub clean_root {
    my $file = shift||'';
    while( substr($file,0,1) eq '/') {
        $file = substr($file,1);
    }
    return $file;
}

# ---------------------------------------------------------------------
# gives the true filename, completing the  ./  part
# relative to an object passed by parameter or
# relative to the environment of the user.
sub effective_file_name { 
    my $pl = current_user();
    my $what   = shift || 0;
    my $relobj = shift || $pl;
    my $name   = $what;
    my $path;
    
    write_debug( 64, "eff_ob_name( $what, $relobj ) ") ;

    # a file dot-path-relative to here or current_user.
    if ( $what =~ m|^\.+/(.+)| ) {
        $name = $1 if $what =~ m|^\./(.+)|;
        # an effective path 
        $path = basedirname( $relobj ) if ( $relobj && !ref($relobj) ) ;
        # if a relative object is passed, search from path of relobj 
        $path = basedirname( $relobj->keyname ) if ( ref($relobj) && $relobj->isa('Object') ) ;
        # default: player's environment (room)
        $path = basedirname( $pl->keyname ) if ( ref($pl) && $relobj->isa('User') && $pl->environment() ) ;
        write_debug( 64, "!" ) if ( $relobj && !ref($relobj) ) ;
        write_debug( 64, "*" ) if ( ref($relobj) && $relobj->isa('Object') ) ;
        write_debug( 64, "_" ) if ( ref($pl) && $pl->environment() ) ;
        write_debug( 64, basenavdir( $path . '/' . $name ) ,"\n" );
        return basenavdir( $path . '/' . $name ) ;
    }    
    return basenavdir($name);
}

# ---------------------------------------------------------------------
# append a string to the logfile specified
# some user/time information are added before your string
sub log_file {
    my $logfile = shift;
    my $message = time_to_str( time(), 'YYMMDD.HHMISS' );
    my $logdir   = getdir('dirlog');
    my $pl = current_user() || '';
    
    if ( ref($pl) ) {
        if ( $pl->isa('User') ) { $message .= ' ' . $pl->keyname }
        elsif ( $pl->isa('Object') ) { $message .= ' ' . $pl->module }
        else { $message .= ' ' . $pl if $pl; }
    }
    else { 
        $message .= ' ' . $pl if $pl;
    }

    append_file( "$logdir/$logfile", "$message: @_\n" );
        
    # if loggin on driver then send it to stdout also.
    print( "$message: @_\n" ) if $logfile eq "engine.log" ;
}

# ---------------------------------------------------------------------
# append a string to the logfile specified
# some user/time information are added before your string
sub warning { 
    $msg = shift;
    print( "Warning: $msg.\n" );
}

# ---------------------------------------------------------------------
#
# Config files
#
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
# restore_config. 
# configure the object passed by reference using the data that follows
# this is the inverse of restore_config
sub restore_config { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $file    = clean_root(shift);
    my $silent  = shift || 0;
    log_file( 'engine.log', "Reading $file... " ) unless $silent;
    return 0 unless basedepth($file) > 0 && open ( CONFIG , $file ) ;
    my @data = <CONFIG>;
    if ( $data[0] =~ m/#\s(.+)\s#/ ) { 
        unless ( "$class" eq "$1" ) { 
        log_file( 'engine.log', "Wrong class $1 in file $file for object $class." );
        return 0;
        }
    }
    restore_string( $this, @data );
    close( CONFIG ) ;
    return 1;
}

# ---------------------------------------------------------------------
# restore_string. 
# configure the object passed by reference using the data that follows
# this is the inverse of store_string
# data can be: scalar, array, hash which element can be any of the previous.
sub restore_string { 
    my $this    = shift;
    foreach my $data (@_) {
        next if $data =~ m/^\s*#/ && $data !~ m/^\s*#.\s*=\s*.*$/; # ignore comments
        #if ( $data =~ m/^\s*(\w[\s\/\w\.]*\w)\s*=\s*(.*)$/
        if ( $data =~ m/^\s*(\w\S*)\s*=\s*(.*)$/
          or $data =~ m/^\s*(\w+)\s*=\s*(.*)$/
          or $data =~ m/^\s*(#.)\s*=\s*(.*)$/ 
           ) { # recognizes key=value
            restore_string_deep( $this, "$1", "$2" );
            ###print ">> $1 << " if $data =~ m/^\s*(#.)\s*=\s*(.*)$/ ;
        }
    }
}

# ---------------------------------------------------------------------
# recursive part of restore_string
sub restore_string_deep {
    my $this    = shift; # hash
    my $key     = shift;
    my $data    = shift;
    # when key has interleaving dots, then data is hash which element must be processed recursively
    if ( $key =~ m/^(\w+)\.([\w\.]+)/ ) {   
        if ( ! exists $this->{"$1"} or ref($this->{"$1"}) ne 'HASH') {
            $this->{"$1"} = {} 
        }
        restore_string_deep( \%{$this->{"$1"}}, "$2", $data );
    }
    else {
        $this->{"$key"} = restore_element( $this, $key, $data );
    }
}

# ---------------------------------------------------------------------
# single element part of restore_string
sub restore_element {
    my $this    = shift; # hash
    my $key     = shift;
    my $data    = shift;
    if ( $data =~ m/^\(\[(.*)\]\)\s*$/ ) {   # data has ([ ]) brackets
        my $str = $1;
        $str =~ s/\\\|/0xFF/;
        my @ary = split( m/\|/, $str);
        map $_ =~ s/0xFF/\|/g, @ary;
        return \@ary;
    }
    else { # scalar value
        $data =~ s/\\~/\n/g; 
        return $data;
    }
}

# ---------------------------------------------------------------------
# store_config( ob, file )
sub store_config {                
    my $this = shift;
    my $class = ref($this) || $this;
    my $file = clean_root(shift);
    
    my @ary = store_string( $this );
    return 0 unless ( basedepth($file) > 0 && open ( HF, "> $file" ) );
    print  HF "# $class #\n";
    print  HF @ary;
    close( HF ) ;
    return 1;
}

# ---------------------------------------------------------------------
# store_string( ob ) -> ary
# given an hash-reference returns an array representing its config file.
# Opposite of restore_string
# Data can be: scalar, array, hash, recursive-hash which element can be any of the previous.
sub store_string {
    my $this    = shift;
    my @result  = ();
    #while ( my ($key,$value) = each %{$this} ) {
    foreach my $key ( keys %{$this} ) {
        my $value = $this->{$key};
        push @result, store_string_deep( $key, $value );
    }
    return sort ( @result );
}

# ---------------------------------------------------------------------
# recursive part of store_string
sub store_string_deep {
    my $key   = shift || return '';
    return '' unless defined $_[0];
    my $value = shift || '0';

    ###print "store_string_deep $key,$value\n";    
    if ( ref($value) =~ m/^HASH/ ) { 
        my @result  = ();
        #while ( my ($kk,$vv) = each %{$value} ) {
        foreach my $kk ( keys %{$value} ) {
            my $vv = $value->{$kk};
            push @result, store_string_deep( "$key.$kk", $vv );
        }
        return @result;
    }
    else {
        return "$key = " . store_element( $value ) . "\n" ;
    }
}

# ---------------------------------------------------------------------
sub store_element {
    return '' unless defined $_[0];
    my $value = shift ;
    
    if ( ! ref($value) ) { # scalar
        $value =~ s/\015\012/\n/g; 
        $value =~ s/\n/\\~/g; 
        return "$value" ;
    }  
    if ( ref($value) =~ m/^ARRAY/ ) { 
        my $result = ''; 
        my @ary = @{$value}; 
        #for( my $i = 0; $i <= $#ary; $i++ ) { 
        foreach my $i ( 0 .. $#ary ) {
            if ( ref($ary[$i]) && $ary[$i]->isa('Object') ) { 
                $ary[$i] = $ary[$i]->module ;
            }
        }
        my $saved = $";
        $" = '|';
        $result = "@ary";
        $result =~ s/\015\012/\n/g; 
        $result =~ s/\n/\\~/g; 
        $result = "([$result])" ; 
        $" = "$saved";
        return $result;
    }
    #log_file( 'store.log', "Other type of reference '$value'." ); # cannot be anything else
    return "$value"
}

# ---------------------------------------------------------------------
#
# User related
#
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
# given a ref-to-client returns the ref-to-user that own it.
# client_to_user( $client ); 
sub client_to_user { 
    my $this = driver();
    my $cl = shift;
    if ($cl && exists $this->clients->{$cl} ) {
        return $this->clients->{$cl};
    }
    return 0;
}

# ---------------------------------------------------------------------
# the client currently being served
# this and the next sub set both CurrentClient and CurrentUser
sub current_client { 
    my $this = driver();
    if ( (@_)>0 ) {
        my $cl = shift;
        if ( $cl ) {
            $this->{CurrentClient} = $cl;
            $this->{CurrentUser} = $this->clients->{$cl};
        }
        else {
            $this->{CurrentUser} = 0;
            $this->{CurrentClient} = 0;
        }
    }
    else {
        return $this->{CurrentClient};
    }
}

# ---------------------------------------------------------------------
# the user currently being served
# this and the previous sub set both CurrentClient and CurrentUser
sub current_user { 
    my $this = driver();
    if ( (@_)>0 ) {
        my $user = shift;
        $this->{CurrentUser} = $user;
        if (ref($user) && $user->isa('User')) {
            $this->{CurrentClient} = $user->client;
        }
        else {
            $this->{CurrentClient} = 0;
        }
    }
    else {
        return $this->{CurrentUser};
    }
}

# ---------------------------------------------------------------------
# quit_all_clients
sub quit_all_clients {
    my $this  = driver();
    my @ready = values %{$this->user_names};
    foreach my $v (@ready) {
        quit_client( $v ) 
    };
}

# ---------------------------------------------------------------------
# quit_client( client )
# given a ref-client quits and cleans up the user 
# you should call 'save' before quitting
sub quit_client {
    my $this     = driver();
    my $client   = shift || return 0;
    my $pl       = client_to_user( $client ) ;
    
    if ( ref($pl) ) {
        my $prov     = $pl->environment;
        # interaction with the environment
        $pl->trans_object_out( $prov ) if ref($prov);
        foreach my $el ( @{$pl->inventory} ) {
            next unless ref($el);
            $el->trans_object_out( $pl ); 
            $el->trans_object_in( the_void() );
        }
        $pl->destroy();
    }
    return 1;
}

# ---------------------------------------------------------------------
# save_all_clients 
sub save_all_users {
    my $this  = driver(); 
    my $dir   = getdir('dircfgusers') ;
    my @users = values %{$this->clients};
    foreach my $us ( @users ) { 
        next if $us->status eq 'Logon';
        tell_object( $us, std_msg('NotifyAutosave') . "\n" );
        $us->store( $dir . $us->name . '.cfg', 1 ) ;
        #save_user( $us ) ;
    };
}

# ---------------------------------------------------------------------
# save user passed by reference
sub save_user {
    my $this  = driver(); 
    my $pl = shift || return 0;
    # only real users can be saved
    return 0 if ! ( ref($pl) && $pl->isa('User') );

    my $file = getdir('dircfgusers') . $pl->name . '.cfg';
    return 1 if ( $pl->store( $file ) );
    return 0;
}

# ---------------------------------------------------------------------
sub user_exists {
    my $this = driver();
    my $who  = shift; 
    return 1 if $this->password( "$who" ) ;
    return 0;
}

# ---------------------------------------------------------------------
# given a user-name returns the ref-to-client used by.
# username_to_client( $name ); 
sub username_to_client { #driver()->user_names->{$_[0]} }
    my $this = driver();
    my $cl = shift;
    if ($cl && exists $this->user_names->{$cl} ) {
        return $this->user_names->{$cl};
    }
    return 0;
}    

# ---------------------------------------------------------------------
#
# Core
#
# ---------------------------------------------------------------------
# ---------------------------------------------------------------------
# call_other( module/object, function, parameter ... )
# call function in other object
# module/object can be an module name, i.e. a "script.pl" file that contains the function
# module/object can be a reference to an object: so call_other is exactly like a obj->func() call.
# if module not found then      returns  0 and keeps notify_fail from load_module
# if module cannot be compiled  returns -1 and keeps notify_fail from load_module
# if ok then                    returns what that function returned
# e.g. call_other( 'std/the_void', 'new', $par );
# e.g. call_other( $room, 'do_something', @param );
sub call_other {
    my $this  = driver();
    my $obj = shift || return 0;
    my $cmd = shift || return 0;
    my @params = @_;
    my $result = 0;
    my $pkg = $obj;
    my $objname = 'unknown';
    my ($pak,$fi,$li) = caller();
    my $statement = 0;
    my $fob;
    my $cmddir  = getdir('dircmd');
    
    $cmd = $1 if $cmd =~ m/^(\w+)$/ ; # -T!
    
    # maybe the called module could modify some important data: 
    # this is a good place to save them
    my $pl     = current_user();

    # first-arg is an object-reference, call method directly
    if ( ref( $obj ) ) {
        if( $cmd =~ m/^\w+$/ ) {
            $statement = qq{ $cmd \$obj \@params } ;
            
        }
        else {
            $objname = $obj->name() if $obj->isa('Object');
            log_file( 'command.log', 'call_other ' . $objname . ' ' . $cmd );
        }
    }
    # when Commons, call local sub
    elsif ( $obj eq 'Commons' ) {
        if( $cmd =~ m/^\w+$/ ) {
            $statement = qq{ $cmd \@params } ;
        }
        else {
            log_file( 'command.log', 'call_other Commons ' . $cmd );
        }
    }
    # first-arg is a module-name, try to load_module and then call method
    else {    
        my $loaded = load_module( $obj );
        if( $loaded > 0 ) {
            if( $cmd =~ m/^\w+$/ ) {
                $pkg =~ s|/|::|g; # subst any / with the :: separator
                $pkg = $1 if $pkg =~ m/^(.+)$/ ; # -T!
                $fob = find_object( effective_file_name( $obj ) );
                # if object (but commands) is not found in memory, then call the new method.
                if ( ! ref($fob) && $cmd ne 'new' && $obj !~ /^$cmddir/ ) {
                    {   
                        local $SIG{__DIE__} = sub { showcomperr($obj,"$_[0]") } ;
                        local $SIG{__WARN__} = sub { showwarnerr($obj,"$_[0]") }  ;
                        $fob = eval qq{ new $pkg( \@params ) } ;
                    } ;
                }
                
                $statement = (ref($fob) ? '$fob' : "$pkg") . "->$cmd(" . '@params)';
                #if ( ref($fob) ) { $statement = qq{ \$fob->$cmd( \@params ) } }
                #else {             $statement = qq{  $pkg->$cmd( \@params ) } }
            }
            else { # NOT $cmd ~ /^\w+$/
                log_file( 'command.log', 'call_other ' . $pkg . '->' . $cmd );
            } 
        }
        else { # not loaded
            $result = $loaded; 
        } 
    }

    if ( $statement ) {
        write_debug( 32, qq{  $statement } );
        {
            local $SIG{__DIE__} = sub { showcomperr($obj,"$_[0]") } ;
            local $SIG{__WARN__} = sub { showwarnerr($obj,"$_[0]") } ; 
            $result = eval qq{  $statement } ;
        } ;
    }

    # restore some important data
    current_user( $pl );

    return $result || 0;
}

# ---------------------------------------------------------------------
# make a delayed call_other. First parameter is the delay in seconds.
# call_out's are fulfiled by the Engine main loop
sub call_out {
    my $this  = driver();
    my $delta = shift || 0; # seconds.
    my $pkg   = shift || return 0;
    my @params = @_;
    my $t = time() + $delta;
    my $d = 1;

    # if many callouts happens to expiry at the same second, then add a leading "0".
    while( exists $this->callouts->{ '0'x$d . $t } ) { $d++ } ;
    
    # stores the caller current_user(), caller package, and then any following parameter
    $this->callouts->{ '0'x$d . $t } = [ current_user(), $pkg, @params ] ;
}

# ---------------------------------------------------------------------
# tries to remove a previous call_out
sub remove_call_out {
    my $this  = driver();
    my $pkg   = shift || return 0;
    my @params = @_;
    my @pending = keys %{ $this->callouts } ;
    foreach my $t (@pending) {
        my @param = @{ $this->callouts->{$t} };
        my $pl  = shift @param;
        my $cal = shift @param;
        delete $this->callouts->{ $t } if current_user() == $pl && $pkg == $cal;
    };
}

# ---------------------------------------------------------------------
# return a referenced array copied from driver->clients
sub connections {
    my $this = driver();
    return [] unless ref($this) && ref($this->clients);
    my @ary = values %{$this->clients()};
    return \@ary;    
}

# ---------------------------------------------------------------------
# cx()
# experimental
sub cx {
    my $name = shift || 'none';
    my $ob = find_object( $name );
    $ob = call_other( $name, 'dummy_function' ) unless $ob;
    return $ob ;
}

# ---------------------------------------------------------------------
# daemon()
# Returns a reference to a named daemon
# If more parameters are given, then a call_other is done using the parameters. 
sub daemon {
    my $name = shift;
    my $func = shift || '';
    my @parm = ();
    my $ob = find_object( getdir('dirstddaemon') . $name . '_daemon' ) ;
    $ob = call_other( getdir('dirstddaemon') . $name . '_daemon', 'new' ) unless ref($ob);
    return $ob unless $func;
    @parm = @_ if scalar @_;
    my $result = call_other( $ob, $func, @parm ) ;
    return $result;
}

# ---------------------------------------------------------------------
# returns a reference to current DBI connection
sub dbi { # TODO! to be removed...
    log_file( 'dbicall.log', caller ) unless ( 0 == (@_) );
    return $databasehandle if ( 0 == (@_) );
    # only Engine can "set me".
    unless (caller eq 'Engine') {
        log_file( 'virus.log', "try to set dbi outside Engine: " . caller ) ;
        return 0
    }
    $databasehandle = shift;
}

# ---------------------------------------------------------------------
# csv
sub csv {
    return $csvdatabasehandle if ( 0 == (@_) );
    # only Engine can "set me".
    unless (caller eq 'Engine') {
        log_file( 'virus.log', "try to set csv outside Engine: " . caller ) ;
        return 0
    }
    $csvdatabasehandle = shift;
}

# ---------------------------------------------------------------------
# pointer to the Engine object
sub driver { 
    return $muddriver if ( 0 == (@_) );
    # only Engine can "set me".
    unless (caller eq 'Engine' or caller eq 'Mudmon') {
        log_file( 'virus.log', "try to set driver outside Engine: " . caller ) ;
        return 0
    }
    $muddriver = shift;
}

# ---------------------------------------------------------------------
# load a module in memory. Normally this sub is called by call_other.
# Next calls must pass a second parameter to force refreshing that module.
# returns 1 on success
# returns 0 if cannot find object file.
# returns -1 on compilation failure or invalid path
# load_module( object [, 1] )
sub load_module {
    my $this    = driver();
    my $obj     = shift;
    my $refresh = shift || 0;
    my $result  = 0;
    my $pl = current_user();
    $obj = basename($obj);
    my $file    = "$obj.pl";

    write_debug( 4, "load_module( $obj, $refresh ) \n") ;

    ###print "//\n" if $obj =~ m/^\//;
    ###print "\.\.\n" if $obj =~ m/^\.\./;
    if ( $obj =~ m/^\// || $obj =~ m/^\.\./ ) {
        log_file( 'command.log', "Invalid path: $obj" ) ;
        $result = -1;
        return $result; 
    }

    $obj = effective_file_name($obj);

    unload_module( $obj ) if $refresh; # force reload in the case
    if ( exists $INC{$file} ) {
        return 1; # module is already loaded
    }

    # module names must be a good filename, alphanum, dot and slash
    if( $file =~ m/^[\w\/\.]+$/ ) {
        $result = include_file( $file ); 
    }
    else {
        log_file( 'command.log', 'load_module ' . $file );
    }

    return $result ;
}

# ---------------------------------------------------------------------
# register the object in the muddriver
# registration is done using the "name" if the object is unique
# or "name#number" if the object is a clone.
# returns the registration key name or name#number.
sub register_object {
    my $this   = driver(); 
    my $name = shift;
    my $obj = shift;
    
    # registers any object into the muddriver.
    if ( exists $this->objects->{ "$name" } ) {
        my $nxt = $this->objects->{ "$name" }->nextclone;
        my $prv = $this->objects->{ "$name" }->prevclone;
        my $cn  = $this->objects->{ "$name" }->clonenumber;
        ###print "$name<$nxt|$cn|$prv>\n" if $name =~ /compass/;
        ++$cn;
        $this->objects->{ "$name" }->clonenumber( $cn );
        $this->objects->{ "$name#$cn" } = $obj; 
        
        $obj->prevclone( $prv ) ;
        $obj->nextclone( 0 );

        $this->objects->{ "$name" }->prevclone( $cn );
        if ( $prv && exists $this->objects->{ "$name#$prv" } ) {
            $this->objects->{ "$name#$prv" }->nextclone( $cn );
        } 
        else {
            $this->objects->{ "$name" }->nextclone( $cn );
            ###print "Unexists $name#$prv\n" if $prv;
        }
        
        ###print "registering $name#$cn\n" if $name =~ /compass/;
        return "$name#$cn";
    }
    else {
        $this->objects->{ "$name" } = $obj; 
        return "$name";
    }
}

# ---------------------------------------------------------------------
# prepare message of last compile error to client
# it relies on the following global variables: $@.
sub showcomperr { eval{ showerr( 'c', @_ ) }; }
sub showwarnerr { eval{ showerr( 'w', @_ ) }; }
sub showerr {
    my $opt     = shift;
    my $this    = driver();
    my $obj     = shift ;     
    my $msg     = shift ; 
    my $pl      = current_user();
    my $dir     = getdir('dirtmp');
    my $progr   = 0; 
    my $output  = '';
    
    # determines the number of temp file.
    if ( 1 == $this->temporarymode() ) {
        $progr = $1 if $msg =~ m/${dir}tmp(\d+)/;
        if ( $progr ) { 
            # find the true filename examining the included_filename hash if progr > 0
            $obj = $included_filename->{ "./${dir}tmp${progr}.pl" } ;
            $msg =~ s|${dir}tmp${progr}\.pl|${obj}|;
        }
    }
    # determines whether there is a "line number" within the message.    
    if ( $msg =~ m/\sline\s(\d+)/ && 2 != driver()->temporarymode() ) {
        my $linenum = $1 - 1; # must be == $#include_header;
        $msg =~ s|line \d+|line $linenum| ;
    }

    # if there is a user that caused that compile error
    if ( $pl && $pl->isa('Living') ) {
        if ( $pl->wizardhood() ) {
            # wizard will see the true message error
            my $key = ($opt eq 'w' ? 'NotifyWarningError' : 'NotifyCompileError');
            $output  = parse_std_msg( $key, $obj ) ;
            $output .= $msg;
        }
        else {
            # mortal will see a standard message
            $output  = parse_std_msg('NotifyWrongnessError', $obj) ;
        }
        # notify output error message
        write_client( $output );
        write_snoopees( $pl, ref($pl)." $msg" ) if $pl->can_be_snooped;
        log_file( $pl->name .'.log', "$msg" ) ;
    }    
    # no user: send it to std-out
    else {
        log_file('engine.log', $msg );
    }

    # log anyway in log-files.
    my $key = ($opt eq 'w' ? 'warning.log' : 'compile.log');
    log_file( $key, $msg ); 
    
    # alerts admins if current user is not.
    alert_admin( $msg );
}

# ---------------------------------------------------------------------
# return the stack frame image
sub stack_frame {    
    my @stack = ();
    foreach my $i (0..200) { 
        last unless caller $i;
        my ($pak,$fi,$li,$fu) = caller $i;
        push @stack, "$i - $pak, $fi, $li, $fu\n" ;
    } 
    return @stack;
}

# ---------------------------------------------------------------------
# unload_module( object )
sub unload_module {
    my $this  = driver();
    my $obj = shift;

    if ($obj && $obj =~ m/(\S+)/ ) { 
        $obj = "$1"; 
        delete $INC{ "${obj}.pl" } if exists $INC{ "${obj}.pl" };
        delete $INC{ "${obj}.pm" } if exists $INC{ "${obj}.pm" };
    }
}

# ---------------------------------------------------------------------
sub unregister_object {
    my $this   = driver(); #shift;
    my $keyname = shift;
    #print "Unregistering ($keyname), " ;

    return 0 unless exists $this->objects->{"$keyname"};

    my $base = $keyname; #default
    my $clone = 0;
    ($base,$clone) = ($`,$') if $keyname =~ /#/ ;

    my $obj = $this->objects->{"$keyname"} ;
    
    my $maxclone = $this->objects->{"$base"}->clonenumber ;
    my $nxt = $obj->nextclone;
    my $prv = $obj->prevclone;

    ###print "***$base # $clone, " if $base =~ /compass/;
    ###print "max $maxclone, nxt $nxt, prv $prv " if $base =~ /compass/;

    # clone zero means this is "$base", swap elements.
    if ( 0 == $clone && exists $this->objects->{ "$base#$nxt" } ) {
        $keyname = "$base#$nxt";
        my $tmp;
        my $swa = $this->objects->{ "$keyname" };
        $swa->clonenumber( $maxclone );
        $tmp = $obj->nextclone; $obj->nextclone($swa->nextclone); $swa->nextclone($tmp);
        $tmp = $obj->prevclone; $obj->prevclone($swa->prevclone); $swa->prevclone($tmp);
        $this->objects->{ "$base" } = $swa;
        $swa->keyname( "$base" );
        $this->objects->{ "$keyname" } = $obj;
        $obj->keyname( "$keyname" );
        $clone = $nxt;
        $nxt = $obj->nextclone;
        $prv = $obj->prevclone;
        ###print ">>>$base # $clone, " if $base =~ /compass/;
        ###print "max $maxclone, nxt $nxt, prv $prv " if $base =~ /compass/;
    } 
    else {
        log_file( 'engine.log',"Prev of $base#$prv not found in clone zero") if $prv;
    }
    
    # rebuild nextclone chain
    if ( $prv && exists $this->objects->{ "$base#$prv" } ) {
        $this->objects->{ "$base#$prv" }->nextclone( $nxt );
    } 
    else {
        $this->objects->{ "$base" }->nextclone( $nxt );
        log_file( 'engine.log',"Prev of $base#$prv not found") if $prv;
    }
    
    # rebuild prevlclone chain
    if ( $nxt && exists $this->objects->{ "$base#$nxt" } ) {
        $this->objects->{ "$base#$nxt" }->prevclone( $prv );
    } 
    else {
        $this->objects->{ "$base" }->prevclone( $prv );
        log_file( 'engine.log',"Next of $base#$nxt not found") if $nxt;
    }
    
    delete $this->objects->{"$keyname"};

    ###print "***\n" if $base =~ /compass/;
}

# ---------------------------------------------------------------------
#
# I/O and parser
#
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
# set the current user fail-message
sub notify_fail { 
    my $this = driver();
    my $user = current_user();
    if (ref($user) && $user->isa('Living') ) {
        return getcolor( 'NotifyFail' ) . $user->error_message( @_ );
    }
    else {
        log_file( "engine.log", "No current_user during notify_fail");
        return 0;
    }
}

# ---------------------------------------------------------------------
# parse alias
# this function examine a command line substituting any user's alias.
sub parse_alias {
    my $this   = driver();
    my $pl     = current_user();
    my $input_line = shift || '';
    return $input_line unless ref($pl) && $pl->isa('User');
    my %aliases = %{ $pl->alias() } ;
    $input_line =~ s/^\s*//;
    return $input_line if $input_line =~ s/^'/say / ; # standard...
    return $input_line if $input_line =~ s/^;/emote / ; # standard...
    return $input_line if $input_line =~ s/^\\/forcesnoop / ; # wizard...
    foreach my $i (1..10) { 
        while ( my ($key,$value) = each %aliases ) { 
            if ( $value =~ m/ \@\_/ && $input_line =~ m/^$key / ) { 
                my ($a,$b)=($`,$'); 
                my $i = $input_line;
                $input_line =~ s/^$key /$a / ;
                $input_line .= $b;
                last;
                ###print "($value) $i -> $input_line\n";
                ###$input_line = $i;
            }
            else {
                last if $input_line =~ s/^$key /$value / ; 
                last if $input_line =~ s/^$key$/$value/ ; 
            }
        }
    }
    return $input_line;
}

# ---------------------------------------------------------------------
sub parse_color {
    my $str    = shift;
    $str =~ s/{NORMAL}/$NORMAL/g;
    $str =~ s/{RESET}/$RESET/g;
    $str =~ s/{BOLD}/$BOLD/g;
    $str =~ s/{B}/$BOLD/g;
    $str =~ s/{NOBOLD}/$NOBOLD/g;
    $str =~ s/{\/B}/$NOBOLD/g;
    $str =~ s/{FAINT}/$FAINT/g;
    $str =~ s/{NOFAINT}/$NOFAINT/g;
    $str =~ s/{ITALIC}/$ITALIC/g;
    $str =~ s/{UNDERLINE}/$UNDERLINE/g;
    $str =~ s/{UNDERSCORE}/$UNDERSCORE/g;
    $str =~ s/{UNDERLINE2}/$UNDERLINE2/g;
    $str =~ s/{NOUNDERLINE}/$NOUNDERLINE/g;
    $str =~ s/{BLINK}/$BLINK/g;
    $str =~ s/{BLINKFAST}/$BLINKFAST/g;
    $str =~ s/{NOBLINK}/$NOBLINK/g;
    $str =~ s/{NEGATIVE}/$NEGATIVE/g;
    $str =~ s/{POSITIVE}/$POSITIVE/g;
    $str =~ s/{CONCEALED}/$CONCEALED/g;
    $str =~ s/{REVEAL}/$REVEAL/g;
    $str =~ s/{BLACK}/$BLACK/g;
    $str =~ s/{RED}/$RED/g;
    $str =~ s/{GREEN}/$GREEN/g;
    $str =~ s/{YELLOW}/$YELLOW/g;
    $str =~ s/{BLUE}/$BLUE/g;
    $str =~ s/{MAGENTA}/$MAGENTA/g;
    $str =~ s/{CYAN}/$CYAN/g;
    $str =~ s/{WHITE}/$WHITE/g;
    $str =~ s/{Black}/$Black/g;
    $str =~ s/{Red}/$Red/g;
    $str =~ s/{Green}/$Green/g;
    $str =~ s/{Yellow}/$Yellow/g;
    $str =~ s/{Blue}/$Blue/g;
    $str =~ s/{Magenta}/$Magenta/g;
    $str =~ s/{Cyan}/$Cyan/g;
    $str =~ s/{White}/$White/g;
    $str =~ s/{ON_BLACK}/$ON_BLACK/g;
    $str =~ s/{ON_RED}/$ON_RED/g;
    $str =~ s/{ON_GREEN}/$ON_GREEN/g;
    $str =~ s/{ON_YELLOW}/$ON_YELLOW/g;
    $str =~ s/{ON_BLUE}/$ON_BLUE/g;
    $str =~ s/{ON_MAGENTA}/$ON_MAGENTA/g;
    $str =~ s/{ON_CYAN}/$ON_CYAN/g;
    $str =~ s/{ON_WHITE}/$ON_WHITE/g;
    $str =~ s/{black}/$black/g;
    $str =~ s/{red}/$red/g;
    $str =~ s/{green}/$green/g;
    $str =~ s/{yellow}/$yellow/g;
    $str =~ s/{blue}/$blue/g;
    $str =~ s/{magenta}/$magenta/g;
    $str =~ s/{cyan}/$cyan/g;
    $str =~ s/{white}/$white/g;
    $str =~ s/\\n/\n/g; 

    return $str    
}   
    
    
# ---------------------------------------------------------------------
# parse_string of std_msg
sub parse_std_msg {
    my $std_msg = shift;
    parse_string( std_msg( $std_msg ), @_ );
}

# ---------------------------------------------------------------------
# parse string susbstituting some symbols with their values.
# This is used by the "emote" routine to render each element dynamically
# $n - user name        $N - target name
# $m - user objective   $M - target objective
# $s - user possessive  $S - target possessive  (F for feminine possessive objects)
# $l - user self        $L - target self
sub parse_string {
    my $str    = shift;

    my $pl     = current_user();
    my $this   = driver();

    my $male   = std_msg('Male') ;
    my $female = std_msg('Female') ;
   
    my $desinm = std_msg('MaleDesin');
    my $desinf = std_msg('FemaleDesin');

    my $he     = std_msg('he')  ;
    my $she    = std_msg('she') ;
    my $him    = std_msg('him')  ;
    my $her    = std_msg('herm') ;
    my $his    = std_msg('hism') ;
    my $hisf   = std_msg('hisf') ;
    my $herf   = std_msg('herf') ;
    my $tohim  = std_msg('tohim') ;
    my $toher  = std_msg('toher') ;
    my $bhim   = std_msg('bhim') ;
    my $bher   = std_msg('bher') ;
    
    my $yourselfm = std_msg('yourselfm') ;
    my $yourselff = std_msg('yourselff') ;
    my $himself   = std_msg('himself'  ) ;
    my $herself   = std_msg('herself'  ) ; 
    
    # substitute param list
    foreach my $i ( 0 .. $#_ ) { 
        $str =~ s/\$$i/$_[$i]/g if defined $_[$i]; 
    }
    # parse control-char
    $str = parse_color($str);

    # Useful in emote
    my $ob     = '';
    my $adv    = '';
    my $whe    = ''; 
    my $gen    = '';
    my $n      = '';
    if ( ref($pl) ) {
        $n =  $pl->short;
        if ( $pl->isa('Living') ) {
            $ob     = $pl->emote_target || '';
            $adv    = $pl->emote_adverb || '';
            $whe    = $pl->emote_where  || '';
            $gen    = $pl->gender       || '';
        }
    }

    my $u = ($gen eq $female ? $she       : $he        );
    my $m = ($gen eq $female ? $her       : $him       );
    my $s = ($gen eq $female ? $her       : $his       );
    my $f = ($gen eq $female ? $herf      : $hisf      );
    my $l = ($gen eq $female ? $herself   : $himself   );
    my $y = ($gen eq $female ? $yourselff : $yourselfm );
    my $o = ($gen eq $female ? $desinf    : $desinm    ); 
    my $t = ($gen eq $female ? $toher     : $tohim     );
    my $b = ($gen eq $female ? $bher      : $bhim      );
   
    if ( ref($ob) && $ob->isa('Living') ) {
        my $obgen = $ob->gender;
        my $N =  $ob->short;
        my $U = ($obgen eq $female ? $she       : $he        );
        my $M = ($obgen eq $female ? $her       : $him       );
        my $S = ($obgen eq $female ? $her       : $his       );
        my $F = ($obgen eq $female ? $herf      : $hisf      );
        my $L = ($obgen eq $female ? $herself   : $himself   );
        my $Y = ($obgen eq $female ? $yourselff : $yourselfm );
        my $O = ($obgen eq $female ? $desinf    : $desinm    );
        my $T = ($obgen eq $female ? $toher     : $tohim     );
        my $B = ($obgen eq $female ? $bher      : $bhim      );
        $str =~ s/\$O/$O/g ;
        $str =~ s/\$N/$N/g ;
        $str =~ s/\$M/$M/g ;
        $str =~ s/\$S/$S/g ;
        $str =~ s/\$F/$F/g ;
        $str =~ s/\$L/$L/g ;
        $str =~ s/\$Y/$Y/g ;
        $str =~ s/\$T/$T/g ;
        $str =~ s/\$B/$B/g ;
    }
    $str =~ s/\$o/$o/g ;
    $str =~ s/\$n/$n/g ;
    $str =~ s/\$m/$m/g ;
    $str =~ s/\$s/$s/g ;
    $str =~ s/\$f/$f/g ;
    $str =~ s/\$l/$l/g ;
    $str =~ s/\$y/$y/g ;
    $str =~ s/\$t/$t/g ;
    $str =~ s/\$b/$b/g ;
    
    $str =~ s/\$v/$adv/g ;
    $str =~ s/\$w/$whe/g ;

    return $str;
}

# ---------------------------------------------------------------------
# wipe out accent.
sub wipe_accent {
    my $string = shift;
    $string =~ tr/\x85\x8A\x82\x8D\x95\x97/aeeiou/;
    $string =~ tr/àèéìòù/aeeiou/;
    $string =~ tr/ÀÈÉÌÒÙ/AEEIOU/;
    return $string;
}

# ---------------------------------------------------------------------
# remove BS from the string applying them to it
sub wipe_ansi {
    my $string = shift;
    $string =~ s/\e\[\d{1,2}m//g;
    return $string;
}

# ---------------------------------------------------------------------
# remove BS from the string applying them to it
sub wipe_bs {
    my $tmp = shift;
    my $command = '';
    foreach my $i ( 0 .. length($tmp) ) {
        if( substr($tmp,$i,1) eq chr(8) ) { 
            substr($command, length($command)-1, 1) = '' 
        } 
        else { 
            $command .= substr($tmp,$i,1) 
        }
    }
    $command =~ s/\x1B\x5B\x63//g; # cursor left?
    $command =~ s/\x1B\x5B\x64//g; # cursor right?
    $command =~ s/\x7F//g; # del
    return $command;
}

# ---------------------------------------------------------------------
# removes all CR or LF.
sub wipe_crlf {
    my $string = shift;
    $string =~ s/[\015\012]//g;
    return $string;
}

# ---------------------------------------------------------------------
# wrap_at, splits an array into another array wrapping at column passed by first
sub wrap_at {
    my $pl      = current_user();
    my $len = shift || ( ref($pl) && $pl->isa('User') ? $pl->wrap_col : 70);
    my $nl = 0;
    $nl = 1 if substr("@_",length("@_")-1,1) eq "\n";
    my @string = split /\n/, join ("\n",@_);
    
    if ( ref $pl && $pl->isa('User') ) {
        foreach my $i ( 0 .. $#string ) {    
            while ( my ($key,$value) = each %{ $pl->char_decode() } ) { 
                $string[$i] =~ s/$key/$value/g;
            }
        }
    }

    my @ary = (); 
    foreach my $elm ( @string ) {
        # if this line is shorter than $len, then send it as-is
        if( length(wipe_ansi($elm)) > $len ) {
            my $esc = 0;
            my $spc = 0;
            my $acc = '';
            my $wrd = '';
            my $cnt = 0;
            $elm .= " ";    # append a space as sentinel
            foreach my $i ( 0 .. length($elm)-1 ) {
                my $c = substr($elm,$i,1);
                if ($spc) {   # within space or spaces
                    next if $c =~ /\s/ ;
                    ###print "$wrd$cnt - ";
                    $spc = 0 ;
                    $acc .= $wrd; # accumulate last word
                    $wrd = '';
                }
                $wrd .= $c; # accumulate char for current word
                $esc = 1 if $c eq "\e" ; # reveal escape sequence
                $spc = 1 if $c =~ /\s/ ; # reveal space char
                if ($esc) { # within escape sequence
                    next unless $c eq "m"  ;
                    $esc = 0 ;
                    next;
                }
                $cnt++; # normal character, add one to counter
                if ( $cnt >= $len && length($acc) ) {
                    push @ary, $acc ;
                    ###print "*$acc*\n";
                    $cnt = length($wrd);
                    $acc = '';
                }
            }
            push @ary, $acc . $wrd;
            ###print "\n^$acc^ $wrd $cnt \n";
        }
        else {
            push @ary, $elm;
            ###print "$elm * " . length($elm) . "\n";
        }
    }
    push @ary, '' if $nl;
    return  @ary;
}

# ---------------------------------------------------------------------
# wrap_parse
# wrap_string of parse_string
sub wrap_parse {
    wrap_string( parse_string( "@_" ) );
}

# ---------------------------------------------------------------------
# wrap_string
# given a string, reformats for current users wrap col.
# uses wrap_string_users which uses wrap_at()
sub wrap_string {
    wrap_string_user( current_user(), @_ );
}

# ---------------------------------------------------------------------
# wrap_string_user
# given a string, reformat it using wrap_at and specified user's wrap col
# uses wrap_at()
sub wrap_string_user {
    my $pl      = shift;
    $pl = current_user() unless ref($pl) && $pl->isa('User');
    return "@_" unless ref($pl) && $pl->isa('User');
    my $len = ( ref($pl) && $pl->isa('User') ? $pl->wrap_col : 70);
    my @ary = (); 
    @ary = wrap_at( $pl->wrap_col, @_ );
    my $out = join( "\n", @ary );
    return $out;
}

# ---------------------------------------------------------------------
# this function is not snooped.
# uses write_other()
sub write_client { 
    my $client = current_client();
    return write_other( $client, @_ );
}

# ---------------------------------------------------------------------
# this function is not snooped.
# uses write_other()
sub write_debug { 
    my $bits = shift || return 1;
    my $client = current_client();
    my $pl = client_to_user( $client ) || current_user() ;
    return 0 if ! ( ref($pl) && $pl->isa('User') );
    return 0 unless $pl->debugging & $bits ;
    return write_other( $client, @_ );
}

# ---------------------------------------------------------------------
# send message to a client
# this function is not snooped.
sub write_other { 
    my $client = shift || current_client() ;
    my $pl = client_to_user( $client ) || current_user();
    return 0 if ! ( ref($pl) && $pl->isa('User') );
    my @ary = @_ ;
    map $_ =~ s/\e\[\d{1,2}m//g, @ary if ref($pl) && 0 == $pl->ansi_color ;
    map $_ =~ s/\015\012/\n/g, @ary;
    map $_ =~ s/\n/\015\012/g, @ary;
    map $_ =~ s/\\n/\015\012/g, @ary;
    if ( ref($client) ) {
        push( @ary, $RESET ) if $pl->ansi_color != 0 && $pl->status eq 'Ok';
        eval { print $client @ary  }; # protect against client sudden disconnections
        $pl->bandwidthdown( $pl->bandwidthdown + length("@ary") );
    }
    return 1;
}

# ---------------------------------------------------------------------
# calls parse_string and sends result to write_client
# this function is not snooped.
sub write_parsed { 
    my $ar = shift;
    write_client(parse_string($ar, @_) ) if $ar;
    return 1;
}

# ---------------------------------------------------------------------
# send a string to all snooper. This function is not snooped.
sub write_snoopees {
    my $this    = driver();
    my $pl      = shift || return 0;

    return 0 unless ref($pl) && $pl->isa('Living');

    #while ( my ($key,$user) = each %{$pl->snooper} ) {
    foreach my $user ( @{$pl->snooper} ) {
        if ($user && $user->isa('User') && $user->status eq 'Ok') {
            my $client = $user->client;
            if( ref($client) ) {
                my @said = @_; 
                foreach my $i ( 0 .. $#said ) {    
                    while ( my ($key,$value) = each %{ $user->char_decode() } ) { 
                        $said[$i] =~ s/$key/$value/g;
                    }
                }

                write_other( $client, 
                  getcolor('SnoopingBegin') .
                  "<* " . $pl->name . " *>" . ansi_clear(),
                  @said  ,
                  getcolor('SnoopingEnd') .
                  "<* " . $pl->name . " *>" . ansi_clear() . "\n"
                  )
                  ;
            }
        }
    }
    return 1;    
}

# ---------------------------------------------------------------------
#
# Object interface Library
#
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
# *L* clones an object given the filename.
sub clone_object {
    my $this = driver();
    my $file = shift;
    my $ob = call_other( $file, 'new', @_ );
    $ob = 0 unless ref($ob);
    return $ob;
}

# ---------------------------------------------------------------------
# *L* generic command call, tries to execute a command as given by the user
# current_user and current_client are assumed in the called modules.
# do_command( 'cccc', ... ) tryes to call_other cmd/_cccc->cccc(...) 
# called functions return a non zero value when "matched", i.e. 1:ok, -1:ko
# do_command returns  1 as OK, 0 as KO (to display Notify Fail). 
sub do_command {
    my $cmd     = shift;
    my $ccc     = $cmd;
    my $this    = driver();
    my $pl      = current_user() || return 0; # no current user!
    my $room    = here() ; #$pl->environment;
    my $result  = 0;

    write_debug( 16, "do_command( $cmd @_ ) \n") ;
    
    $ccc     = wipe_accent($cmd);
    $ccc     = lc($ccc);
    
    # current user must be a User or mobile
    return 0 unless( ref($pl) && $pl->isa('Living'));

    # 1. Try admin-command via cmd/adm
    if ( 0 == $result && $pl->wizardhood() && $pl->administrator ) { 
        my $dir = '';
        $dir = getdir('dircmdadm')  if -e getdir('dircmdadm')  . "_$ccc.pl";
        $result = call_other( $dir . "_$ccc", "cmd_$ccc", $ccc, @_ ) if $dir;
    }

    # 2. Try wiz-command via cmd/wiz...
    if ( 0 == $result && $pl->wizardhood() ) { 
        my $dir = '';
        $dir = getdir('dircmdfile') if -e getdir('dircmdfile') . "_$ccc.pl";
        $dir = getdir('dircmdwiz')  if -e getdir('dircmdwiz')  . "_$ccc.pl";
        $result = call_other( $dir . "_$ccc", "cmd_$ccc", $ccc, @_ ) if $dir;
    }

    # 3. For each object the user has in inventory, check if it can respond an action
    if ( 0 == $result && ! $pl->ghost ) {
        foreach my $item (@{ $pl->inventory } ) { 
            if ( exists( $item->actions->{ "$cmd" } ) ) {
                $result = call_other( $item, $item->actions->{ "$cmd" }, $cmd, @_ );
                last if $result;
            }
        }
    }
    
    # 4. For each object the user can see, check if it can respond an action
    if ( 0 == $result && ref($room) && $room->isa('Room') && ! $pl->ghost ) {
        foreach my $item ( @{ $room->inventory } ) { 
            next if $item->isa('Room'); # skip rooms!
            next if $item->isa('User'); # skip users.
            if ( exists( $item->actions->{ "$cmd" } ) ) {
                ###print "$item,$cmd\n";
                $result = call_other( $item, $item->actions->{ "$cmd" }, $cmd, @_ );
                last if $result;
            }
        }
    }
    
    # 5. Check room actions.
    if ( 0 == $result && $room && ref($room) && $room->isa('Room') ) {
        if ( exists $room->actions->{ "$cmd" } && $room->actions->{ "$cmd" } ) {
            $result = call_other( $room, $room->actions->{ "$cmd" }, $cmd, @_ );
        }
    }

    # 6. Check "user" action (should be rare)
    ##if ( 0 == $result && ! $pl->ghost ) {
    ##    if ( exists $pl->actions->{ "$cmd" } && $pl->actions->{ "$cmd" } ) {
    ##        $result = call_other( $pl, $pl->actions->{ "$cmd" }, $cmd, @_ );
    ##    }
    ##}
    
    # 7. Standard commands via cmd/norm path.
    if ( 0 == $result ) {
        my $dir = '';
        $dir = getdir('dircmdnorm') if -e getdir('dircmdnorm') . "_$ccc.pl";
        if ( $pl->ghost ) {
            notify_fail( parse_std_msg('NotifyGhost') ) ;
        }
        else {
            $result = call_other( $dir . "_$ccc", "cmd_$ccc", $ccc, @_ ) if $dir;
        }
    }
    
    # 8. Standard commands via Actions definitions, see cfg/setup/actions.cfg
    if ( 0 == $result ) { 
        if( exists getsetup('Action')->{ "$ccc" } && getsetup('Action')->{ "$ccc" } ) {
            my $relycmd = getsetup('Action')->{ "$ccc" }; 
            $relycmd =~ s|::|/|g;
            $result = call_other( basedirname($relycmd), basefilename($relycmd), $ccc, @_ );
        }
    }

    # 9. Even a ghost can do it, cmd/ghost/_ccc
    if ( 0 == $result ) {
        my $dir = '';
        $dir = getdir('dircmdghost') if -e getdir('dircmdghost') . "_$ccc.pl";
        $result = call_other( $dir . "_$ccc", "cmd_$ccc", $ccc, @_ ) if $dir;
    }

    write_debug( 16, "do_command() >> $result \n") ;

    # result will be 1 (ok) or 0 (ko)
    return 1 == $result ? 1 : 0;
}

# ---------------------------------------------------------------------
# *L* finds user given a name
sub find_user {
    my $what   = shift; $what = lc($what);
    my $driver = driver();
    my $cli = $driver->user_names->{$what} || 0;
    return 0 unless $cli;
    return $driver->clients->{ $cli } ;
}

# ---------------------------------------------------------------------
# *L* given an living-name returns its ref-object 
# this means an object is uniquely named.
# argument are "name", "where", "number" 0 first, 1,2,... next,
sub find_living { 
    my $what   = shift; $what = lc($what);
    my $where  = shift || 0; 
    my $which  = shift || 0;
    my $pl     = current_user();
    my $this   = driver();
    my $inve;
    my $count;

    # 1. search "where" using "name" and "altname"
    if( $where && ref($where) && $where->isa('Object') ) {
        $inve = $where->inventory;
        if( ref($inve) ) {
            $count = 0;
            foreach my $value ( @{$inve} ) { 
                next unless $value->isa('Living');
                if ( $value->id( $what ) ) {
                    if ( $count == $which ) {
                        return $value;
                    }
                    $count++;
                }
            }
        }
        return 0;
    }

    # 2. search global object using unique "keyname"
    return driver()->objects()->{ $what } 
        if exists driver()->objects()->{ $what } && 
            driver()->objects()->{ $what }->isa('Living');

    # if current_user is undefined then return not found.
    return 0 unless ref($pl);

    # 3. search user inventory using "name" and "altname"
    $count = 0;
    $inve = $pl->inventory;
    foreach my $value ( @{$inve} ) { 
        next unless $value->isa('Living');
        if ( $value->id( $what ) ) {
            if ( $count == $which ) {
                return $value;
            }
            $count++;
        }
    }

    # 4. search user environment using "name" and "altname"
    $where = $pl->environment();
    if( $where && ref($where) && $where->isa('Room') ) {
        $inve = $where->inventory;
        if( ref($inve) ) {
            $count = 0;
            foreach my $value ( @{$inve} ) { 
                next unless $value->isa('Living');
                if ( $value->id( $what ) ) {
                    if ( $count == $which ) {
                        return $value;
                    }
                    $count++;
                }
            }
        }
    }
   
    # Not found
    return 0;
}

# ---------------------------------------------------------------------
# *L* given an object-name returns its ref-object 
# this means an object is uniquely named.
# argument are "name", "where", "number" 0 first, 1,2,... next,
sub find_object { 
    my $what   = shift; $what = lc($what);
    my $where  = shift || 0; 
    my $which  = shift || 0;
    my $pl     = current_user();
    my $this   = driver();
    my $inve;
    my $count;

    # 1. search "where" using "name" and "altname"
    if( $where && ref($where) && $where->isa('Object') ) {
        $inve = $where->inventory;
        if( ref($inve) ) {
            $count = 0;
            foreach my $value ( @{$inve} ) { 
                ###print $value->name, "\n";
                if ( $value->id( $what ) ) {
                    if ( $count == $which ) {
                        return $value;
                    }
                    $count++;
                }
            }
        }
        return 0;
    }

    # 2. search global object using unique "keyname"
    return driver()->objects()->{ $what } if exists driver()->objects()->{ $what }; 
    # if current_user is undefined then return not found.
    return 0 unless ref($pl);

    # 3. search user inventory using "name" and "altname"
    $count = 0;
    $inve = $pl->inventory;
    foreach my $value ( @{$inve} ) { 
        if ( $value->id( $what ) ) {
            if ( $count == $which ) {
                return $value;
            }
            $count++;
        }
    }

    # 4. search user environment using "name" and "altname"
    $where = $pl->environment();
    if( $where && ref($where) && $where->isa('Room') ) {
        $inve = $where->inventory;
        if( ref($inve) ) {
            $count = 0;
            foreach my $value ( @{$inve} ) { 
                if ( $value->id( $what ) ) {
                    if ( $count == $which ) {
                        return $value;
                    }
                    $count++;
                }
            }
        }
    }
   
    # Not found
    return 0;
}

# ---------------------------------------------------------------------
# here()
# Returns the room you are
sub here {
    my $pl = current_user();
    return $pl->environment() if ref($pl) && $pl->isa('Object');
    return the_void();
}

# ---------------------------------------------------------------------
sub myself {
    return current_user();
}

# ---------------------------------------------------------------------
# send a message string to all objects in your enviroment, 
# except those in the list
sub say { 
    my $said    = shift;
    my @list    = @_;
    my $pl      = current_user() ;

    unless ( ref($pl) ) {
        log_file( 'engine.log', "No ref Object during say.");
        return 0;
    }

    my $room    = $pl->environment;
    ##return tell_room ( $room, $said, @list );
   
    # remove from %people the user listed in @list
    if ( ref($room) && $room->isa('Room') ) { 
        #my %people = %{$room->inventory} ;
        my @people = @{$room->inventory} ;
        foreach my $ob ( @list ) { 
            remove_from_array( \@people, $ob );
        }
    
        # send message to all %people
        foreach my $dest (@people) { 
            ###print $dest->name, " ";
            if ( $dest->living ) {
                tell_object( $dest, "$said" );
            }
        }
        return 1;
    }
    return 0;    
}

# ---------------------------------------------------------------------
# Send strings to all interactive users but the current_user().
sub shout { 
    my $this    = driver();
    my @said    = @_;
    my $pl      = current_user();
    
    #while ( my ($key,$user) = each %{$this->clients} ) { 
    foreach my $user ( values %{$this->clients} ) {
        tell_object( $user, @said ) if ($user != $pl && $user->status eq 'Ok');
    }
    return 1;    
}

# ---------------------------------------------------------------------
sub tell_object { 
    my $who = shift;
    my @said   = @_;

    # if there is nothing to be told    
    return unless scalar @said;

    # calls the catch_tell of the target object
    if( ref($who) && $who->isa('Object') ) {
        if ( $who->isa('User')) {
            foreach my $i ( 0 .. $#said ) {    
                while ( my ($key,$value) = each %{ $who->char_decode() } ) { 
                    $said[$i] =~ s/$key/$value/g;
                }
            }
        }
        $who->catch_tell( @said );
    }
}

# ---------------------------------------------------------------------
# send a message string to all objects in a specific room
# except those in the list.
# room can be passed by reference or by filename.
sub tell_room { 
    my $where = shift;
    my $said  = shift;
    my @list  = @_;
    my $room;

    # cercare fra le rooms il nome, ottenendo il ref alla Room
    if ( ref( $where ) && $where->isa('Room') ) { 
        $room = $where; 
    } 
    else { 
        $room = find_object( $where ); 
    }

    unless ( $room ) {
        # se manca, caricare con load_module creare l'istanza e inserirla nelle rooms
        $room = call_other( $where, 'new' ); 
        if ( 0 == $room || -1 == $room ) {
            #notify_fail ( "There is no such a place $room! );
            notify_fail( parse_std_msg('NotifyNoSuchPlace', $room ) );
            return 0;
        };
    }

    # remove from %people the user listed in @list
    if ( ref($room) && $room->isa('Room') ) { 
        #my %people  = %{$room->inventory};
        my @people  = @{$room->inventory};
        foreach my $ob ( @list ) { 
            remove_from_array( \@people, $ob );
        };
        
        # send message to all %people
        foreach my $dest ( @people ) { 
            if ( $dest->living ) {
                tell_object( $dest, "$said" );
            }
        }
        return 1;    
    }
    return 0;
}

# ---------------------------------------------------------------------
# this returns the "void" room, i.e. a room always defined.
sub the_void {
    #return find_object( getsetup('VoidRoom') );
    return find_object( driver()->the_void_room() );
}


# ---------------------------------------------------------------------
#
# Private
#

# ---------------------------------------------------------------------
# alert admins if current user is not.
sub alert_admin {    
    my $msg     = shift ; 
    my $pl      = current_user();
    # alert admins if current user is not.
    my @admin = getsetup('Administrators') ;
    if ( !ref($pl) || !$pl->isa('Living') || -1 == pos_array( @admin, $pl->name ) ) {
        foreach $adm (@admin) {
            my $user = find_user($adm);
            next unless ref($user) && $user->isa('User');
            next if $user == $pl;
            write_other( $user->client, $msg );
        }
    }
}

# ---------------------------------------------------------------------
sub alert_antivirus {
    my $pkg = shift;
    my @content = @_ ;
    
    #for( my $i = 0; $i < $#content; $i++ ) {
    my $pod = 0;
    foreach my $i ( 0 .. $#content ) {
        my $line = $content[$i];
        $pod = 1 if $line =~ /^=pod/ ;
        $pod = 0 if $line =~ /^=cut/ ;
        next if $pod;
        next if $line =~ /^\s*#/ ;
        if (  $line =~ /\W*package\W*/ 
           or $line =~ /\W*require\W*/ 
           #or $line =~ /\W*use.*::/ 
           or $line =~ /\W*qx\W*/
           ) {
            alert_admin( "Illegal perl source ($pkg,$i) : $&" );
            log_file( 'virus.log',  "$pkg,$i : $&" ) ;
            $@ = "Illegal perl source in $pkg at line $i.\n";
            return $i;
        }
    }
    return -1;
}

# ---------------------------------------------------------------------
# emulates require module.
# secured for use within this package
# returns 1 for OK (loaded now or already loaded)
# returns 0 for KO (file not found or not loaded)
# returns -1 for compilation error, 
# returns -2 for "virus" alert.
sub include_file {
    my $filename = shift;
    #$filename = clean_root($filename);
    my $realfilename = '';
    my $result = 0;
    my $found  = 0;
    ##my $pl     = current_user();
    my @content;

    # do not reload a module if it is in memory
    if ( exists $INC{$filename} ) {
        write_debug( 2, "include_file: $filename already included.\n" );
        return 1;
    }

    # find module directly
    if ( -f $filename ) { 
        $realfilename = $filename;
        $found = 1 ;
        write_debug( 2, "include_file: found directly\n" );
    }
    else {
        # search within @INC path
        foreach my $prefix (@INC) { # in driver.pl there are some use 'directory'...
            $realfilename = "$prefix/$filename";
            $found = 1 if ( -f "$prefix/$filename" );
            last if $found;
            write_debug(  2, "include_file: search $filename in $prefix\n" ) ;
        }
    }
 
    if ( $found ) {
        write_debug( 2, "include file: $realfilename found.\n" ) ;
        # read module
        return 0 unless ( basedepth($realfilename) > 0 && open( AFILE , $realfilename ) );
        @content = <AFILE> ;
        close( AFILE );
        # anti-virus alert
        if ( basedirname($realfilename) ne getdir('dirstd') ) {
            my $ln = alert_antivirus( $realfilename, @content ) ;
            if ( $ln >= 0 ) {
                my $lninc = $ln + 1;
                write_debug( 2, "$content[$ln] .Illegal perl source in $realfilename at line $lninc.\n" ); 
                return -2; # antivirus alert
            }
        }
    }
    elsif ( basefilename($filename) =~ m/^(.+)\_\d+\_\d+/  ) {
        # try virtual grid room xxx_N_N or xxx_N_N_N
        # virtual rooms rely on a xxx_base existing file as skeleton.
        # a room xxx_N_N can exist as a true file as link to normal rooms.
        write_debug( 2, "include_file: $filename is a virtual room, using $realfilename\n");
        @content = ( 
            'use VirtualRoom; # !!!T' . 'EMPO'.'RARY!!!' . "\n",
            'sub new { ' . "\n",
            '    my $this  = shift;               ' . "\n",
            '    my $class = ref($this) || $this ;' . "\n",
            '    my $self  = $this->SUPER::new ;  ' . "\n",
            '    return bless $self, $class ;     ' . "\n",
            '} ' . "\n",
            );
        $realfilename = $filename;
    }
    else {
        # continues if found     
       write_debug( 2, "include_file: $filename not found\n" ) ;
        return 0; # not found
    }

    # tmp module is numbered with this sequence.
    $include_progr++ if 1 == driver()->temporarymode();
    
    # build package name
    my $pkg;
    $pkg = basename($realfilename) ;
    $pkg =~  s|/|::|g;
    
    # Search class name in the first line of file and add a line "our @ISA = qw(XX);"
    foreach my $i ( 0 .. $#content ) {
        my $class = $1 if $content[$i]  =~ m/^\s*use\s*(\w+)\s*;/ ;
        if ( $class && -1 == pos_array( driver()->uninheritable, $class ) ) {
            #write_debug( 2, "include_file: class $class \n" ) ;
            $content[$i] = $content[$i] . 'our @ISA = qw('. $class .');' ."\n" ;
            last;
        }
    }

    my $tmp; 
    if ( 2 == driver()->temporarymode() ) {
        # temporary mode 2: will write a .pm near the prior .pl file.
        # useful for Open-IDE debugging.
        $tmp = $realfilename;
        $tmp =~  s|\.pl$|\.pm|;
    }
    else {
        # other temporary mode will write a anonymous temporary file
        my $dir = getdir('dirtmp'); # this relies on the fact that ./ is the correct directory.
        $tmp    = "${dir}tmp${include_progr}.pt";
    }
    $tmp = "./$tmp"; # questionable.
    #$tmp = driver()->basedir() . $tmp;
    #print "$tmp\n";

    return 0 unless ( basedepth($tmp) > 0 && open (BFILE , "> $tmp" ) );
    
    my @include_header = (
        "package $pkg; # !!!T". 'EMPO'.'RARY!!!' . "\n",
        "use Commons;\n"
        );
    
    #$include_header[0] =~ s|pkg|$pkg|;
    print BFILE @include_header;
    print BFILE @content;
    print BFILE "\n";
    print BFILE "1;\n";
    close( BFILE );

    # include tmp just written
    log_file( "engine.log", "$realfilename" . ( $include_progr ? " ($include_progr)." : '') );
    $included_filename->{ "$tmp" } = "$realfilename" if 1 == driver()->temporarymode() ;
    
    delete $INC{$tmp} if exists $INC{$tmp};

    {
        local $SIG{__DIE__} = sub { showcomperr($tmp,"$_[0]") } ;
        local $SIG{__WARN__} = sub { showwarnerr($tmp,"$_[0]") unless $_[0] =~ /redefined/ } ; 
        $result = eval { require $tmp ; } ;
    } ;
    
    if ( defined $result ) {
        $INC{$filename} = $filename ;
        $INC{$tmp} = $tmp if 2 == driver()->temporarymode() ;
    }
    else {
        delete $INC{$filename} if exists $INC{$filename}; # unload .pl
        delete $INC{$tmp}      if exists $INC{$tmp}     ; # unload .pm
        return -1;
    }
    
    return ($result ? 1 : 0);
}

# ---------------------------------------------------------------------
# TEST
# ---------------------------------------------------------------------
sub ztest {
no strict;
}

1;

__END__
