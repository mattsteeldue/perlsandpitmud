# time_daemon.pl
# Created Jan 2007
# Author  flogisto

# Time daemon handles many time functionalities.
# - calendar: see "kal" command
# 

use Daemon;

# ---------------------------------------------------------------------
sub globalseason    { (@_)>1 ? $_[0]->{GlobalSeason}    = $_[1] : $_[0]->{GlobalSeason}   }
sub globalmonth     { (@_)>1 ? $_[0]->{GlobalMonth}     = $_[1] : $_[0]->{GlobalMonth}    }
sub globalday       { (@_)>1 ? $_[0]->{GlobalDay}       = $_[1] : $_[0]->{GlobalDay}      }
sub globaldayofyear { (@_)>1 ? $_[0]->{GlobalDayOfYear} = $_[1] : $_[0]->{GlobalDayOfYear}}
sub globalhour      { (@_)>1 ? $_[0]->{GlobalHour}      = $_[1] : $_[0]->{GlobalHour}     }
sub globalminute    { (@_)>1 ? $_[0]->{GlobalMinute}    = $_[1] : $_[0]->{GlobalMinute}   }
sub globalmoon      { (@_)>1 ? $_[0]->{GlobalMoon}      = $_[1] : $_[0]->{GlobalMoon}     }
sub globaldaymoon   { (@_)>1 ? $_[0]->{GlobalDayMoon}   = $_[1] : $_[0]->{GlobalDayMoon}  }
# ---------------------------------------------------------------------
sub temp            { (@_)>1 ? $_[0]->{Temp}            = $_[1] : $_[0]->{Temp}           }
sub baro            { (@_)>1 ? $_[0]->{Baro}            = $_[1] : $_[0]->{Baro}           }
sub humi            { (@_)>1 ? $_[0]->{Humidity}        = $_[1] : $_[0]->{Humidity}       }
sub lastweathertime { (@_)>1 ? $_[0]->{LastWeatherTime} = $_[1] : $_[0]->{LastWeatherTime}}
sub lastsavealltime { (@_)>1 ? $_[0]->{LastSaveAllTime} = $_[1] : $_[0]->{LastSaveAllTime}}
sub lasthazardtime  { (@_)>1 ? $_[0]->{LastHazardTime}  = $_[1] : $_[0]->{LastHazardTime} }
# ---------------------------------------------------------------------
sub tempH           { (@_)>1 ? $_[0]->{TempH}           = $_[1] : $_[0]->{TempH}          }
sub baroH           { (@_)>1 ? $_[0]->{BaroH}           = $_[1] : $_[0]->{BaroH}          }
sub humiH           { (@_)>1 ? $_[0]->{HumiH}           = $_[1] : $_[0]->{HumiH}          }
# ---------------------------------------------------------------------

sub query_kal {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $driver = driver();
    my $pl    = current_user();

    my $msg = getsetup('Season')->[ $this->globalseason ]               . ", " 
                        . getsetup('Month')->[ $this->globalmonth  ] . " " 
                        . $this->globalday   . " - "  
                        . ($this->globalhour<10?'0':'') . $this->globalhour  . ":" 
                        . ($this->globalminute<10?'0':'') . 10*int($this->globalminute/10)  . " - " 
                        . getsetup('Moon')->[ $this->globalmoon  ] . " ("
                        . $this->globaldaymoon . ")"  ;
                        
    $msg .=               " t:" . $this->temp 
                        . " p:" . $this->baro 
                        . " h:" . $this->humi  if $pl->wizardhood();
    return $msg;
}

# ---------------------------------------------------------------------
sub query_daylight {
    my $dh = getsetup('HourPerGameDay'    ); 
    my $h = daemon('time')->globalhour();  
    my $b = 1;
    $b = 0 if $h > $dh * 3/4;
    $b = 0 if $h < $dh * 1/4;
    return $b;
}

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( 'time_daemon' );
    bless $self, $class ;

    # last changement time.
    $self->lastweathertime( 0 );
    # temperature
    $self->temp( 0 );    # -10 - 40
    # barometric pressure
    $self->baro( 1000 );  # 800 - 1100  
    # humidity
    $self->humi( 60 );

    # History
    $self->tempH ( [ 10,10,10,10,10,10,10,10,10,10 ] );
    $self->baroH ( [ 1000,1000,1000,1000,1000,1000,1000,1000,1000,1000 ] );
    $self->humiH ( [ 80,80,80,80,80,80,80,80,80,80 ] );

    $self->lastsavealltime( -1 );

    $self->globalhour(25); # just to avoid unwanted messages.
    $self->globalminute(61);
   
    return $self;
}

# ---------------------------------------------------------------------
sub heart_beat {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $tt    = shift || time();
    $this->SUPER::heart_beat($tt);

    # CALENDAR SECTION
    $this->heart_beat_calendar( $tt );

    # WEATHER SECTION - METEO
    if ( $tt > $this->lastweathertime + getsetup('WeatherDelay') ) {
        $this->lastweathertime( $tt );
        $this->heart_beat_meteo( $tt );
    }

    # SAVE-ALL SECTION
    if ($tt > $this->lastsavealltime + getsetup('SaveAllDelay') ) { 
        save_all_users;
        $this->lastsavealltime( $tt );
    }
    
    # HAZARD SECTION
    #if ($tt > $this->lasthazardtime ) { # + 5 * getsetup('WeatherDelay') ) { 
    #    $this->lasthazardtime( $tt );
    #    $this->heart_beat_hazard( $tt );
    #}
    
    return 1;
}

# ---------------------------------------------------------------------
sub heart_beat_calendar {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $driver = driver() ;
    my $tt = shift || time() ;
    
    $tt += getsetup('TimeSynchronization');
    
    my $prevhhmm = $this->globalhour() + $this->globalminute() / 60;
    
    # reads some basic constants and update calendar.
    my $dt = getsetup('SecondPerGameHour' ); 
    my $dh = getsetup('HourPerGameDay'    );
    my $ss = ($tt % $dt);
    $this->globalminute( int( 60 * $ss/$dt ) ); # in "seconds" within an "hour"
    $tt = int($tt/$dt);
    $this->globalhour( $tt % $dh ); 
    $tt = int($tt/$dh);
    $this->globaldayofyear( $tt );

    # calc day, month and season, traversing month array
    my $dd = getsetup('DayPerGameMonth'   ); # ref-array of days in each month
    my $ds = getsetup('MonthPerGameSeason'); 
    my $dp = getsetup('SeasonDisplacement'); 
    my $dx = scalar @{ getsetup('Season') } ;
    my $dy = 0;
    foreach my $ii (@{$dd}) { $dy += $ii };
    $tt = 1 + $this->globaldayofyear() % $dy; 
    my $im = 0;
    while ( $tt > $dd->[$im] ) { $tt -= $dd->[$im]; $im++ }
    $this->globalday( $tt ); 
    $this->globalmonth( $im ); # starts from zero
    $this->globalseason( int( ($im + $dp) / $ds) % $dx );

    # calc moon
    my $dm = $dy / scalar @{ getsetup('Moon') } ; #getsetup('DayPerGameMoon'    ); 
    $tt = $this->globaldayofyear() + getsetup('DayMoonDisplacement');
    $tt = $tt % $dy;
    $this->globalmoon( int($tt / $dm) ); # starts from zero
    $this->globaldaymoon( 1 + int($tt - $dm * int($tt / $dm) ) ); # starts from zero

    # calc midnight, dawn, noon, sunset.
    my $ldisp = getsetup('MonthDaylightDelta')->[ $this->globalmonth  ] / 60 ; 
    my $hhmm = $this->globalhour() + $this->globalminute() / 60;
    shout(getsetup('DayMessageMidnight')) if $hhmm <  1 && $prevhhmm > 23;
    shout(getsetup('DayMessageDawn'    )) if $hhmm >= 6-$ldisp && $prevhhmm < 6-$ldisp;
    shout(getsetup('DayMessageNoon'    )) if $hhmm >= 12 && $prevhhmm < 12;
    shout(getsetup('DayMessageSunset'  )) if $hhmm >= 18+$ldisp && $prevhhmm < 18+$ldisp;
}
    
# ---------------------------------------------------------------------
sub heart_beat_meteo {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $driver = driver() ;
    my $tt = shift || time();

    my $rnd ;
    my $mult;
    my $deltatemp = 0 ;
    my $deltabaro = 0 ;
    my $deltahumi = 0 ;
    my $daylight  = 0 ;
    my $tempdisp  = 0 ;
    my $frac      = getsetup('DaylightTempFrac')||2; 
    my $dh = getsetup('HourPerGameDay'    ); 

    # temperature displacement for Month: 0-20
    $tempdisp = getsetup('MonthTempDelta')->[ $this->globalmonth  ] ; 

    # temperature displacement for daylight 
    $daylight = int( $this->globalhour / $frac );
    $daylight = ($dh/$frac) - $daylight  if $daylight > ($dh/$frac)/2 ;
  
    # random behaviour
    $mult = 1 + int(rand(2)); # random number between 1 and 2
    $rnd = int(rand(5)); # random number between 0 and 4
    $deltatemp = -$mult if $rnd == 0;
    $deltatemp =  $mult if $rnd == 4;
    $rnd = int(rand(5)); # random number between 0 and 4
    $deltabaro = -20*$mult if $rnd == 0;
    $deltabaro =  20*$mult if $rnd == 4;
    $rnd = int(rand(5)); # random number between 0 and 4
    $deltahumi = -10*$mult if $rnd == 0;
    $deltahumi =  10*$mult if $rnd == 4;

    # update global temp, range between -20 and +20 (later there will be a season-temp displacement).
    $this->temp ( $this->temp + $deltatemp );
    $this->temp ( -20 ) if $this->temp < -20; 
    $this->temp (  20 ) if $this->temp >  20;

    # update global pressure, range between 700 (ciclone eye) and 1180 (very dry)
    $this->baro ( $this->baro + $deltabaro );
    $this->baro (  700 ) if $this->baro <  700;
    $this->baro ( 1180 ) if $this->baro > 1180;

    # update global humidity
    $this->humi ( $this->humi + $deltahumi ); 
    $this->humi (  30 ) if $this->humi <  30; 
    $this->humi ( 100 ) if $this->humi > 100;
    
    my $dx = scalar @{ getsetup('Season') } ;
    my $season_disp = 0;
    $season_disp = 1  if $this->globalseason() == $dx/2 - 1;
    $season_disp = -1 if $this->globalseason() == $dx - 1;

    # store ten history values.
    unshift @{$this->tempH}, $this->temp ; #unless @{$this->tempH}[0] == $this->temp;
    unshift @{$this->baroH}, $this->baro ; #unless @{$this->baroH}[0] == $this->baro;
    unshift @{$this->humiH}, $this->humi ; #unless @{$this->humiH}[0] == $this->humi;
    pop @{$this->tempH} if scalar @{$this->tempH} >= 10 ;
    pop @{$this->baroH} if scalar @{$this->baroH} >= 10;
    pop @{$this->humiH} if scalar @{$this->humiH} >= 10;

    log_file ( 'time_daemon.log',  $this->query_kal() ) if getsetup('WeatherLog');

    # send meteo message (customize each client).
    my @people = values %{ $driver->clients };
    foreach my $user ( @people ) { 
        # skip if not user of user-at-logon
        next unless ( ref($user) && $user->isa('User') && ref($user->client()) && $user->status ne 'Logon' ) ;

        # skip if you're without environment.        
        my $room = $user->environment;
        next unless ref($room) ;
        next unless $room->isa('Room') ;
        
        my $subjt = $this->temp + $tempdisp + $daylight ;
        my $subjp = $this->baro ;
        my $subjh = $this->humi ;
        
        # in high mountain decrease subjective temp by 10 deg C
        $subjt -= 10 if $room->query_property('mountain') ; 

        # in dry/moist zone decrease/increase subjective humidity.
        $subjh -= 20 if $room->query_property('desert') ; 
        $subjh -= 20 if $room->query_property('volcano') ; 
        $subjh += 10 if $room->query_property('forest') ||
                        $room->query_property('garden') ;
        $subjh += 10 if $room->query_property('forest') ; 

        $subjh += 20 if $room->query_property('sea') || 
                        $room->query_property('river') ||
                        $room->query_property('lake') ||
                        $room->query_property('waterfall') ||
                        $room->query_property('swap') ||
                        $room->query_property('reef') ||
                        $room->query_property('island') ; 
                        
        my $ip = int( ($subjp - $subjh/3) / 100 );
        $ip += $season_disp if $season_disp;
        
        if ($user->wizardhood && $user->brief() & 16) {
            tell_object( $user, getcolor('Weather'), getsetup('Season')->[ $this->globalseason ], ", "  
                       , $this->globalday  , ", "  
                       , getsetup('Month')->[ $this->globalmonth  ], " "  
                       , ($this->globalhour<10?'0':'') , $this->globalhour , ":" 
                       , ($this->globalminute<10?'0':'') , $this->globalminute , " - " 
                       , "t:$subjt (",$this->temp,",$tempdisp,$daylight) " 
                       , "p:$subjp (",$this->baro,") "
                       , "h:$subjh (",$this->humi,") "
                       , "delta: $deltatemp,$deltabaro,$deltahumi"
                       , "\n" );
        }
        
        my $msg = '';
        if ( $subjt <= 0 ) { 
            $msg = getsetup('WeatherDescT00')->[ $ip - 7 ];
        }
        elsif ( $subjt <= 10 ) { 
            $msg = getsetup('WeatherDescT10')->[ $ip - 7 ];
        }
        elsif ( $subjt <= 20 ) { 
            $msg = getsetup('WeatherDescT20')->[ $ip - 7 ];
        }
        elsif ( $subjt <= 30 ) { 
            $msg = getsetup('WeatherDescT30')->[ $ip - 7 ];
        }
        else { 
            $msg = getsetup('WeatherDescT40')->[ $ip - 7 ];
        }
        
        my $outdoor = $room->query_property('outdoor') ||
                      $room->query_property('weather') ; # weather is signalled only outdoor

        #???$user->custom('WeatherLastMessage') = '---' unless defined $user->custom('WeatherLastMessage') ;
        #print "outdoor " if $outdoor;
        #print "'$msg'=='", $user->custom('WeatherLastMessage'), "' ";
        #print "diversi " if $msg ne $user->custom('WeatherLastMessage');
        #print "\n";
        my $persist  = getsetup('WeatherMessagePersistence')||3;
        my $prevmsg  = $user->custom('WeatherLastMessage')||'';
        my $lasttime = $user->custom('WeatherLastTime')||0;
        my $wdelay   = getsetup('WeatherDelay')||60;
        if ( $outdoor ) {
           if (    ( $msg ne $prevmsg ) 
                || ( $lasttime + $persist * $wdelay < $tt )
                || ( $user->wizardhood && $user->brief() & 32 ) ) {
                #tell_object( '*' ) unless $msg ne $user->custom('WeatherLastMessage')||'';
                tell_object( $user, getcolor('Weather') . "$msg.\n"  ) ;
                $user->custom('WeatherLastTime',$tt);
            }
        }
        $user->custom('WeatherLastMessage',$msg);
    }
}

# ---------------------------------------------------------------------
sub heart_beat_hazard {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $driver = driver() ;
    my $tt = shift ;
    
    shout "Hazard $tt\n";
}
