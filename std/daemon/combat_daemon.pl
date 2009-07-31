# combat_daemon.pl
# Created Jul 2007
# Author  flogisto

use Daemon;

# ---------------------------------------------------------------------
use constant {
    DICE        => getsetup('DiceSize') || 6 ,
    HANDICAP    => getsetup('CombatHandicap') || 0.70 ,
    ADVANTAGE   => getsetup('CombatAdvantage') || 0.05 ,
    TOPLEVEL    => getsetup('MaxStrength') || 10 ,
};

# ---------------------------------------------------------------------
# This function reads the 10x10 "to-hit" chart built during new
#  0|1|2|3|4|5|6|7|8|9|10
# --+-+-+-+-+-+-+-+-+-+--
#  1|4|4|5|6|6|6|6|6|6|6 
#  2|3|4|4|4|5|5|6|6|6|6 
#  3|2|3|4|4|4|4|5|5|5|6 
#  4|2|3|3|4|4|4|4|4|5|5 
#  5|2|3|3|3|4|4|4|4|4|4 
#  6|2|3|3|3|3|4|4|4|4|4 
#  7|2|3|3|3|3|3|4|4|4|4 
#  8|2|2|3|3|3|3|3|4|4|4 
#  9|2|2|2|3|3|3|3|3|4|4 
# 10|2|2|2|2|3|3|3|3|3|4 
my $tohitchart;
sub to_hit {
    my $me       = shift;
    my $attacker = shift; 
    my $defender = shift;
    $attacker =  1        if $attacker < 1;
    $attacker =  TOPLEVEL if $attacker > TOPLEVEL ;
    $defender =  1        if $defender < 1;
    $defender =  TOPLEVEL if $defender > TOPLEVEL ;
    return $tohitchart->[ $attacker ]->[ $defender ] ;
}

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( 'combat_daemon' );
    bless $self, $class ;

    ##my $msgmissed = getsetup( 'CombatMiss' ) ;
        
    # i: attacker, j:defender
    $tohitchart->[ 0 ] = [ 0 .. 10 ];
    #print @{$tohitchart->[ 0 ]}, "\n";
    for( my $i = 1; $i <= 10; $i++ ) { 
        #$tohitchart->[$i] = getsetup('CombatTohitchart' ) ;
        $tohitchart->[$i] = [ $i ];
        #print $tohitchart->[$i]->[ 0 ];
        for( my $j = 1; $j <= 10; $j++ ) { 
            # Excel formula:
            #1+($P$13-1)*(C$13/($B14+C$13))+SE(C$13>$B14*2;$P$18;0)-SE(C$13*2<$B14;$P$17;0)
            $tohitchart->[$i]->[$j] = int ( 
                1.5 + (DICE - 1) * ($j/($i+$j))
                  + ( $j>$i*2 ? HANDICAP : 0 ) # weaker attacker handicap
                  - ( $j*2<$i ? ADVANTAGE : 0 ) # weaker defender advantage
            );
            $tohitchart->[$i]->[$j] = 2 if $tohitchart->[$i]->[$j] < 2;
            #print $tohitchart->[$i]->[$j];
        }
        #print "\n";
    }
        
    return $self;
}

# ---------------------------------------------------------------------
sub heart_beat_flee {
    my $me       = shift;
    my $pl       = shift || current_user(); 

    # --- check flee each target ---
    ##tell_object( $pl, "(" );
    ##foreach my $ob ( @{ $pl->attack_target } ) {
    ##    tell_object( $pl, $ob->keyname, " $ob," );
    ##}
    ##tell_object( $pl, ")\n" );
    ###
    my @flee = ();
    foreach my $ob ( @{ $pl->attack_target } ) {
        if ( -1 == pos_array( $pl->environment->inventory, $ob ) ) {
            push @flee, $ob ;
            tell_object( $pl, parse_std_msg('Actions_Attack_stop',$ob->short ) ) ;
        }
    }
    # verify no more target
    foreach my $ob ( @flee ) {
        remove_from_array( $pl->attack_target, $ob );
        delete $pl->attack_target_distance->{$ob} ;
    }
    ###$pl->attacking( 0 ) unless ( scalar @{ $pl->attack_target } );
}

# ---------------------------------------------------------------------
sub heart_beat_attack {
    my $me       = shift;
    my $pl       = shift || return 0; 
    my $ob       = shift || return 0;
    my $combat   = current_user();
    
    return 0 unless ref($pl) && $pl->isa('Living');
    return 0 unless ref($ob) && $ob->isa('Living');
    
    # inform about yours stat.
    #if ($pl->brief() & 64) {
    #    tell_object( $pl, "[", $pl->wounds, "/", $pl->hit_points, "] " );
    #}
    
    my $idx ;
    my @accu = ();    # wizard display.
    my $distance = 0 ; #$pl->attack_target_distance->{$ob} ;
    my $damage  = 0;
    my $weapon_strength = 0;
    my $roll  = roll_dice(); # check to-hit chart
    my $match = 9999; # number the dice rolled must match: very high
    my @msg ;   # Message to you
    my @tar ;   # Message to target
    my @oth ;   # Message to others
    my @rmsg ;  # Message to you, immediate effect
    my @rtar ;  # Message to target, immediate effect
    my @roth ;  # Message to others, immediate effect
    my $arm   = $pl->armour_righthand || $pl->armour_lefthand ;
    my $armed = ref($arm) ? $pl->armed_with : $pl->barehanded ;

    # calc match value and weapon_strength
    if ( $distance ) {
        $match = $pl->ballistic_skill ;
        $weapon_strength = 1;
        # *** add bonus...
    }
    else { 
        $match = $me->to_hit( $pl->weapon_skill, $ob->weapon_skill );
        #push @accu, "WS:" , $pl->weapon_skill, "-", $ob->weapon_skill, ":", $match ;
        # *** add bonus...
    }

    # check if you hit or missed        
    push @accu, " >>> roll($roll/$match) ";
    if ( $roll < $match ) {
        # missed: message depends on how-far you missed
        @msg  = @{ $pl->combat_miss        } ;
        @tar  = @{ $pl->combat_miss_target } ;
        @oth  = @{ $pl->combat_miss_others } ;
        @rmsg = @{ $ob->combat_miss_rea    } ;
        @rtar = @{ $ob->combat_miss_reatar } ;
        @roth = @{ $ob->combat_miss_reaoth } ;
        $idx = $match - $roll ;
    }
    else {
        # hitted: message depends on damage.
        @msg  = @{ $pl->combat_hit        } ;
        @tar  = @{ $pl->combat_hit_target } ;
        @oth  = @{ $pl->combat_hit_others } ;
        @rmsg = @{ $ob->combat_hit_rea    } ;
        @rtar = @{ $ob->combat_hit_reatar } ;
        @roth = @{ $ob->combat_hit_reaoth } ;
        if ($pl->weapon_class) { 
            foreach $idx ( 1 .. $pl->damage_dice ) { $damage += roll_dice(); } 
        } 
        else {
            $damage += int(roll_dice()/2);
        }
        push @accu, "dam: $damage";
        push @accu, "+[", $distance ? $weapon_strength : $pl->strength ;
        $damage += $distance ? $weapon_strength : $pl->strength ;
        push @accu, ("-",$ob->resistance) ;
        $damage -= $ob->resistance ;
        push @accu, ("-",$ob->armour_class,"]") ;
        $damage -= $ob->armour_class ;
        push @accu, ("= $damage");
        $idx = $damage ;
    }
    $idx = $#msg if $idx > $#msg;
    $idx = 0 if $idx < 0;

    # combat communications and combat aftermath
    
    $combat->emote_target( $ob );
    current_user($pl); # temporarily.

    $armed = parse_string( $armed, (ref($arm)?$arm->short:'') );
    my $wmsg = parse_string( getsetup( 'ArmedWithMessage' ), $armed, $ob->short );
    my $wtar = parse_string( getsetup( 'ArmedWithTarget'  ), $armed, $pl->short );
    my $woth = parse_string( getsetup( 'ArmedWithOthers'  ), $armed, $pl->short, $ob->short );
    $wmsg = "$wmsg";
    $wtar = "$wtar";
    $woth = "$woth";

    my @outp = ();
    push @outp, "$wmsg" ;
    push @outp, ($pl->wizardhood ? parse_string("@accu") : '') ;
    push @outp, "\n" ;
    push @outp, parse_string( '{'.getsetup('ColorAttackMessage').'}'. $msg[ min($idx,$#msg) ], $ob->short) ;
    push @outp, parse_string( '{'.getsetup('ColorAttackerPrct') .'}'." [".int( 100*($pl->wounds / $pl->hit_points) ) ."%]{RESET}") ;
    push @outp, "\n" ;
    push @outp, parse_string( '{'.getsetup('ColorAttackOpponent').'}'. $rmsg[ min($idx,$#rmsg) ], $ob->short) ;
    push @outp, parse_string( '{'.getsetup('ColorDefenderPrct')  .'}'. " [".int( 100*($ob->wounds / $ob->hit_points) ) ."%]{RESET}" ) ;
    push @outp, "\n" ;
    tell_object($pl, @outp );

    @outp = ();
    push @outp, "   $wtar\n   " ;
    push @outp, parse_string( '{'.getsetup('ColorDefendMessage') .'}'. $tar[ min($idx,$#tar) ], $pl->short) ;
    push @outp, "\n   " ;
    push @outp, parse_string( '{'.getsetup('ColorDefendOpponent').'}'. $rtar[ min($idx,$#rtar) ], $pl->short) ;
    push @outp, "\n" ;
    tell_object( $ob, @outp );
    
    @outp = ();
    push @outp, "   $woth\n   " ;
    push @outp, parse_string( $oth[ min($idx,$#oth) ], $pl->short, $ob->short, $armed ) ;
    push @outp, "\n" ;
    push @outp, parse_string( $roth[ min($idx,$#roth) ], $ob->short, $pl->short) ;
    push @outp, "\n" ;
    say( @outp, $pl, $ob) ;

    @outp = ();
    push @outp, getsetup('RumorsNeighbour');
    #map { tell_room( $_, @outp ) } $pl->environment->query_neighbour();
    my $neigh = $pl->environment->query_neighbour_dirs() ;
    foreach my $direct ( keys %$neigh ) {
        tell_room( $neigh->{$direct}, parse_string( "@outp", $direct ) );
    }

    current_user($combat);
    $combat->emote_target( 0 );
    
    # inflict victim reaction
    if ( $damage > 0 ) {
        $ob->catch_hit( $damage, $pl ) ;
    }
    $ob->death( $pl ) if $ob->wounds < 1;
}

# ---------------------------------------------------------------------
sub living_dies {
    my $me       = shift ;
    my $pl       = shift ; 
    my $attacker = shift ;

    # attacker and pl must be both living objects.    
    return 0 unless ref($pl) && $pl->isa('Living') && ref($attacker) && $attacker->isa('Living');

    tell_object( $pl, parse_std_msg('Actions_Attack_death1', $attacker->short) );
    tell_object( $attacker, parse_std_msg('Actions_Attack_death2', $pl->short) );
    say( parse_std_msg('Actions_Attack_death3', $pl->short), $pl, $attacker ) ;
    
    shout( parse_std_msg('Actions_Attack_death4', $attacker->short, $pl->short ) );
    
}

