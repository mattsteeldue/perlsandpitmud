# User.pm
# Created Aug 2006
# Author  flogisto

package User;
use strict;
##use diagnostics;

use Commons;
use Living;

our @ISA = qw(Living);

=pod

=head1 User

client          reference to the client connector
input_to        name of the function that will handle the input line
password        user password (crypted)
attempt         number of attempts allowed
status          Logon or Ok or Quit.
step            step within a "status" (used in Logon etc.)
peerhost        Connection PeerHost
clientname      Connection ClientName
lastlogon       Last logon
bandwidthup     Number of bytes sent by the user
bandwidthdown   Number of bytest sent to user

logonshout      shout logon messages
logontime       time of log-on
inputline       the line just typed
inputsumch      number of characters typed in the last poll
inputsumch2     square of number of characters typed in the last poll
inputcount      number of poll
inputbuff       accumulator of data typed
inputhistory    history of lines typed
iamarobot       how many times you 
ansi_color      ansi colors disabled 0, enabled 1
wrap_col        number of columns for line wrapping [ not used yet ]
alias           mapping of alias

preload_objects preloaded objects.

wizardhood      true if wizard
level           level
role
title
idletime        time of last input
maxidletime     max allowed idletime delay
earmuffed       true if user hears the "shout"
echo
brief           true => short descriptions
stand_prompt    prompt displayed after each action ok.
char_decode      

debugging       value used for debugging (set by trace n) see muddrv.cfg 
finddir         returns the directory given a symbolic name

AdvanceUsername
ExpelUsername, ExpelMotivation
FrozenByUsername
MailAddressee, MailSubject, MailCarboncopy, MailLines, MailTimestamp, MailDeleting
CurrentWorkDirectory

=cut

# ---------------------------------------------------------------------
# client connection members
sub status          {(@_)>1 ? (($_[0]->{Step}=0,$_[0]->{Status}=$_[1]),$_[0]) : $_[0]->{Status}}
sub client          {(@_)>1 ? ($_[0]->{Client}            = $_[1],$_[0]) : $_[0]->{Client}        }
sub password        {(@_)>1 ? ($_[0]->{Password}          = $_[1],$_[0]) : $_[0]->{Password}      } 
sub attempt         {(@_)>1 ? ($_[0]->{Attempt}           = $_[1],$_[0]) : $_[0]->{Attempt}       }
sub step            {(@_)>1 ? ($_[0]->{Step}              = $_[1],$_[0]) : $_[0]->{Step}          }
sub peerhost        {(@_)>1 ? ($_[0]->{PeerHost}          = $_[1],$_[0]) : $_[0]->{PeerHost}      } 
sub clientname      {(@_)>1 ? ($_[0]->{ClientName}        = $_[1],$_[0]) : $_[0]->{ClientName}    } 
sub lastlogon       {(@_)>1 ? ($_[0]->{LastLogon}         = $_[1],$_[0]) : $_[0]->{LastLogon}     } 
sub bandwidthup     {(@_)>1 ? ($_[0]->{BandwidthUp}       = $_[1],$_[0]) : $_[0]->{BandwidthUp}   } 
sub bandwidthdown   {(@_)>1 ? ($_[0]->{BandwidthDown}     = $_[1],$_[0]) : $_[0]->{BandwidthDown} } 
sub alignment       {(@_)>1 ? ($_[0]->{Alignment}         = $_[1],$_[0]) : $_[0]->{Alignment}     } 
sub prevpeerhost    {(@_)>1 ? ($_[0]->{PrevPeerHost}      = $_[1],$_[0]) : $_[0]->{PrevPeerHost}  } 
sub prevclientname  {(@_)>1 ? ($_[0]->{PrevClientName}    = $_[1],$_[0]) : $_[0]->{PrevClientName}} 
sub prevlastlogon   {(@_)>1 ? ($_[0]->{PrevLastLogon}     = $_[1],$_[0]) : $_[0]->{PrevLastLogon} } 
sub input_number    {(@_)>1 ? ($_[0]->{InputNumber}       = $_[1],$_[0]) : $_[0]->{InputNumber}   }
sub switchee_user   {(@_)>1 ? ($_[0]->{SwitcheeUsername}  = $_[1],$_[0]) : $_[0]->{SwitcheeUsername}}
sub switched_by     {(@_)>1 ? ($_[0]->{SwitchedByUsername}= $_[1],$_[0]) : $_[0]->{SwitchedByUsername}} 
# ---------------------------------------------------------------------
# input data and statistics
sub logonshout      {(@_)>1 ? ($_[0]->{LogonShout}    = $_[1],$_[0]) : $_[0]->{LogonShout}    }  
sub logontime       {(@_)>1 ? ($_[0]->{LogonTime}     = $_[1],$_[0]) : $_[0]->{LogonTime}     }  
sub inputline       {(@_)>1 ? ($_[0]->{InputLine}     = $_[1],$_[0]) : $_[0]->{InputLine}     }  
sub inputstat       {(@_)>1 ? ($_[0]->{InputStat}     = $_[1],$_[0]) : $_[0]->{InputStat}     }  
sub inputtime       {(@_)>1 ? ($_[0]->{InputTime}     = $_[1],$_[0]) : $_[0]->{InputTime}     }  
sub inputsumch      {(@_)>1 ? ($_[0]->{InputSumch}    = $_[1],$_[0]) : $_[0]->{InputSumch}    }  
sub inputsumch2     {(@_)>1 ? ($_[0]->{InputSumch2}   = $_[1],$_[0]) : $_[0]->{InputSumch2}   }  
sub inputcount      {(@_)>1 ? ($_[0]->{InputCount}    = $_[1],$_[0]) : $_[0]->{InputCount}    }  
sub inputbuff       {(@_)>1 ? ($_[0]->{InputBuff}     = $_[1],$_[0]) : $_[0]->{InputBuff}     }  
sub inputhistory    {(@_)>1 ? ($_[0]->{InputHistory}  = $_[1],$_[0]) : $_[0]->{InputHistory}  }  
sub iamarobot       {(@_)>1 ? ($_[0]->{IAmARobot}     = $_[1],$_[0]) : $_[0]->{IAmARobot}     }  
sub ansi_color      {(@_)>1 ? ($_[0]->{AnsiColor}     = $_[1],$_[0]) : $_[0]->{AnsiColor}     }
sub wrap_col        {(@_)>1 ? ($_[0]->{WrapCol}       = $_[1],$_[0]) : $_[0]->{WrapCol}       }
sub alias           {(@_)>1 ? ($_[0]->{Alias}         = $_[1],$_[0]) : $_[0]->{Alias}         }
sub preload_objects {(@_)>1 ? ($_[0]->{Preload}       = $_[1],$_[0]) : $_[0]->{Preload}       }

# interaction
# ---------------------------------------------------------------------
sub administrator   { $_[0]->{Level} >= getsetup('LevelAdmin') ||0 } 
sub wizardhood      { $_[0]->{Level} >= getsetup('LevelWizard') ||0 } 
#sub level           {(@_)>1 ? ($_[0]->{Level}         = $_[1],$_[0]) : $_[0]->{Level}       } # inherited from Living
sub role            {(@_)>1 ? ($_[0]->{Role}          = $_[1],$_[0]) : $_[0]->{Role}          } 
sub title           {(@_)>1 ? ($_[0]->{Title}         = $_[1],$_[0]) : $_[0]->{Title}         } 
sub idletime        {(@_)>1 ? ($_[0]->{IdleTime}      = $_[1],$_[0]) : $_[0]->{IdleTime}      } 
sub maxidletime     {(@_)>1 ? ($_[0]->{MaxIdleTime}   = $_[1],$_[0]) : $_[0]->{MaxIdleTime}   } 
sub earmuffed       {(@_)>1 ? ($_[0]->{Earmuffed}     = $_[1],$_[0]) : $_[0]->{Earmuffed}     } 
sub echo            {(@_)>1 ? ($_[0]->{Echo}          = $_[1],$_[0]) : $_[0]->{Echo}          }
sub brief           {(@_)>1 ? ($_[0]->{Brief}         = $_[1],$_[0]) : $_[0]->{Brief}         }
sub stand_prompt    {(@_)>1 ? ($_[0]->{StandPrompt}   = $_[1],$_[0]) : $_[0]->{StandPrompt}   }
sub char_decode     {(@_)>1 ? ($_[0]->{CharDecode}    = $_[1],$_[0]) : $_[0]->{CharDecode}    }

# ---------------------------------------------------------------------
# Utility
sub debugging       {(@_)>1 ? ($_[0]->{Debugging}     = $_[1],$_[0]) : $_[0]->{Debugging}     }
sub short    { (@_)>1 ? $_[0] : ucfirst($_[0]->{Name}) }
sub cap_name { (@_)>1 ? $_[0] : ucfirst($_[0]->{Name}) }


# ---------------------------------------------------------------------
#                                  {NotifyFail}
#                                  {NotifyError}

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $new  = shift;
    my $self  = $this->SUPER::new(); 
    my $drv = driver();
    my $curtime = time();
    bless $self, $class;

    unregister_object( $self->keyname() ) ; 
    
    #$self->name ( 'guest' . time_to_str( $curtime, 'SSS' ) );
    $self->name ( 'guest' . $curtime ) ;

    $self->{Short} = ucfirst($self->name);
    $self->{NotifyFail} = std_msg('NotifyFail');
   #     ->{NotifyError} = std_msg('NotifyError')
         
    $self->environment      (    0 ) 
         ->living           (    1 ) 
         ->idletime         (    0 ) 
         ->maxidletime      (   60 )   # logon timeout in seconds.
         ->logontime        ( $curtime - 1 ) 
         ->logonshout( std_msg( 'ShoutEntersTheGame' ) ) 
         
         ->status           ( 'Logon' ) 
         ->client           ( $new )  
         ->input_number     (    0 ) 
         ->switchee_user    (    0 ) 
         ->switched_by      (    0 ) 
         
         ->bandwidthdown    (    0 ) 
         ->bandwidthup      (    0 ) 
         ->alignment        (    0 ) 
         
         ->presence         (    0 ) 
         ->attempt          (    0 ) 
         ->debugging        (    0 )   #driver()->debugging() );
         ->level            (    0 ) 
         ->role             (   '' ) 
         ->initial_room     ( driver()->startup_room() )
         
         ->inputline        (   '' ) 
         ->inputstat        ( [ 1 .. $drv->maxrobotbuffer ] )  
         ->inputtime        ( [ 1 .. $drv->maxrobotbuffer ] )  
         ->inputsumch       (    0 ) 
         ->inputsumch2      (    0 ) 
         ->inputcount       (    0 ) 
         ->inputbuff        (   '' ) 
         ->inputhistory     (  [ ] ) 
         ->iamarobot        (    0 ) 
         
         ->idletime         ( $curtime ) 
         ->earmuffed        (    0 ) 
         ->echo             (    1 ) 
         ->brief            (    7 ) 
         ->wrap_col         (   72 ) 
         ->ansi_color       (    1 ) 
         ->alias            (   {} ) 
         ->stand_prompt     ( '$ ' ) 
         ->char_decode ( {  'À'=>'A`',   'à'=>'a`', 
                            'È'=>'E`',   'è'=>'e`',
                            'É'=>'E\'',  'é'=>'e\'',
                            'Ì'=>'I`',   'ì'=>'i`',
                            'Ò'=>'O`',   'ò'=>'o`',
                            'Ù'=>'U`',   'ù'=>'u`', 
                       } )
         
         ->emote_target     (    0 )
         
         ->preload_objects( [ ] )
         ;       

    ##$drv->clients->{ "$new" } = $self; # To be moved back to Muddrv.pm ??
    return $self;
}

# ---------------------------------------------------------------------
sub death{ 
    my $this     = shift;
    my $class    = ref($this) || $this;
    my $attacker = shift || 0 ;
    $this->ghost( 1 );
    $this->SUPER::death( $attacker ); 
    return $this;
}

# ---------------------------------------------------------------------
sub destroy {
    my $this     = shift;
    my $class = ref($this) || $this;
    my $client   = $this->client() || return 0;
    my $name     = $this->name();
    my $drv = driver();
    log_file( 'logon.log', "quits." ) ;
    $drv->selector->remove($client);
    delete $drv->clients->{ $client } if exists $drv->clients->{ $client };
    delete $drv->user_names->{ $name } if exists $drv->user_names->{ $name };
    $this->client( 0 );
    $this->SUPER::destroy;
    $client->close;
    return $this;
}

# ---------------------------------------------------------------------
sub store {               
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $file    = shift;
    my $opt     = shift || 0;
    my $rc;

    # Switch command: do not save when I'm switching some one else.
    if ( $this->switched_by ) {
        log_file( "switch.log", $this->switched_by );
        return $this;    
    }

    # avoid storing guest-user data.
    return $this if $this->name() =~ m/^guest\d+/ ;
    
    my @accu   = @{$this->inventory};
    $this->preload_objects( [ ] ) ;
    foreach my $ob ( @accu ) {
        my $file = basename($ob->module);
        if ( $ob->query_property('permanent') ) {
            if ( -1 == pos_array( @{ $this->preload_objects }, $file ) ) {
                push @{ $this->preload_objects }, $file ;
            }
        }
    }

    $this->SUPER::store($file);

    my $dbh = dbi();
    my $sth = $dbh->table_info( undef,undef,'engine_user_info' );
    if ( $dbh->err || ! $sth->fetch() ) {
        $dbh->do( qq[
            create table engine_user_info (
            name          char(64) not null primary key,
            wizardhood    char(1),
            level         integer,
            age           integer,
            born          integer,
            gender        char(24),
            logontime     integer,
            land          char(64),
            race          char(64),
            peerhost      char(64),
            clientname    char(64),
            bandwidthdown integer,
            bandwidthup   integer,
            alignment     integer )
                    ] );
    }
    
    $sth = $dbh->prepare( qq[ select * from engine_user_info where name = ?  ]);
    $sth->execute( $this->name );
    if ( $dbh->err || ! $sth->fetch() ) {
        $sth = $dbh->prepare( qq[
            insert into engine_user_info values (
            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? ) ]);
        $sth->execute(
            $this->name          ,
            $this->wizardhood    ,
            $this->level         ,
            $this->age           ,
            $this->born          ,
            $this->gender        ,
            $this->logontime     ,
            $this->land          ,
            $this->race          ,
            $this->peerhost      ,
            $this->clientname    ,
            $this->bandwidthdown ,
            $this->bandwidthup   ,
            $this->alignment
            );
        $sth->finish();    
    }
    else {
        $sth = $dbh->prepare( qq[ 
        update engine_user_info set
            wizardhood    = ?, 
            level         = ?, 
            age           = ?, 
            born          = ?, 
            gender        = ?, 
            logontime     = ?, 
            land          = ?, 
            race          = ?, 
            peerhost      = ?, 
            clientname    = ?, 
            bandwidthdown = ?, 
            bandwidthup   = ?,
            alignment     = ?
        where 
            name          = ?     
        ] );
    
        $sth->execute( 
            $this->wizardhood    ,
            $this->level         ,
            $this->age           ,
            $this->born          ,
            $this->gender        ,
            $this->logontime     ,
            $this->land          ,
            $this->race          ,
            $this->peerhost      ,
            $this->clientname    ,
            $this->bandwidthdown ,
            $this->bandwidthup   ,
            $this->alignment     ,
            # where condition:
            $this->name  );
        $sth->finish();    
    }
    return $this;
}

# ---------------------------------------------------------------------
sub config {                
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $file    = shift;
    
    my $curtime = time();

    # Security: save some data... and call standard config.    
    my $client     = $this->client;
    my $name       = $this->name;
    my $status     = $this->status;
    my $clientname = $this->clientname;
    my $peerhost   = $this->peerhost;
    my $lastlogon  = $this->lastlogon;

    $this->SUPER::config($file);
    
    $this->prevclientname( $this->clientname ); 
    $this->prevpeerhost  ( $this->peerhost   ); 
    $this->prevlastlogon ( $this->lastlogon  );
    
    # restore saved data
    $this->client( $client );
    $this->status( $status );
    $this->name( $name );
    $this->clientname( $clientname ); 
    $this->peerhost( $peerhost ); 
    $this->lastlogon( $lastlogon );
    
    # discard something
    $this->living       ( 1 );
    $this->environment  ( 0 );
    $this->inputline    ( '');
    $this->inputstat( [ 1 .. driver()->maxrobotbuffer ] ) ;
    $this->inputtime( [ 1 .. driver()->maxrobotbuffer ] ) ;
    $this->inputsumch   ( 0 );
    $this->inputsumch2  ( 0 );
    $this->inputcount   ( 0 );
    $this->inputbuff    ('');
    ##$this->inputhistory ( [ ] );
    $this->iamarobot( 0 );
    $this->logontime    ( $curtime );
    $this->idletime     ( $curtime );
    $this->attempt( 1 );
    $this->input_number( 0 );
    $this->used_capacity( 0 );
    $this->used_payload( 0 );

    # preloaded permanent objects.
    for( my $i = 0; $i < scalar ( @{ $this->preload_objects } ); $i++ ) {
        my $file = $this->preload_objects->[$i] ;
        my $pars = [] ; #$this->cloned_params->[$i] ;
        my $ob = clone_object( $file, @{ $pars } );
        #$this->cloned_pointer->[$i] = $ob ;
        #$this->cloned_keyname->[$i] = (ref($ob) ? $ob->keyname : 0) ;
        $ob->trans_object_in( $this ) if ref($ob) ;
    }
    
    if ( $this->{Frozen} ) {
        daemon('actions','cmd_freeze', $this ) ;
    }

    ###current_user( $this );   # ????
    return $this;
}

# ---------------------------------------------------------------------
sub heart_beat  { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    $this->SUPER::heart_beat();
    
    #if ( 0 == $this->is_connected() ) {
    #    shout( $this->short() . " si tramuta in una statua di sale.\n" );
    #}
    return $this;
} 


# ---------------------------------------------------------------------
#sub is_connected  { 
#    my $this      = shift;
#    my $class     = ref($this) || $this;
#    my $drv = driver;
#    my $sel       = $drv->selector();
#    my $client    = $this->client() ;
#    
#    return -1 unless $drv->selector->exists($client);
#    return -2 unless exists $drv->clients->{ $this->client };
#    return -3 unless ref($client);
#
#    unless ( substr($client->sockname(),7,1) ne "\x00" ) {
#        log_file( 'muddrv.log', "!is connected." );
#        delete $drv->clients->{ $this->client } if exists $drv->clients->{ $this->client };
#        $this->client( 0 );
#        $drv->selector->remove($client); 
#        $client->close ;
#        return 0;
#    }
#    return 1;
#};
    
# ---------------------------------------------------------------------
sub catch_tell { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    $this->SUPER::catch_tell( @_ );
    write_other( $this->client, @_ ) if ref($this->client); # \n should be added from the caller;
    return $this;
}

# ---------------------------------------------------------------------
sub cannot_zap { 
    my $this  = shift;
    my $class = ref($this) || $this;
    ##$this->SUPER::cannot_zap();
    notify_fail( "Cannot zap users." ) if current_user();
    return $this;
}

# ---------------------------------------------------------------------
sub query_input_to{ (@_)>1 ? $_[0] : $_[0]->{InputTo} }

# ---------------------------------------------------------------------
# called with a parameter makes the next input to be processed by that function
# called without parameter resets to the default behaviour.
sub input_to      {
    my $this  = shift;
    my $par   = shift || 0;
    my ($pak,$fi,$li) = caller();

    $this->{InputTo} = $par;
    return $this->{InputTo} unless $par;
    
    # legal function can be defined within Commons, strip the leading part
    if ( $par =~ m/^Commons::(.*)/ ) {
        $this->{InputTo} = $1; 
    }
    # ... or within a package among the hierarchy.
    elsif ( $par =~ m/::/ ) {
        $this->{InputTo} = $par;
    }
    # or be equal to Commons. (what happens?)
    elsif ( $pak eq 'Commons' ) {
        $this->{InputTo} = $par;
    }
    # or be expressed as a caller's function.
    else {
        $this->{InputTo} = $pak . '::' . $par;
    }
    return $this;
    #return $this->{InputTo};
}

# ---------------------------------------------------------------------
sub display_startup_info { 
    my $this  = shift;
    my $class = ref($this) || $this;
  
    if ($this->prevlastlogon) {
        tell_object( $this, parse_std_msg('PromptYourLastLogon',
            time_to_str($this->prevlastlogon,'DD-MON-YYYY HH.MI.SS'),
            $this->prevclientname, $this->prevpeerhost ) );
    }
        
    if ( $this->level > 0 ) {
        cat_wrap( getdir('dirdocnews') . 'usernews.txt' )
    }

    if ( $this->wizardhood ) {
        cat_wrap( getdir('dirdocnews') . 'wiznews.txt' )
    }
    
    # Advertising
    cat_wrap( getdir('dirdoc') . driver()->advert_spot() ) ;

    # You have unread mail
    if ( $this->level > 0 ) {
        my $dbh = dbi();
        my $sth = $dbh->prepare( 
            qq[ select count(1) from engine_mailbox where username=? and mailread=0 ]) ;
        $sth->execute( $this->name );
        my $row  = $sth->fetch();
        my $num = 0;
        $num += $row->[0] if defined $row;
        if ( $num ) {
            tell_object( $this, parse_std_msg('YouHaveUnreadMail') );
        }
        
        if ( $this->ghost ) {
            tell_object( $this, parse_std_msg('YouAreStillGhost') );
        }
    }
    
    return $this;
}

# ---------------------------------------------------------------------
sub query_title {
    my $this     = shift;
    my $class    = ref($this) || $this;
    my $role     = $this->role || 'Default';
    my $lev      = $this->level;
    my @levels   = @{getsetup("Level$role")} ; #*1@{driver()->constants->{"Level$role"} };
    $lev = $#levels if $lev > $#levels;
    return $levels[ $lev ] ;
}

# ---------------------------------------------------------------------
sub examine_object {
    my $this     = shift;
    my $class    = ref($this) || $this;
    my ($me,$ro,$ta) = $this->SUPER::examine_object( @_ ); 
    my $obj_desc ;
    
    my $capn = $this->short();
    my $racn = $this->race();
    my $land = $this->land();
    my $artc = ($land =~ /zanelia/i ? 'di' :'della');
    
    my $hit_points      = $this->hit_points      || 0 ; 
    my $wounds          = $this->wounds          || 0 ;
    my $spell_points    = $this->spell_points    || 0 ;
    my $power           = $this->power           || 0 ; 

    my $weapon          = $this->weapon_skill    || 0 ;
    my $ballistic       = $this->ballistic_skill || 0 ;
    my $agility         = $this->agility         || 0 ;
    my $strength        = $this->strength        || 0 ;
    my $resistance      = $this->resistance      || 0 ; 

    my $damage_dice     = $this->damage_dice     || 0 ;
    my $initiative      = $this->initiative      || 0 ;
    my $presence        = $this->presence        || 0 ;
    my $movement        = $this->movement        || 0 ;
    my $left_handed     = $this->left_handed     || 0 ;

    my $helmet = ($this->armour_helmet    && $this->armour_helmet   ->desc ) || 'senza elmetto';
    my $gloves = ($this->armour_gloves    && $this->armour_gloves   ->desc ) || 'senza guanti';
    my $cloak  = ($this->armour_cloak     && $this->armour_cloak    ->desc ) || 'senza mantello';
    my $body   = ($this->armour_body      && $this->armour_body     ->desc ) || 'senza corpetto';
    my $boots  = ($this->armour_boots     && $this->armour_boots    ->desc ) || 'senza stivali';

    my $shield = ($this->armour_shield    && $this->armour_shield   ->desc ) || 'senza scudo';
    my $right  = ($this->armour_righthand && $this->armour_righthand->desc ) || 'mani nude';
    my $left   = ($this->armour_lefthand  && $this->armour_lefthand ->desc ) || '';

    my $fmt = <<'END';
Osservi @<<<<<<<<<<<<<<<<<
----------------------------------------------------
 @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      _       Liv. @<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<
     (")           @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   >--H--<         @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      H            @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      H            @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
     | |           
    _| |_          @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                              
 Classe d'armatura @<<<
 Arma   @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 Scudo  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                              
 Abilita` armi     @<<<
 Abilita` lancio   @<<<
 Agilita`          @<<<
 Forza             @<<<
 Resistenza        @<<<
---------------------------------------------------- 
END

    $^A = "";
    formline( $fmt, $capn,
        "$capn, $racn $artc $land",
        $this->level, "(".$this->query_title.")",
        $helmet, $gloves, $cloak, $body, $boots,
        $this->armour_class, $right . ' ' . $left, $shield,
        $weapon, $ballistic, $agility, $strength, $resistance
        );

    $obj_desc .= "$^A";

    return ($obj_desc, $ro, $ta);
}

# ---------------------------------------------------------------------
# returns the directory given a symbolic name
sub finddir {
    my $this     = shift;
    my $file   = shift || '/home/'.$this->name;
    my $dir    = $this->custom('CurrentWorkDirectory') || '/home/'.$this->name ;
    # directory begins with / --> set directly
    if ($file =~ /^\// ) {
        $dir = $file ;
    }
    else {    
        $dir .= '/' unless ($dir eq '/' || $dir eq '~');
        $dir .= $file;
    }
    my $normdir = basenavdir($dir);
    my $depth   = basedepth($dir);
    return "./$normdir";
}


1;
