# Mobile.pm
# Created Aug 2006
# Author  flogisto

package Mobile;
use strict;
##use diagnostics;

use Commons;
use Living;

our @ISA = qw(Living);

# ---------------------------------------------------------------------
sub init_phrase      { (@_)>1 ? ($_[0]->{InitPhrase}     = $_[1],$_[0]) : $_[0]->{InitPhrase}     } 
sub done_phrase      { (@_)>1 ? ($_[0]->{DonePhrase}     = $_[1],$_[0]) : $_[0]->{DonePhrase}     } 
sub init_phrase_room { (@_)>1 ? ($_[0]->{InitPhraseRoom} = $_[1],$_[0]) : $_[0]->{InitPhraseRoom} } 
sub done_phrase_room { (@_)>1 ? ($_[0]->{DonePhraseRoom} = $_[1],$_[0]) : $_[0]->{DonePhraseRoom} } 
sub trigger_word     { (@_)>1 ? ($_[0]->{TriggerWord}    = $_[1],$_[0]) : $_[0]->{TriggerWord}    } 
sub chat_period      { (@_)>1 ? ($_[0]->{ChatPeriod}     = $_[1],$_[0]) : $_[0]->{ChatPeriod}     } 
sub chat_phrase      { (@_)>1 ? ($_[0]->{ChatPhrase}     = $_[1],$_[0]) : $_[0]->{ChatPhrase}     } 
sub chat_prob        { (@_)>1 ? ($_[0]->{ChatProb}       = $_[1],$_[0]) : $_[0]->{ChatProb}       } 
sub combat_phrase    { (@_)>1 ? ($_[0]->{CombatPhrase}   = $_[1],$_[0]) : $_[0]->{CombatPhrase}   } 
sub wandering_prob   { (@_)>1 ? ($_[0]->{WanderingProb}  = $_[1],$_[0]) : $_[0]->{WanderingProb}  } 
sub wandering_area   { (@_)>1 ? ($_[0]->{WanderingArea}  = $_[1],$_[0]) : $_[0]->{WanderingArea}  } 
sub trail_path       { (@_)>1 ? ($_[0]->{TrailPath}      = $_[1],$_[0]) : $_[0]->{TrailPath}      } 
sub trail_index      { (@_)>1 ? ($_[0]->{TrailIndex}     = $_[1],$_[0]) : $_[0]->{TrailIndex}     } 
sub trail_delay      { (@_)>1 ? ($_[0]->{TrailDelay}     = $_[1],$_[0]) : $_[0]->{TrailDelay}     } 

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $name  = shift || '';
    my $self  = $this->SUPER::new( $name );
    
    $self->init_phrase      (  0 ) 
         ->done_phrase      (  0 ) 
         ->init_phrase_room (  0 ) 
         ->done_phrase_room (  0 ) 
         ->trigger_word     ( {} ) 
         ->chat_phrase      ( [] ) 
         ->chat_period      ( [] ) 
         ->chat_prob        (  0 ) 
                                   
         ->wandering_prob   (  0 ) 
         ->wandering_area   ( [] ) 
                                   
         ->trail_path       ( [] ) 
         ->trail_index      (  0 ) 
         ->trail_delay      (  0 ) 
         ;
         
    bless $self, $class;

    return $self;
}

# ---------------------------------------------------------------------
sub heart_beat  { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $tt      = shift || time();
    $this->SUPER::heart_beat($tt);
    
    if ( $this->combat() ) {
        ##print "#"; ###
        return 0;
    }
    # --- wandering monster ---
    if ( $this->wandering_prob() > 0 && ref($this->environment) ) {
        my @exits = ();
        my @areas = @{$this->wandering_area};
        my $neighbour = $this->environment->query_neighbour_dirs ;
        foreach my $key ( keys %$neighbour ) {
            my $room = $neighbour->{$key};
            push @exits, $key if $room->query_wandering_area( @areas );
        }
        
        if ( scalar @exits > 0 ) {
            if ( $this->wandering_prob*100 > rand(10000) ) {
                my $rand = int( rand( scalar @exits ) );
                $this->force_to( $exits[ $rand ] );
            }
        }
        else {
            log_file( 'trapped.log', $this->environment );
            $this->wandering_prob( 0 );
        }
        
    }
    # --- trail monster ---
    if ( $this->trail_delay() > 0 && scalar( $this->trail_path() ) ) {
        my $driver = driver();
        if ( ( time() % ($this->trail_delay()) ) < ($driver->time_to_sleep + $driver->time_between) ) {
            ###print $this->trail_path->[ $this->trail_index() ], "\n";
            $this->force_to( $this->trail_path->[ $this->trail_index() ] );
            $this->trail_index( 1 + $this->trail_index() );
            $this->trail_index( 0 ) if $this->trail_index > $#{$this->trail_path()} ;
        }
    }
    # --- random chat ---
    unless ( $this->combat() ) {
        my @phrase = @{$this->chat_phrase()};
        my @period = @{$this->chat_period()};
        my $hour = daemon('time')->globalhour();
        if ( (scalar @phrase) > 0 && $this->chat_prob*100 > rand(10000) ) {
            for( my $i = $#phrase; $i >= 0; --$i ) {
                my $match = vec($period[$i],$hour,1);
                unless ( $match ) {
                    splice @phrase, $i;
                    splice @period, $i;
                }
            }
            if( (scalar @phrase) ) {
                my $rand = int( rand( scalar @phrase ) );
                say( $phrase[ $rand ] . "\n", $this ) ;
            }
        }
    }
    return $this;
}

# ---------------------------------------------------------------------
sub init {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $param   = shift; 
    $this->SUPER::init($param);
    return 0 unless $this->init_phrase() || $this->init_phrase_room();
    if( ref($param) && $param->isa('User') ) {
        remove_call_out( $this, 'init_delay', $param ); # too fast?
        call_out( 1, $this, 'init_delay', $param ); 
    }
    return $this;
}

# ---------------------------------------------------------------------
# Say a init-phrase
sub init_delay {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $param   = shift; 
    return 0 unless $param->environment == $this->environment;
    my $ob = $this->init_phrase();
    my $msg = ( ref($ob) eq 'CODE' ) ? &$ob($this,@_) : $ob ;
    tell_object( $param, parse_string( $msg, $param ) );
    $ob = $this->init_phrase_room();
    $msg = ( ref($ob) eq 'CODE' ) ? &$ob($this,@_) : $ob ;
    say( parse_string( $msg, $param ), $param );
    return $this;
}

# ---------------------------------------------------------------------
sub done {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $param   = shift; 
    $this->SUPER::init($param);

    return $this unless $this->done_phrase() || $this->done_phrase_room();

    if( ref($param) && $param->isa('User') ) {
        remove_call_out( $this, 'done_delay', $param ); # too fast?
        call_out( 1, $this, 'done_delay', $param );
    }
    return $this;
}

# ---------------------------------------------------------------------
# Say a done-phrase
sub done_delay {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $param   = shift;
    ##return 0 unless $param->environment == $this->environment;
    my $ob = $this->done_phrase();
    my $msg = ( ref($ob) eq 'CODE' ) ? &$ob($this,@_) : $ob ;
    tell_object( $param, parse_string( $msg, $param ) );
    $ob = $this->done_phrase_room();
    $msg = ( ref($ob) eq 'CODE' ) ? &$ob($this,@_) : $ob ;
    say( parse_string( $msg, $param ), $param );
    return $this;
}

# ---------------------------------------------------------------------
# add
sub add_reply {
    my $this     = shift;
    my $class    = ref($this) || $this;
    my $word     = shift;
    my $reply    = shift;
    $this->trigger_word()->{ $word } = $reply ;
    return $this;
}

# ---------------------------------------------------------------------
sub catch_tell { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my @ary     = @_;
    $this->SUPER::catch_tell( @ary );
    my $phrase = '';
    $phrase = $1 if "@ary" =~ /dice: \'(.+)\'\n$/ ;
    if ( exists $this->trigger_word()->{ $phrase } ) {
        write_client( $this->trigger_word()->{ $phrase } , "\n" ) ;
        return 1;
    }
    my @words = split / /, "$phrase";    
    foreach my $word (@words) {
        if ( exists $this->trigger_word()->{ $word } ) {
            write_client( $this->trigger_word()->{ $word } , "\n" ) ;
            return 1;
        }
    }
    return $this;
}

# ---------------------------------------------------------------------
sub death{ 
    my $this     = shift;
    my $class    = ref($this) || $this;
    my $attacker = shift || 0 ;
    $this->SUPER::death( $attacker ); 
    $this->trans_object_out( $this->environment ) ;
    $this->destroy();
    return $this;
}

# ---------------------------------------------------------------------
sub destroy {
    my $this  = shift;
    my $class = ref($this) || $this;
    $this->SUPER::destroy; 
    return $this;
}

# ---------------------------------------------------------------------
# add a named wandering area
sub add_wandering_area { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $area    = shift  || return 0;
    my $where   = $this->wandering_area;
    push @$where, $area if -1 == pos_array( @$where, $area ) ;
    return $this;
}

# ---------------------------------------------------------------------
# remove a named wandering area
sub remove_wandering_area { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $area    = shift  || return 0;
    my $where   = $this->wandering_area;
    remove_from_array( $where, $area ) unless -1 == pos_array( $where, $area );
    return $this;
}

# ---------------------------------------------------------------------
# reply 1 if an area matches with those of this room.
sub query_wandering_area { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my @areas   = @_ ;
    return 1 if $areas[0] eq '*'; #jolly.
    my $where   = $this->wandering_area;
    foreach my $area ( @areas ) {
        return 1 unless -1 == pos_array( $where, $area ) ;
    }
    return 0;
}

# ---------------------------------------------------------------------
sub add_chat {
    my $this     = shift;
    my $class    = ref($this) || $this;
    my $what     = shift;
    my $phrases  = $this->chat_phrase();
    my $periods  = $this->chat_period();
    
    my $bits = 0;
    while( my $hour = shift ) {
        $bits |= 1 << $hour;
    }
    $bits = -1 if 0 == $bits;
    
    if ( -1 == pos_array( @$phrases, $what ) ) {
        push @$phrases, $what;
        push @$periods, $bits;
    }
    return $this;
}

sub query_chat_period {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $what     = shift;
    my $phrases   = $this->chat_phrase();
    my $periods   = $this->chat_period();
    my $i = 0;
    if ( $what =~ /^\d+$/ ) {
        $i = $what;
    }
    else {
        $i = pos_array( $phrases, $what ) ;
    }
    if ($i >= 0) {
        my $h = 0;
        my @ary = ();
        my $num = $periods->[$i];
        while ($num) {
            push @ary, $h  if $num & 1;
            $num >>= 1;
            $h++;
        }
    }
    return @$periods;
}

# ---------------------------------------------------------------------
sub remove_chat { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $what     = shift;
    my $phrases   = $this->chat_phrase();
    my $periods   = $this->chat_period();
    my $i = pos_array( $phrases, $what ) ;
    if ($i >= 0) {
        splice @$phrases, $i;
        splice @$periods, $i;
    }
    return $this;
}

# ---------------------------------------------------------------------
sub set_combat_chat {
    my $this     = shift;
    my $class    = ref($this) || $this;
    my $what     = shift;
    my $phrases  = $this->combat_phrase;
    push @$phrases, $what if -1 == pos_array( @$phrases, $what );
    return $this;
}

# ---------------------------------------------------------------------
# remove a named wandering area
sub remove_combat_chat { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $what     = shift;
    my $phrases  = $this->combat_phrase;
    remove_from_array( $phrases, $what ) unless -1 == pos_array( $phrases, $what ) ;
}

1;
