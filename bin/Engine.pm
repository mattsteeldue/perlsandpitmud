# Engine.pl
# Created Aug 2006
# Author  flogisto

package Engine;
my $mudversion = '0.121';

=pod

=head1 NAME

Engine - Multi User Dungeon.

=head1 DESCRIPTION

This is the mud driver engine. It accepts many socket-connections 
executing command they send to it via telnet.

It relies on Commons package, that is a "library" that supplies many
features, and some hierarchy objects (Object, Living, User).


=head2 Members

desc            description of mud
configfile      a filename e.g. "./bin/world.cfg"
drv_is_alive    0 to stop, 1 the mud is alive
tracemudalive   traces every main loop in mudalive.log
time_to_sleep   time in seconds between two loops
time_to_halt    timeout, when reached sets drv_is_alive to 0 (default -1 i.e. never).
time_to_next    time of next heartbeat
time_between    time in seconds between two heartbeats (default 2)
time_restart    time in seconds between two restart 
time_garbage    time in seconds after which the garbage collector acts.
bytes_per_poll  number of bytes taken into account in socket_process (default 80).
callouts        callouts waiting
time_last_hb    last heart beat time
time_boot       boot time

listner         reference to the listener
selector        reference to the selector
clients         given the "ref-client"   maps the ref-user. Accessible via 'connections'
user_names      given the "name-user"    maps the ref-client
objects         given the "keyname"      maps the ref-object

maxusernamelen  max username length
attempts        maximum number of logon attempts
maxcommands     maximum number of commands per input line
maxrobotbuffer  number of inputs parsed to check whether the user is a robot
maxlinespersec  maximum lines per second
maxcharpersec   maximum character per second
maxreadyclients maximum clients server per second.
temporarymode   set 1 to use temporary file, 2 to use .pm file near corresponding .pl 
resetroommode   set 0 to avoid restart room system, 1 to enable
uninheritable   list of un-inheritable modules (i.e. exporter utility module you can include)
maxmaillines    maximum number of lines per internal-mail.
historymaxlen   dimension of input-line history (used for diagnostic purposes)

opcodes         inert op-codes
constants       custom setup constants
message         custom messages
port            port number
dir             directory structures
banned          banned site address
connectstats    connection statistics
lockfile        internal constant
dbidriver       name of the dbi driver to be used
dbimasterfile   sqlite master filename
dbiusername     username to connect to dbi
dbipasswd       password to connect to dbi
dbibackup       name of backup database
write_lock      writes the lock file to signal the mud is running
verify_lock     reads the lock file to verify that the mud is running

new             called once at startup: builds up things, reads config files, calls ->init()
password        given the "name-user"    maps the crypted-password (stored permanently)
database_setup  first database creation
config          reads actions, directions, emotes, messages from config file.
destroy         called at close-down. immediately closes all clients.
minidump        store to dump.log the content of the current_user() that crashed the mud.
init            builds primary rooms and objects. Masks opcodes.
run             main loop.
linkdead_test   checks each connection for linkdead user
timeout_test    checks each connection for timeout
heart_beat      call hb on every object
fulfil_callouts fulfils pending callouts at expiry time.
socket_logon    first socket handling when users is logging on.
socket_process  normal socket handling
call_input_to   transit sub to call the correct input_to function.

process_logon   logon phase: handles the username, password and kickout 
process_username called from process_logon: input username
process_passw   called from process_logon: input password
process_passw2  called from process_logon: password confirm
process_kickout called from process_logon when you try to connect twice.
process_enter   called from the three above to complete connection.
process_normal  handles the normal user input lines
process_startup handles the first session user set-up


=cut

print( "SandpitMud v.$mudversion.\n" );
print( "Written by Matteo Vitturi.\n" );

use IO::Socket;
use IO::Socket::SSL;
use IO::Select;
use Net::hostent;
use Socket;
use Opcode;
use DBI;
use File::Copy;
use Time::HiRes;

# Object hierarchy. This guarantees compilation check
use Object;
use   Room;
use     Shop;
use     BackShop;
use     PostOffice;
use     VirtualRoom;
use Daemon;
use Living;
use   User;
use   Mobile;
use Garment;
use   Amulet;
use   Armour;
use   Belt;
use   Boots;
use   Cloak;
use   Earring;
use   Helmet;
use   Gloves;
use   Ring;
use   Shield;
use   Weapon;
use Book;
use Key;
use Money;
use Exit;

# non inheritable
use Commons;
use Database;

# ---------------------------------------------------------------------
#
# data member methods
#
# ---------------------------------------------------------------------
sub desc           { (@_)>1 ? ($_[0]->{Desc}               = $_[1],$_[0]) : $_[0]->{Desc}              } 
sub welcome_splash { (@_)>1 ? ($_[0]->{WelcomeSplash}      = $_[1],$_[0]) : $_[0]->{WelcomeSplash}     }
sub advert_spot    { (@_)>1 ? ($_[0]->{AdvertSpot}         = $_[1],$_[0]) : $_[0]->{AdvertSpot}        }
sub world_name     { (@_)>1 ? ($_[0]->{WorldName}          = $_[1],$_[0]) : $_[0]->{WorldName}         }
sub configfile     { (@_)>1 ? ($_[0]->{ConfigFile}         = $_[1],$_[0]) : $_[0]->{ConfigFile}        }
sub drv_is_alive   { (@_)>1 ? ($_[0]->{MudIsAlive}         = $_[1],$_[0]) : $_[0]->{MudIsAlive}        }
sub tracemudalive  { (@_)>1 ? ($_[0]->{TraceMudAlive}      = $_[1],$_[0]) : $_[0]->{TraceMudAlive}     }
sub time_to_sleep  { (@_)>1 ? ($_[0]->{TimeToSleep}        = $_[1],$_[0]) : $_[0]->{TimeToSleep}       }
sub time_to_halt   { (@_)>1 ? ($_[0]->{TimeToHalt}         = $_[1],$_[0]) : $_[0]->{TimeToHalt}        }
sub time_to_next   { (@_)>1 ? ($_[0]->{TimeToNextHB}       = $_[1],$_[0]) : $_[0]->{TimeToNextHB}      }
sub time_between   { (@_)>1 ? ($_[0]->{TimeBetweenHB}      = $_[1],$_[0]) : $_[0]->{TimeBetweenHB}     }
sub time_restart   { (@_)>1 ? ($_[0]->{TimeBetweenRestart} = $_[1],$_[0]) : $_[0]->{TimeBetweenRestart}}
sub time_garbage   { (@_)>1 ? ($_[0]->{TimeBetweenGarbage} = $_[1],$_[0]) : $_[0]->{TimeBetweenGarbage}}
sub bytes_per_poll { (@_)>1 ? ($_[0]->{BytesPerPoll}       = $_[1],$_[0]) : $_[0]->{BytesPerPoll}      }
sub callouts       { (@_)>1 ? ($_[0]->{Callouts}           = $_[1],$_[0]) : $_[0]->{Callouts}          } 
sub time_last_hb   { (@_)>1 ? ($_[0]->{TimeLastHB}         = $_[1],$_[0]) : $_[0]->{TimeLastHB}        } 
sub time_boot      { (@_)>1 ? ($_[0]->{TimeBoot}           = $_[1],$_[0]) : $_[0]->{TimeBoot}          } 
sub startup_room   { (@_)>1 ? ($_[0]->{StartupRoom}        = $_[1],$_[0]) : $_[0]->{StartupRoom}       } 
sub initial_room   { (@_)>1 ? ($_[0]->{InitialRoom}        = $_[1],$_[0]) : $_[0]->{InitialRoom}       } 
sub the_void_room  { (@_)>1 ? ($_[0]->{TheVoidRoom}        = $_[1],$_[0]) : $_[0]->{TheVoidRoom}       } 
sub daemon_room    { (@_)>1 ? ($_[0]->{DaemonRoom}         = $_[1],$_[0]) : $_[0]->{DaemonRoom}        } 
# ---------------------------------------------------------------------
sub listner        { (@_)>1 ? ($_[0]->{Listner}            = $_[1],$_[0]) : $_[0]->{Listner}           } 
sub selector       { (@_)>1 ? ($_[0]->{Selector}           = $_[1],$_[0]) : $_[0]->{Selector}          } 
sub clients        { (@_)>1 ? ($_[0]->{Clients}            = $_[1],$_[0]) : $_[0]->{Clients}           } 
sub user_names     { (@_)>1 ? ($_[0]->{UserNames}          = $_[1],$_[0]) : $_[0]->{UserNames}         } 
sub objects        { (@_)>1 ? ($_[0]->{Objects}            = $_[1],$_[0]) : $_[0]->{Objects}           } 
# ---------------------------------------------------------------------
sub maxusernamelen { (@_)>1 ? ($_[0]->{MaxUsernameLen}     = $_[1],$_[0]) : $_[0]->{MaxUsernameLen}    }  
sub attempts       { (@_)>1 ? ($_[0]->{Attempts}           = $_[1],$_[0]) : $_[0]->{Attempts}          }  
sub maxcommands    { (@_)>1 ? ($_[0]->{MaxCommands}        = $_[1],$_[0]) : $_[0]->{MaxCommands}       }  
sub maxrobotbuffer { (@_)>1 ? ($_[0]->{MaxRobotBuffer}     = $_[1],$_[0]) : $_[0]->{MaxRobotBuffer}    }  
sub maxlinespersec { (@_)>1 ? ($_[0]->{MaxLinesPerSec}     = $_[1],$_[0]) : $_[0]->{MaxLinesPerSec}    }  
sub maxcharpersec  { (@_)>1 ? ($_[0]->{MaxCharSec}         = $_[1],$_[0]) : $_[0]->{MaxCharSec}        }  
sub maxreadyclients{ (@_)>1 ? ($_[0]->{MaxReadyClients}    = $_[1],$_[0]) : $_[0]->{MaxReadyClients}   }  
sub temporarymode  { (@_)>1 ? ($_[0]->{UseTempMode}        = $_[1],$_[0]) : $_[0]->{UseTempMode}       }  
sub resetroommode  { (@_)>1 ? ($_[0]->{ResetRoomMode}      = $_[1],$_[0]) : $_[0]->{ResetRoomMode}     }  
sub uninheritable  { (@_)>1 ? ($_[0]->{UninheritableObj}   = $_[1],$_[0]) : $_[0]->{UninheritableObj}  }  
sub maxmaillines   { (@_)>1 ? ($_[0]->{MaxMailLines}       = $_[1],$_[0]) : $_[0]->{MaxMailLines}      }  
sub historymaxlen  { (@_)>1 ? ($_[0]->{HistoryMaxLength}   = $_[1],$_[0]) : $_[0]->{HistoryMaxLength}  }
sub cmd_splitter   { (@_)>1 ? ($_[0]->{CommandSplitter}    = $_[1],$_[0]) : $_[0]->{CommandSplitter}   } 
# ---------------------------------------------------------------------
sub opcodes        { (@_)>1 ? ($_[0]->{OpCodes}            = $_[1],$_[0]) : $_[0]->{OpCodes}           } 
sub constants      { (@_)>1 ? ($_[0]->{Constant}           = $_[1],$_[0]) : $_[0]->{Constant}          } 
sub message        { (@_)>1 ? ($_[0]->{Message}            = $_[1],$_[0]) : $_[0]->{Message}           } 
sub port           { (@_)>1 ? ($_[0]->{Port}               = $_[1],$_[0]) : $_[0]->{Port}              }
sub sslcertfile    { (@_)>1 ? ($_[0]->{SSLCertFile}        = $_[1],$_[0]) : $_[0]->{SSLCertFile}       }
sub sslkeyfile     { (@_)>1 ? ($_[0]->{SSLKeyFile}         = $_[1],$_[0]) : $_[0]->{SSLKeyFile}        }
sub dir            { (@_)>1 ? ($_[0]->{Dir}                = $_[1],$_[0]) : $_[0]->{Dir}               }
sub banned         { (@_)>1 ? ($_[0]->{BannedSiteAddress}  = $_[1],$_[0]) : $_[0]->{BannedSiteAddress} }
sub connectstats   { (@_)>1 ? ($_[0]->{ConnectStats}       = $_[1],$_[0]) : $_[0]->{ConnectStats}      }  
sub lockfile       { basefilename($_[0]->{ConfigFile}) . ".lock.txt" }
#sub basedir        { $_[0]->{BaseDir} }
# ---------------------------------------------------------------------
sub dbidatabase    { (@_)>1 ? ($_[0]->{DbiDatabase}        = $_[1],$_[0]) : $_[0]->{DbiDatabase}       }
sub dbidriver      { (@_)>1 ? ($_[0]->{DbiDriver}          = $_[1],$_[0]) : $_[0]->{DbiDriver}         }
sub dbimasterfile  { (@_)>1 ? ($_[0]->{DbiMasterFile}      = $_[1],$_[0]) : $_[0]->{DbiMasterFile}     }
sub dbiusername    { (@_)>1 ? ($_[0]->{DbiUsername}        = $_[1],$_[0]) : $_[0]->{DbiUsername}       }
sub dbipasswd      { (@_)>1 ? ($_[0]->{DbiPasswd}          = $_[1],$_[0]) : $_[0]->{DbiPasswd}         }
sub dbibackup      { (@_)>1 ? ($_[0]->{DbiBackupDatabase}  = $_[1],$_[0]) : $_[0]->{DbiBackupDatabase} }
sub dbiconn        { (@_)>1 ? ($_[0]->{DbiConnection}      = $_[1],$_[0]) : $_[0]->{DbiConnection}     }
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
# verifies what "lock" file says to check if driver is running.
sub write_lock {
    my $this  = shift; 
    my $class = ref($this) || $this;
    my $file = $this->lockfile;
    my $curtime = shift || 0;
    return 0 unless (basedepth("$file") > 0 && open (LOCK, ">$file" ) );
    print LOCK $curtime, "\t", time_to_str($curtime), ".\n",
        "This file was written by pid $$.\n",
        "Engine is using " . $this->configfile . " config file .\n",
        "This file keeps the last time-stamp it was seen alive.\n",
        "If you remove this file, the engine will stop shortly.\n";
    close LOCK;  
}

# ---------------------------------------------------------------------
# verifies what "lock" file says to check if driver is running.
sub verify_lock {
    my $this  = shift; 
    my $class = ref($this) || $this;
    my $curtime = time();
    my $lastlock = $this->read_lock_file();
    if ( $curtime - $lastlock < 60 ) {
        return 0; # lock file found up to date: driver is running
    }
    return 1; # lock file not found (or just created): driver not running
}

# ---------------------------------------------------------------------
# reads the "lock file" returns the number.
# used by MudMon to check itself Engine.
sub read_lock_file {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $file = $this->lockfile;
    return 0 unless basedepth("$file") > 0 ;
    if ( open (LOCK, "$file") ) {
        my ($tt,$ts) = split /\t/, <LOCK>;
        close LOCK;
        return $tt;
    }
    return -1; # lock file not found (or just created): driver not running
}

# ---------------------------------------------------------------------
# create the muddriver, a listner, a selector and some data-member
# ::new( configfilename );
sub new {
    # reads config file to fill the previous hashes.
    my $this  = shift;
    my $class = ref($this) || $this;
    my $configfile = shift || 'cfg/world.cfg'; # default
    my $self = {};
    bless $self, $class;
    # default member initial values: configurable in cfg/world.cfg
    my $curtime = time();

    # set master object global variable: driver() is defined in Commons.pm
    driver( $self ); # stores muddriver in global variable.
    $self->desc             ( 'Mud default name' ) 
         ->world_name       ( 'world' )
         ->welcome_splash   ( 'welcome.txt' )
         ->advert_spot      ( 'advert.txt' )
         ->configfile       ( $configfile )
         ->drv_is_alive     (  0 ) 
         ->tracemudalive    (  0 ) 
         ->time_to_halt     ( -1 )  # never
         ->time_to_sleep    (  1 )  # in seconds    
         ->time_to_next     ( -1 ) 
         ->time_between     (  1 ) 
         ->bytes_per_poll   ( 80 )  
         ->time_last_hb     ( $curtime ) 
         ->time_boot        ( $curtime ) 
         ->callouts         ( {} ) 
         ->attempts         (  3 )    
         ->maxusernamelen   ( 20 ) 
         ->banned           ( [] ) 
         ->connectstats     ( {} ) 
         ->cmd_splitter     ( '\|' )

         # default directory structure
         ->dir( { qw(
                dirarea          area/         
                dirbin           bin/          
                dircfg           cfg/          
                dircfgsetup      cfg/setup_en/
                dircfgusers      cfg/world/
                dirclonable      clonable/     
                dircmd           cmd/          
                dircmdadm        cmd/adm/      
                dircmdfile       cmd/file/     
                dircmdghost      cmd/ghost/    
                dircmdnorm       cmd/norm/     
                dircmdwiz        cmd/wiz/      
                dirdbsqlite      db/sqlite
                dirdbcsv         db/csv/      
                dirdoc           doc/          
                dirdocbook       doc/book/     
                dirdochelp       doc/help/     
                dirdochelpadm    doc/help/adm/ 
                dirdochelpnorm   doc/help/norm/
                dirdochelpwiz    doc/help/wiz/ 
                dirdocnews       doc/news/
                dirdocsys        doc/sys/      
                dirhome          home/         
                dirlog           log/          
                dirstd           std/          
                dirstddaemon     std/daemon/   
                dirstdmon        std/mon/      
                dirstdobj        std/obj/      
                dirstdroom       std/room/     
                dirtmp           tmp/          
                dirtrashcan      trashcan/     
                ) } )

         # default constants
         ->constants( {
                'WeekDayShort' => ['Sun','Mon','Tue','Wed','Thu','Fri','Sat','Sun']
               ,'MonthShort'   => [1..12]
                  } )

         # default message prompts
         ->message( {
                'PromptLogin'  => 'Logon: '
               ,'PromptPassw'  => 'password: '
               ,'PromptPassw2' => 'type it again: '
               ,'PromptRedo'   => 'Redo from start'
               ,'NotifyFail'   => 'What?'
                  } )

         ->sslcertfile( 'cfg/server.crt' )
         ->sslkeyfile ( 'cfg/server.key' )

         ->dbimasterfile( '/db/sqlite/world.sqlite' )
         ->dbidriver  ( 'dbi:SQLite:dbname=$0' ) 
         ->dbiusername( '' ) 
         ->dbipasswd  ( '' ) 
         ->dbibackup  ( 1 )
         ;

    restore_config( $self, $configfile ) || die "Can't read $configfile: $!.\n" ;
    #srand($curtime + $$);

    if ( $self->dir->{dircfgusers} eq $self->dir->{dircfgsetup} ) {
        die "Setup directory and Users directory must be different.";
    }

    $self->dbidatabase( new Database
        $self->dbidriver    () ,
        $self->dbimasterfile() ,
        $self->dbiusername  () ,
        $self->dbipasswd    () ,
        $self->dbibackup    ()   ) ;
    $self->dbidatabase->open_database();   
    $dbh = $self->dbidatabase->connect_database();
    $self->dbiconn( $dbh );
    $self->dbidatabase->setup_database( $self->world_name() );

    # set master database global variable: dbi() is defined in Commons.pm
    dbi( $dbh );

    # verify lock-file to check if it is already running
    unless ( $self->verify_lock() ) {
        my $file = $self->lockfile();
        die "Driver already running.\nCheck $file." ;
    }
    
    # open aux CSV database if any
    my $dbicsv = $self->{DbiCSVDriver};
    $dbicsv =~ s/\\t/\t/;
    $dbicsv =~ s/\\n/\n/;
    my $csv = DBI->connect( $dbicsv, '','' );
    csv( $csv ) if $csv;

    # reads specific configuration file (actions, directions, emotes)
    $self->config();

    # Activates listener at this port (TLS-encrypted; plaintext telnet is no longer served)
    my $port = $self->port || die "Missing 'Port' parameter in config file.\n";
    my $certfile = clean_root( $self->sslcertfile );
    my $keyfile  = clean_root( $self->sslkeyfile  );
    die "SSL certificate '$certfile' not found. Generate one first (see plan/PLAN_MODERNIZATION.md).\n"
        unless -f $certfile;
    die "SSL private key '$keyfile' not found. Generate one first (see plan/PLAN_MODERNIZATION.md).\n"
        unless -f $keyfile;
    my $lsn = IO::Socket::SSL->new(
        Proto             => 'tcp',
        Family            => AF_INET , # match the old IO::Socket::INET (IPv4-only) binding
        LocalPort         => $port ,
        Listen            => 10 ,
        Reuse             => 1 ,
        SSL_server        => 1 ,
        SSL_cert_file     => $certfile ,
        SSL_key_file      => $keyfile ,
        SSL_startHandshake => 0 , # defer handshake to socket_logon(), which does it blocking
         ) ;
    die "Can't setup listener: " . IO::Socket::SSL::errstr() unless $lsn;
    $lsn->blocking( 0 ); # superflous?
    
    # Setup selector
    my $sel = new IO::Select( $lsn );
    die "Can't setup selector: $@" unless $sel && ref($sel);
    
    # protected data
    $self->configfile   ( $configfile );
    $self->listner      ( $lsn );   
    $self->selector     ( $sel );   
    $self->clients      ( { } );     # hash of ref of connected users by "client"
    $self->user_names   ( { } );     # hash of ref of connected clients by "name"
    $self->objects      ( { } );     # hash of ref of all objects in the mud

    # other data
    $self->{CurrentClient}  = 0 ;
    $self->{CurrentUser}    = 0 ;   

    # unbuffered I/O
    $| = 1;
 
    # initialize the environment
    $self->init();

    # configure termination-signal to do a mini-dump.
    $self->{'!TERMSIGNAL!'} = $SIG{TERM} || undef;
    $SIG{TERM} = sub {
        $self->minidump()
    };

    log_file( 'engine.log',  "Start pid $$." );

    return $self;
}

# ---------------------------------------------------------------------
# dumps to file the object-image that crashed the driver.
sub minidump {
    my $this  = shift;
    my $class = ref($this) || $this;
    $SIG{TERM} = $this->{'!TERMSIGNAL!'} if defined $this->{'!TERMSIGNAL!'};
    log_file( 'dump.log', time_to_str() );
    log_file( 'dump.log', store_string( current_user() ) );
    $this->destroy( 0 );
    exit 1; # return to OS !
}

# ---------------------------------------------------------------------
# retrieve a single password (crypt) given the username or the whole password table.
sub password {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $key     = shift || '';
    return $this->dbidatabase->password( $key );
    
    ##my $dbh     = dbi();
    ##my $hpwd    = {};
    ##my $sql     = qq[ select username, passwd from engine_password ];
    ##$sql .= qq[ where username = ? ] if $key ne '' ;
    ##my $sth = $dbh->prepare( $sql );
    ##unless ( $dbh->err ) {
    ##    $sth->execute( $key ) if $key ne '';
    ##    $sth->execute( ) unless $key ne '';
    ##};
    ##unless ( $dbh->err ) {
    ##    while ( my $row = $sth->fetchrow_hashref() ) {
    ##        $hpwd->{ $row->{username} } = $row->{passwd} ;
    ##    }
    ##    my $passw = $hpwd->{ $key };
    ##    $sth->finish();
    ##    return $passw if $key ne '' ;
    ##    return $hpwd;
    ##}
    ##$sth->finish();
    ##return 0;
}

# ---------------------------------------------------------------------
# ::config()
# reads configuration files
sub config {
    my $this    = shift;
    my $class   = ref($this) || $this;
    
    # constants: parametrization
    $this->constants    ( { } )  unless ref $this->constants  ;            
    restore_config( $this->constants, getdir('dircfgsetup').'constants.cfg' ) 
        || warn "Can't read constants: $!.\n" ;
        
    # messages: localization
    $this->message      ( { } )  unless ref $this->message    ;
    restore_config( $this->message , getdir('dircfgsetup').'messages.cfg' ) 
        || warn "Can't read messages: $!.\n" ;

    # Standard actions: also built in aliases
    $this->{Constant}->{Action} = ( { } )  unless ref $this->{Constant}->{Action} ;
    restore_config( $this->{Constant}->{Action}, getdir('dircfgsetup').'actions.cfg' ) 
        || warn "Can't read actions: $!.\n" ;
    
    # Emotes actions
    $this->{Constant}->{Emote}  = ( { } )  unless ref $this->{Constant}->{Emote} ;
    restore_config( $this->{Constant}->{Emote}, getdir('dircfgsetup').'emotes.cfg' ) 
        || warn "Can't read emotes: $!.\n" ;
        
    # Adverbs used by Emotes.    
    $this->{Constant}->{Adverb} = ( { } )  unless ref $this->{Constant}->{Adverb} ;
    restore_config( $this->{Constant}->{Adverb}, getdir('dircfgsetup').'adverbs.cfg' ) 
        || warn "Can't read adverbs: $!.\n" ;
        
    # set-up an action for each emote: warns for duplications.    
    foreach my $verb (keys %{ $this->{Constant}->{Emote} } ) { 
        if ( exists getsetup('Action')->{$verb} ) {
            log_file( "emotes.log", "Warning: Emote action '$verb' is duplicated." );
        }
        $this->{Constant}->{Action}->{$verb} = getsetup('EmoteHandleCommand') ;
    };
}

# ---------------------------------------------------------------------
# ::destroy()
sub destroy {
    my $this  = shift;
    my $class = ref($this) || $this;

    log_file( 'engine.log',  "Destroy pid $$." );
    
    # immediately closes all clients.
    my @ready = @{ connections() } ; #values %{$this->user_names};
    foreach my $pl (@ready) {
        my $client = $pl->client;
        print $client "Closing down.\nBye.\n";
        $this->selector->remove($client);
        $client->close;
    }

    #my $dbh = dbi();
    $dbh = $this->dbiconn();
    $dbh->disconnect();
    
    my $cvs = csv();
    $cvs->disconnect();

    my $file = $this->lockfile;
    unlink "$file" if basedepth("$file") > 0 ;
    
    log_file( 'engine.log',  "Stop pid $$." );
}

# ---------------------------------------------------------------------
# ::init()
# create default objects. 
# This sub is called once at create.
sub init {
    my $this    = shift;
    my $class   = ref($this) || $this;

    # mask opcodes
    if ( defined $this->opcodes ) {
        my @ary = @{$this->opcodes} ;
        log_file( 'engine.log', "Masked opcodes: @ary." );
        Opcode::opmask_add( Opcode::opset( @ary ) );
    }

    # call creation of preloaded rooms
    my @preobj = ();
    push @preobj, $this->the_void_room() if $this->the_void_room();
    push @preobj, $this->startup_room()  if $this->startup_room() ;
    push @preobj, $this->initial_room()  if $this->initial_room() ;  
    push @preobj, $this->daemon_room()   if $this->daemon_room()  ;
    push @preobj, @{getsetup('PreloadedObjects')} if @{getsetup('PreloadedObjects')};
    foreach my $room ( @preobj ) {
        next unless $room;
        my $result = call_other( $room, 'new' );
        unless ( $result ) { 
            log_file( 'engine.log', "Fail to preload object: $room.") ;
            sleep( 1 );
        }
    }

    # log_file is a global sub declared in Commons
    log_file( 'engine.log', "Server now accepting clients.");
}

# ---------------------------------------------------------------------
# sets the muddriver "alive" and begin a loop that reads all clients
# and do "heartbeat" in every object.
# run( [timeout] )
sub run {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $timeout = shift || 0;
    my $sel     = $this->selector;
    my $lsn     = $this->listner;        
    my $curtime = time();

    $this->service if $timeout == -1;
    $this->drv_is_alive(1) if $timeout >= 0;
    $this->time_to_halt($curtime + $timeout) if $timeout;

    # main loop for accepting and processing sockets
    while( $this->drv_is_alive ) { 

        $this->write_lock( $curtime );
        log_file( 'mudalive.log', $curtime ) if $curtime % 600 == 0 && $this->tracemudalive;

        Time::HiRes::usleep ( $this->time_to_sleep * 1_000_000 );
        $curtime = time();
        ##print('.');

        # Tiemout client test.
        $this->timeout_test( $curtime );

        # fulfil pending callouts
        $this->fulfil_callouts( $curtime );

        # main client-server loop
        my @ready = $sel->can_read ( 0 ) ; 
        my $nc = 0;
        foreach my $client (@ready) {
            $nc++;
            if($client == $lsn) { 
                $this->socket_logon();
            } 
            else { 
                $this->socket_process( $client );
            }
            # avoid overheat
            sleep( 1 ) unless $nc % ($this->maxreadyclients || 8) ;
        }

        # wait next time to heartbeat
        $this->heart_beat( $curtime ) if $curtime >= $this->time_to_next;

        # stops the mud if is time to halt
        if ( ( $this->time_to_halt > 0 && $curtime > $this->time_to_halt )
            or ( $this->read_lock_file() == -1 ) ) {
            $this->drv_is_alive(0);
        }
    }
    log_file( 'engine.log', "**** Child pid $$ is stopping.");
}

# ---------------------------------------------------------------------
# checks each connection for linkdead user
sub linkdead_test {
    my $this    = shift;
    my $class   = ref($this) || $this;
    #my @test = @{ connections() } ; #values %{$this->user_names};
    #foreach my $pl (@test) {
    my $pl      = shift;
    my $clientname = $pl->clientname(); 
    my $clientaddr = $pl->peerhost(); 
    my ($port, $myaddr) = (0,0);
    ($port, $myaddr) = sockaddr_in($pl->client->sockname()) if ref($pl->client);
    my $testing = "$clientaddr -  $clientname - " . unpack('L',$myaddr);

    unless ( unpack('L',$myaddr) ) { # when linkdead this unpack gives zero
        #print "$testing\n";
        ##current_user( $pl );
        log_file( 'logon.log', "Linkdead." );
        log_file( 'banned.log', "Probable hacker from $clientname ($clientaddr)." );
        shout( $pl->short . ' ' . std_msg('NotifyLinkdead') . "\n" ) if exists $this->user_names->{$pl->name} ;
        quit_client( $pl->client );
        ##current_user( 0 );
    }
}
        
# ---------------------------------------------------------------------
# checks each connection for timeout
sub timeout_test {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $curtime = shift;
    my @test = @{ connections() } ; #values %{$this->user_names};
    foreach my $pl (@test) {
        if ( $curtime - $pl->idletime() > $pl->maxidletime() ) {
            current_user( $pl );
            log_file( 'logon.log', "Timeout." );
            shout( $pl->short . ' ' . std_msg('NotifyLinkdead') . "\n" ) if exists $this->user_names->{$pl->name} ;
            quit_client( $pl->client );
            current_user( 0 );
        }
    };
}


# ---------------------------------------------------------------------
# ::heart_beat()
# this call the heart_beat sub on every object in the mud
sub heart_beat {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $curtime = shift;
    my @people = values %{ $this->objects };

    $this->time_last_hb( $curtime );
    $this->time_to_next( $curtime + $this->time_between );

    # for each object in the mud call its heartbeat
    my $result;
    foreach my $object ( @people ) {
        last unless $this->drv_is_alive;
        current_user( $object );
        {
            local $SIG{__DIE__} = sub { showcomperr('Engine.heart_beat', "$_[0]" ) } ;
            local $SIG{__WARN__} = sub { showwarnerr('Engine.heart_beat', "$_[0]" ) } ;
            $result = eval { $object->heart_beat( $curtime ) };
        } ;
        current_user( 0 );
    }
}
    
# ---------------------------------------------------------------------
# fulfil pending callouts of the time passed by param
# this sub simply scans the pending callouts and fulfil the expiried ones
# There is no order: i.e. no sort is done before calls.
sub fulfil_callouts {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $curtime = shift;
    my @pending = keys %{ $this->callouts } ;
    foreach my $t (@pending) {
        last unless $this->drv_is_alive;
        if ( 0 + $t <= $curtime ) {
            my @param = @{ $this->callouts->{$t} };
            my $pl = shift @param;
            my $pkg = shift @param;
            unless ( ref($pkg ) ) {
                $pkg = "$pkg";
                $pkg =~ s|::|/|g; # subst any :: with the / separator
            }
            current_user( $pl );
            my $result = call_other( $pkg, @param ) ;
            delete $this->callouts->{ $t };
            current_user( 0 );
        };
    }
}

# ---------------------------------------------------------------------
# Accepts new login
# socket_logon()
sub socket_logon {
    my $this   = shift;
    my $class  = ref($this) || $this;
    my $clientname = '<unknown>';
    my $clientaddr = '<unknown>';

    my $new = $this->listner->accept;  #IO::Socket::SSL, TLS handshake not yet done (SSL_startHandshake => 0)

    unless ( $new ) {
        log_file( 'engine.log', "Rejected connection: TCP accept failed." );
        return 0;
    }

    # complete the TLS handshake now. accept_SSL() internally polls the socket
    # non-blocking via select() up to Timeout seconds, so a slow/hostile client
    # can only cost a few seconds, never hang the single-threaded engine.
    unless ( $new->accept_SSL( Timeout => 5 ) ) {
        log_file( 'engine.log', "Rejected connection: TLS handshake failed or timed out: " . IO::Socket::SSL::errstr() );
        $new->close( SSL_no_shutdown => 1 );
        return 0;
    }

    my $hostinfo = eval { gethostbyaddr($new->peeraddr,0) } ;
    $clientname = eval { $hostinfo->name } || 'unknown';
    $clientaddr = join '.',unpack('C4',$new->peeraddr);
    
    log_file( 'engine.log', "Connection request from $clientname ($clientaddr)." );
    log_file( 'logon.log', "Connection request from $clientname ($clientaddr)." );
    
    # refues connection if client-site is present in banned-list
    my $octet4 = $clientaddr ;
    my $octet3 = $clientaddr ; $octet3 =~ s/\.\d{1,3}$/\._/;
    my $octet2 = $clientaddr ; $octet2 =~ s/\.\d{1,3}\.\d{1,3}$/\._\._/;
    my $octet1 = $clientaddr ; $octet1 =~ s/\.\d{1,3}\.\d{1,3}\.\d{1,3}$/\._\._\._/;

    my ($f4,$f3,$f2,$f1) = ( pos_array( $this->banned, $octet4) 
                           , pos_array( $this->banned, $octet3) 
                           , pos_array( $this->banned, $octet2) 
                           , pos_array( $this->banned, $octet1) );
                           
    if ( -1 != $f1 || -1 != $f2 || -1 != $f3 || -1 != $f4 || $clientaddr eq '<unknown>') {
        write_other( $new, std_msg('PromptConnectionRefused') ); 
        $new->close unless ( $clientaddr eq '127.0.0.1' ) ;
        log_file( 'banned.log', "refused connection from $clientname ($clientaddr)." );
        log_file( 'banned.log', "match $octet4") if -1 != $f4 ;
        log_file( 'banned.log', "match $octet3") if -1 != $f3 ;
        log_file( 'banned.log', "match $octet2") if -1 != $f2 ;
        log_file( 'banned.log', "match $octet1") if -1 != $f1 ;
        return 0 unless ( $clientaddr eq '127.0.0.1' ) ;
    }

    return 0 unless $this->drv_is_alive;

    # You're in.
    #write_other( $new, "\e[2J" );

    # creates a new user-object. At this point the user is still anonymous
    my $pl = User->new( $new );
    my $curtime = time();
    if ( ref($pl) ) {
        current_user( $pl );

        $new->blocking( 0 );
        $this->selector->add( $new );
    
        # binds a user with a socket.
        $this->clients->{ "$new" } = $pl; # To be moved inside User.pm ??
        $pl->clientname( $clientname ); 
        $pl->peerhost  ( $clientaddr ); 
        $pl->lastlogon ( $curtime    );
        log_file( 'logon.log', "is connecting from $clientname ($clientaddr)." );
    
        # sends logon welcome-screen to user
        cat( getdir('dirdoc') . $this->welcome_splash() );
    
        my $uptime = $curtime - $this->time_boot();
        my $ss = $uptime % 60; $uptime = int($uptime/60);
        my $mi = $uptime % 60; $uptime = int($uptime/60);
        my $hh = $uptime % 24; $uptime = int($uptime/24);
        my $dd = $uptime;
        my $output = '';
        $output .= parse_std_msg('PromptUptime', $dd, $hh, $mi, $ss) ; 
        $output .= parse_std_msg('PromptYourIpAddr', $clientname, $clientaddr ); 
        $output .= parse_std_msg('PromptLoggedUser', scalar keys %{$this->user_names} ); 
        $output .= parse_std_msg('PromptLogin') ; 
        write_client( $output );
    }
    else {
        write_other( $new, std_msg('PromptConnectionFailed') );
        $new->close;
        log_file( 'engine.log', "Cannot build object from $clientname ($clientaddr)." );
        return 0;
    }
    
    my $ch; # chunk of input stacked to input_buffer
    my $num; # length of chunk read
    $num = sysread $new, $ch, $this->bytes_per_poll ;
    log_file( 'preinputdata.log',"$ch" );
    
    current_user( 0 );
    return 1;
}

# ---------------------------------------------------------------------
# process client input
# socket_process( client )
sub socket_process {
    my $this   = shift;
    my $class  = ref($this) || $this;
    my $client = shift;
    my $pl     = client_to_user( "$client" ) || 0;    
    my $ch; # chunk of input stacked to input_buffer
    my $input_line;
    my $rest_of_line;
    my $num; # length of chunk read
    my $result;
    my $input_to; # name of routine that will handle the input.

    my $clientname = $pl->clientname;
    my $clientaddr = $pl->peerhost;

    # read as many character available (up to bytes_per_poll)
    $num = sysread $client, $ch, $this->bytes_per_poll;

    # this verifies that $pl is inherited from User--Living--Object and Mud is alive
    if ( not (ref($pl) && $pl->isa('User') ) ) {
        log_file( 'engine.log', "Client $clientname ($clientaddr) not assigned to any user!" );
        log_file( 'inputdata.log', "$clientname ($clientaddr) : " . "$ch." );
        return 0;
    }

    current_user( $pl );

    # Link-dead client test.
    if ( $num == 0 ) {
        $this->linkdead_test( $pl );
    }

    if ( not $this->drv_is_alive ) {
        log_file( 'engine.log', "Client $clientname ($clientaddr) running on dead driver!" );
        log_file( 'inputdata.log', $pl->input_number . "$clientname ($clientaddr) : " . "$ch." );
        return 0;
    }

    $pl->input_number( 1 + $pl->input_number );
    my $msg = "$ch";
    $msg =~ s/\x01//g;
    $msg =~ s/\x02//g;
    $msg =~ s/[\012]$// ;
    $msg =~ s/[\015]$// ;
    push  (@{ $pl->inputhistory }, $msg) unless $pl->status eq 'Logon' && (1 == $pl->step || 2 == $pl->step);
    shift @{ $pl->inputhistory } while scalar(@{ $pl->inputhistory }) > $this->historymaxlen() ;
    
    # Active reaction-defense. Within the first n lineinput, the driver reacts to 
    # some sequences of character disconnecting the hacker.
    if ( $pl->input_number <= $this->{'FirstLoggedInput'} ) {
        log_file( 'inputdata.log', $pl->input_number ." $clientname ($clientaddr) $msg." ) ;
        # Anfame reaction !
        my @trg = @{ $this->{ReactionTrigger} };
        for( my $k = 0; $k < @trg; $k++ ) {
            my $match = $trg[$k];
            if ( $msg =~ m/$match/ ) { # es: USER-fadm��
                log_file( 'banned.log', "Trigger $& reaction $this->{ReactionFilename}->[$k]." );
                cat( getdir('dirdocsys') . $this->{ReactionFilename}->[$k] ) ;
                $pl->status('Quit');
            }
        }
    }
    
    # reset notify messages to default 
    notify_fail( std_msg('NotifyFail') );

    # append this chunk to the input-buffer
    $pl->inputbuff( $pl->inputbuff . $ch );
    
    # while there is any character in input-buffer
    while ( $pl->inputbuff && $pl->status ne 'Quit') { 
        last unless $this->drv_is_alive;

        if ( $pl->inputbuff =~ m/([\015\012])/  ) {
            # extract the first "line" as input_line and store the rest_of_line
            ($input_line,$rest_of_line) = ($`,$');
            $input_line =~ s/[\015\012]$//; # clean trailing cr/lf
            $rest_of_line =~ s/^[\015\012]//; # clean leading cr/lf
            $pl->inputbuff( $rest_of_line );
        }
        else {
            # leave now if the input-line is not completed by a cr/lf
            # giving a chance at next loop call
            last; 
        }
        
        # original input line is saved anyway in the InputLine member
        $input_line = wipe_bs( $input_line );
        $input_line =~ s/^\000//;
        $pl->inputline( $input_line ); 
        
        # this time is marked as the user idle-time
        $pl->idletime( time() );
        
        # snoop handler of typed strings
        write_snoopees( $pl, $input_line ) if $pl->can_be_snooped;

        # calls the "input" handler, i.e. process_logon() or process_normal().
        $input_to = $pl->query_input_to ;
        $pl->input_to( 0 );

        unless( $input_to ) {
            # defaulting: these sub are declared in Commons.
            $input_to = 'process_logon'   if $pl->status eq 'Logon'; 
            $input_to = 'process_normal'  if $pl->status eq 'Ok'; 
            $input_to = 'process_startup' if $pl->status eq 'Start'; 
        }

        if ( $pl->debugging & 1024 ) {
            print $pl->name . " breakpoint: " . $input_line . "\n";
            # Set a breakpoint after *this* line when using "Open Perl IDE"
            1;
        }

        # standard input_to
        if ( $input_to =~ m/^\s*(\w+)\s*$/ ) { 
            call_input_to( $input_to, $input_line );
        }
        # custom input_to
        else {
            my $found = '';
            # search for function in pathlist
            foreach my $path ( @{ $this->{InputToPath} } ) {
                if ( $input_to =~ m/^\s*${path}::[\w:]+\s*$/ ) { $found = $path; last }
            }
            if ( $found eq '' ) {
                log_file( 'command.log', "Failed process input_to $input_to." );
            }
            else {
                log_file( 'command.log', "Trying process input_to $input_to." ) if $pl->debugging & 32 ;
                call_input_to( $input_to, $input_line );
            }
        }

        # prompt for next input
        write_parsed( $pl->stand_prompt ) if ref($pl) && $pl->status eq 'Ok' && ! $pl->query_input_to;
    
    }    

    # immediately quits if status is 'Quit'.
    quit_client( $client, $pl ) if $pl->status eq 'Quit';

    # reset notify messages to their defaults 
    notify_fail( std_msg('NotifyFail') );
    #notify_error( std_msg('NotifyError') );

    current_user( 0 );
    
    return 1;
}

# ---------------------------------------------------------------------
sub call_input_to {
    my $input_to = shift;
    my $input_line = shift;
    my $result = eval qq{ $input_to( \$input_line ) };
    return $result;
}

# ---------------------------------------------------------------------
# Private
# These subs are accessible from this package only.
# ---------------------------------------------------------------------
# process the logon phase. This is called from Engine.
sub process_logon {
    my $this       = driver();
    my $input_line = shift;
    my $pl         = current_user();
    # process input string is splitted by spaces
    
    unless ( ref($pl) && $pl->isa('User') ) {
        log_file( 'engine.log', "No ref User during process_logon.");
        return 0;
    }
    
    $input_line =~ s/\W//g if 0 == $pl->step ; 
    $input_line =~ s/\d//g if 0 == $pl->step ; 
    $input_line =~ s/[^!-~]//g if 0 < $pl->step ;
    ###print ">>$input_line<<\n";
    
    my @param = split( /\s+/, $input_line );
    my $result;

    if    (0 == $pl->step) { $result = process_username( @param ); }
    elsif (1 == $pl->step) { $result = process_passw( @param ); }
    elsif (2 == $pl->step) { $result = process_passw2( @param ); }
    elsif (3 == $pl->step) { $result = process_kickout( @param ); }

    if ( $result <= 0 ) {
        $pl->attempt( ( $pl->attempt || 0 ) + 1 );
        # allow three attempts
        if ( $pl->attempt >= $this->attempts ) {
            write_parsed( std_msg('PromptTooManyAttempts') ); 
            $pl->status('Quit');
            #quit_client( $pl->client );
            log_file( 'logon.log', "Too many attempts.");
            return 0;
        }
        unless( $result ) {
            $pl->status('Logon'); 
            my $username = $pl->keyname;
            write_parsed( std_msg('PromptRedo'), ucfirst($username) );
            log_file( "engine.log", "wrong password #" . $pl->attempt . "." );
        }
    }
    
    return 1;
}
        
# ---------------------------------------------------------------------
# normal process handling
sub process_normal {
    my $this = driver();
    my $input_line = shift;
    my $pl         = current_user();
    my $result;
    my $i = 0;
    my $num = length($input_line);
    my $sum = 0;        
    my $den ;
    
    unless ( ref($pl) && $pl->isa('User') ) {
        log_file( 'engine.log', "No ref User during process_normal.");
        return 0;
    }

    $pl->bandwidthup( $pl->bandwidthup + $num );

    # if the previous two condition are verified ten times then
    # forces quit and adds your site to banned site address
    # so you cannot connect again (at least until next shutdown)
    if ( $pl->iamarobot > 10 ) { #$pl->maxiamaraobot ) {
        $pl->force_to('quit') ;
        log_file( "engine.log",  "Quitting.") ;
        push @{$this->{BannedSiteAddress}}, $pl->peerhost(); 
    }

    # buffers last n input
    $den = time() - shift @{$pl->inputtime} ;
    push @{$pl->inputtime}, time() ;
    shift @{$pl->inputstat} ;
    push @{$pl->inputstat}, $num ;
    foreach my $t (@{$pl->inputstat}) { $sum += $t } ;

    #foreach my $t (@{$pl->inputtime}) { write_client( $t - $pl->logontime . " " )} ; 
    #write_client( ", " );
    #foreach my $t (@{$pl->inputstat}) { write_client( "$t " ) } ;
    #write_parsed( "sum: $sum, den: $den, rate: " . $sum / $den . "\n" ); 
    
    # this checks if you typed too many lines in too little time 
    if ( $this->maxrobotbuffer / $den > $this->maxlinespersec ) {
        log_file( "engine.log",  "Too many lines.") ;
        $pl->iamarobot( 1 + $pl->iamarobot );
        write_parsed( std_msg('NotifyTooManyLines'), $pl->iamarobot ) ;
        return 0;
    }
    
    # this checks if you typed too many characters per seconds 
    if ( $sum / $den > $this->maxcharpersec ) {
        log_file( "engine.log",  "Too many characters.") ;
        $pl->iamarobot( 1 + $pl->iamarobot );
        write_parsed( std_msg('NotifyTooManyCharacters'), $pl->iamarobot ) ;
        return 0;
    }

    # here log everything typed
    write_debug( 8, "process_normal( $input_line ) \n") ;
    log_file( "inputdata.log",  ">> $input_line") if $pl->debugging & 8 ;

    # alias-parser.
    $input_line = parse_alias( $input_line );

    # multicommand splitter
    my $sp = $this->cmd_splitter();
    $sp = '\|' unless $sp eq '\|' or $sp eq ';' ;
    foreach my $command ( split(m/$sp/ , $input_line ) ) {
        last if $i++ > $this->maxcommands; # ignores any further command in a one-line-multi-command
        
        # the normal process of an input line is to "force" the user to "do" an action    
        # this returns 1:success, 0:failure
        $result = $pl->force_to( $command ); # uses current_user();

        if ($result) {
            log_file( "engine.log", "Command $command executed." ) if $pl->debugging & 8 ;
        }
        else {
            my $prompt = notify_fail(); # gets the current notify-fail string
            tell_object( $pl, $prompt, "\n" ); 
        }
        write_debug( 8, "process_normal() >> $result \n") ;
        last if $pl->inputline eq ''; # hook to leave this loop immediately
    }
    return $result;
}
        
# ---------------------------------------------------------------------
# process the logon phase. This is called from Engine.
sub process_startup {
    my $this       = driver();
    my $input_line = shift;
    my $pl         = current_user();

    unless ( ref($pl) && $pl->isa('User') ) {
        log_file( 'engine.log', "No ref User during process_startup.");
        return 0;
    }

    my $room       = $pl->environment();
    # process input string is splitted by spaces
    my @param = split( /\s+/, $input_line );

    write_debug( 8, "process_startup($input_line) \n") ;

    # the user environment is expected to have a "startup" function that will
    # handle the input of the startup phase.
    tell_object( $pl, "Startup KO.\n" ) unless ref($room);
    eval { $room->startup( @param ) } if ref($room); 
    
    return 1;
}
        
# ---------------------------------------------------------------------
# logon by userid
# process_username -- step 0
sub process_username {
    my $this     = driver();
    my $username = "@_";
    my $pl       = current_user();
    my $maxusernamelen = $this->maxusernamelen() ;

    $username =~ s/ //g;
    $username = lc($username);
    $username = substr($username,0, $maxusernamelen-1); 

    unless ( ref($pl) && $pl->isa('User') ) {
        log_file( 'engine.log', "No ref User during process_username.");
        return 0;
    }

    # silently accept username and wait for password.
    if ($username) {

        # check banished username
        foreach my $elt ( @{getsetup('Banish')} ) { 
            if ( lc($elt) eq lc($username) ) {
                write_parsed( std_msg('PromptBanished'), ucfirst($username) ); 
                log_file( "banish.log", "The name $username is reserved or banished." );
                return 1; # without changing step.
            }
        }
 
        #my @switched = values %{$this->user_names};
        #for my $v (@switched) { 
            #if ($v->name eq $username ) {
                ###call_out( 1, 
                ###print $v->switched_by, " switches \n";
                ###last;
            #}
        #}
       
        ###$pl->name( $username );
        $pl->step(1);
        $pl->keyname( $username );
        
        ##save_user( $pl ); # stores a "guest" config file. Useful for intruder detection

        if ( user_exists( "$username" ) ) { 
            write_parsed( std_msg('PromptPassw'), ucfirst($username) ); 
            log_file( "engine.log", "is now logging on." );
        } 
        else {
            write_parsed( std_msg('PromptNewUser'), ucfirst($username) ); 
            log_file( "engine.log", "is now logging on (new)." );
        }
    }
    else {
        write_parsed( std_msg('PromptLogin') ); 
        log_file( "engine.log", "unknown is now logging on." );
        return -1;
    }

    return 1;
}

# ---------------------------------------------------------------------
# process_passw -- step 1
sub process_passw {
    my $this     = driver();
    my $password = shift;
    my $pl       = current_user();
    
    unless ( ref($pl) && $pl->isa('User') ) {
        log_file( 'engine.log', "No ref User during process_passw.");
        return 0;
    }
    
    my $username = $pl->keyname;
        
    return 0 unless $password; 

    # new user
    $salt = length($username).length($password) ^ '@_';
    if ( ! user_exists("$username") ) { 
        $pl->password( crypt($password,$salt) ); 
        $pl->step(2);
        write_parsed( std_msg('PromptPassw2'), ucfirst($username) ); 
        log_file( "engine.log", "new user." );
    }
    # known user
    elsif ( $this->password( "$username" ) eq crypt($password,$password) # old-style
         or $this->password( "$username" ) eq crypt($password,$salt)
          ) { 

        # renew password crypt-style.
        $pl->password( crypt($password,$salt) ); 
        my $dbh = dbi();
        my $sth = $dbh->prepare( 
            qq[ update engine_password set passwd=?, newpwd='NEW' where username=? ] );
        unless ( $dbh->err ) {
            $sth->execute( $pl->password(), $username );
        }

        if( username_to_client( $pl->keyname ) ) { 
            $pl->step(3);
            write_parsed( std_msg('PromptKickOut'),std_msg('yes'),std_msg('no') );
            log_file ("engine.log", "tries to reconnect." );
        } 
        else { 
            # you are known here and gave me the right password
            $pl->config( getdir('dircfgusers') . $username . '.cfg' );
            process_enter();
            log_file( "engine.log", "connected." ); 
        }
    }
    # wrong password
    else {
        return 0;
    }
    return 1;
}

# ---------------------------------------------------------------------
# password confirmation
# ::process_passw2( client, user ) step 2
sub process_passw2 {
    my $password = shift || '0';
    my $this     = driver();
    my $pl       = current_user();

    unless ( ref($pl) && $pl->isa('User') ) {
        log_file( 'engine.log', "No ref User during process_passw2.");
        return 0;
    }

    my $username = $pl->keyname;
    
    $salt = length($username).length($password) ^ '@_';
    if ( $pl->password() eq crypt($password,$salt) ) { 
        my $sth = dbi->prepare(
            qq[ insert into engine_password values( ?, ?, 'NEW') ] );
        $sth->execute( $username, $pl->password() ); # new user
        $sth->finish();
        ###$this->passwords->{ "$username" } = $pl->password(); # new user
        ###store_config( $this->passwords, getdir('dirdbsqlite') . "passwords.cfg" ) ;
        process_enter();
        $pl->store( getdir('dircfgusers') . $username . '.cfg' );
        log_file( "engine.log", "connected (new user)." ); 
    }
    else{ 
        return 0; # ko
    }
    return 1;
}

# ---------------------------------------------------------------------
# process_kickout( Y/N ) (step 3)
sub process_kickout {
    my $this     = driver();
    my $client   = current_client();
    my $pl       = current_user();

    unless ( ref($pl) && $pl->isa('User') ) {
        log_file( 'engine.log', "No ref User during process_kickout.");
        return 0;
    }

    my $reply    = shift;
    my $username = $pl->keyname;
    my $match    = std_msg('yes');
        
    if ( $reply =~ m/^$match/i ) { 
        my $other_client = username_to_client( $pl->keyname );
        write_other( $other_client, parse_std_msg('PromptKickOutOther', ucfirst($username) ) );
        quit_client( $other_client );
        $pl->config( getdir('dircfgusers') . $username . '.cfg' );
        process_enter();
        log_file( "engine.log", "connected (kick out)." ); 
    }
    else{ 
        return 0; # ko
    }
    return 1;
}

# ---------------------------------------------------------------------
# process_enter( )
sub process_enter {
    my $this     = driver();
    my $client   = current_client();
    my $pl       = current_user();

    unless ( ref($pl) && $pl->isa('User') ) {
        log_file( 'engine.log', "No ref User during process_enter.");
        return 0;
    }

    my $username = $pl->keyname;
    $pl->name( $username );
    $pl->maxidletime( getsetup('MaxIdleTime') ) if getsetup('MaxIdleTime');
    my $clientname = $pl->clientname(); 
    my $clientaddr = $pl->peerhost(); 
    my $result;
  
    register_object( "$username", $pl );
    
    $this->user_names->{ "$username" } = $pl->client; # late-binding.

    write_client( "\n" );

    if ( $pl->level > 0 ) {
        $pl->display_startup_info;
    }
        
    log_file( 'logon.log', "is entering from $clientname $clientaddr." );

    $result = $pl->move( $pl->initial_room ); 
    
    if ( $result < 0 ) {
        write_client( std_msg('NotifyWrongClient')."\n" );
    }
        
    if ( $pl->level > 0 ) {
        $pl->status('Ok') ;  
        daemon('patch','do_patch'); 
        shout ( parse_string( $pl->logonshout() ) );
        save_user( $pl );
        log_file( 'logon.log', "Connects from ", 
           $pl->peerhost(), " ",
           $pl->clientname() ); 
    }
    else {
        $pl->status('Start') ;
        $pl->environment->startup();
    }
}

# ---------------------------------------------------------------------
sub service {
    print "This is service\n";
}

1;

