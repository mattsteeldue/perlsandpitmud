# combat_in_progress.pl
# Created June 2008
# Author  flogisto

use Object;

sub friend          {(@_)>1 ? $_[0]->{Friend   }      = $_[1] : $_[0]->{Friend   }      }
sub foe             {(@_)>1 ? $_[0]->{Foe      }      = $_[1] : $_[0]->{Foe      }      }
sub phase           {(@_)>1 ? $_[0]->{Phase    }      = $_[1] : $_[0]->{Phase    }      }
sub pause           {(@_)>1 ? $_[0]->{Phase    }      = $_[1] : $_[0]->{Phase    }      } 

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $ob    = shift || 0;
    my $pl    = shift || 0;
    my $self  = $this->SUPER::new; 
    bless $self, $class;  
    
    $self->visible( 0 );
    
    my $friend = 'unknown';
    $friend = $pl->name if ref($pl) && $pl->isa('Living');
    my $foe = 'unknown';
    $foe = $ob->name if ref($ob) && $ob->isa('Living');

    $self->add_id( 'combat' );
    $self->short('Combattimento ' . $friend . ' vs '. $foe);
    $self->shorts('Combattimenti');
    $self->desc( "Un combattimento in corso tra \u$friend e \u$foe.");

    $self->weight ( 0 ) ; 
    $self->phase  ( 0 ) ;
    $self->phase  ( 0 ) ;
    $self->friend( [ ] );
    $self->foe( [ ] );

    if (ref($pl) && $pl->isa('Living') ) {
        $pl->combat( $self ); # combat reference to me
        $self->friend( [ $pl ] );
        $pl->attacking( $pl->attacking() + 1 );
    }
    
    if (ref($ob) && $ob->isa('Living') ) {
        $ob->combat( $self ); # combat reference to me
        $self->foe( [ $ob ] );
        $ob->attacking( $ob->attacking() + 1 );
    }

    return $self;
}

# ---------------------------------------------------------------------
sub add_friend {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $friend = shift;
    push @{$this->friend}, $friend if ref($friend) && $friend->isa('Living');
}

# ---------------------------------------------------------------------
sub remove_friend {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $friend = shift;
    unless ( -1 == pos_array( $this->friend, $friend) ) {
        remove_from_array( $this->friend, $friend) 
    }
}

# ---------------------------------------------------------------------
sub add_foe {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $foe   = shift;
    push @{$this->foe}, $foe if ref($foe) && $foe->isa('Living');
}

# ---------------------------------------------------------------------
sub remove_foe {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $foe   = shift;
    unless ( -1 == pos_array( $this->foe, $foe)) {
        remove_from_array( $this->foe, $foe) 
    }
}

# ---------------------------------------------------------------------
sub destroy {
    my $this  = shift;
    my $class = ref($this) || $this;    
    my @living = ( @{$this->friend}, @{$this->foe} );
    say('Combat is over');
    for( my $i = 0; $i <= $#living; $i++ ) { 
        my $liv = $living[$i];
        if ( ref($liv) && $liv->isa('Living') && $this == $liv->combat ) {
            $liv->combat( 0 ) ;
            $liv->attacking( $liv->attacking - 1);
        }
    }
    $this->SUPER::destroy; 
}

# ---------------------------------------------------------------------
sub cannot_get { return 1; }

# ---------------------------------------------------------------------
sub heart_beat {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $tt      = shift || time();
    $this->SUPER::heart_beat($tt);

    $this->phase( $this->phase ? 0 : 1 ); # flip-flop
    my @blue;
    my @orange;

    if ( $this->phase() ) {
        @blue = @{$this->friend};
        @orange = @{$this->foe};
    }
    else {
        @blue = @{$this->foe};
        @orange = @{$this->friend};
    }

    # case when all monster are died 
    if ( 0 == scalar(@orange) ) { # 0 == scalar(@blue) 
        $this->destroy();
        return;
    }
    
    # check if each blue-team member and orange-team member are in the same room.
    # this applies the first-attack rule.
    my @attack;
    my @defend;
    for( my $i = 0; $i <= $#blue; $i++ ) {
        if ( ref($blue[$i]) && 
             ref($orange[$i]) &&
             $blue[$i]->isa('Living') && 
             $orange[$i]->isa('Living') &&
             $blue[$i]->environment == $orange[$i]->environment ) {
            print time(), " ", $blue[$i]->name , ' vs ', $orange[$i]->name, "\n"; ###
            daemon('combat')->heart_beat_attack( $blue[$i], $orange[$i] );
            $attack[$i] = 1;
            $defend[$i] = 1; 
        }
        else {
            $attack[$i] = 0;
            $defend[$i] = 0; 
        }
    }
    
    my $any = 0;
    map { $any++ if $_ } @attack;
    if ( $any ) {
        $this->pause( 0 );
        # manage who did not attack yet.
        my $defcon = 1;
        for( my $i = 0; $i <= $#blue; $i++ ) {
            # already attacked?
            next if $attack[$i] > 0; 
            # search opponent with less attacks received.
            my $j;
            for( $j = 0; $j <= $#orange; $j++ ) { last if $defend[$j] < $defcon }
            $defend[$j]++ ; 
            $defcon = $defend[$j] if $defend[$j] > $defcon; # keep max between
            print time(), " ", $blue[$i]->name , ' vs ', $orange[$i]->name, "\n"; ###
            daemon('combat')->heart_beat_attack( $blue[$i], $orange[$j] );
        }
    }
    else {
        $this->pause( 1 + $this->pause );
        # case when all monster or you are fleed away: after a while the combat will be over.
        $this->destroy() if $this->pause >= getsetup('StopCombatDelay');
    }
    
}
