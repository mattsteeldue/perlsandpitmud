# Living.pm
# Created Aug 2006
# Author  flogisto

package Living;
use strict;
##use diagnostics;

use Commons;
use Object;

our @ISA = qw(Object);

=pod

=head1 DESCRIPTION

Living object: i.e. players and monsters.
A living object is a object that can interact with other objects.

=head1 MEMBERS

new             constructor, initializes data; config will read actual data
config          retrieve data reading a configuration file (reverse of store)
store           inherited
destroy         desctuct this object (i.e. moves away and unregister)

gender          Male, Female, Neuter
race            Umani, Mezzelfi, Folletti, Ninfe, Gnomi, Draghi, Sirenidi, Fammin
land            Vento, Acqua, Mare, Sole, Giorni, Notte, Fuoco, Rocce, Zanelia, Grande.
level           1 - 10
money
ghost
echo

message_in      Thorin enters. / Thorin arriva.
message_out     Thorin leaves ... / Thorin va verso ...
message_tin     
message_tout 
message_clone
message_home 
follower        Users that are following you
following       User you are following
party           Users that are allowed to begin following you

hit_points      Maximum hit-points available
wounds          Number of hit-points consumed by wounds
spell_points    Maximum spell-points available
power           Number of spell-points consumed by wounds

weapon_skill      1 - 6 
ballistic_skill   1 - 6
agility           1 - 6
strength          1 - 6
resistance        1 - 6
damage_dice       1 - 3
initiative    
presence
movement
left_handed

armour_helmet
armour_gloves
armour_cloak 
armour_body
armour_boots 

armour_shield
armour_righthand
armour_lefthand 

armed_with
barehanded

combat_miss       
combat_miss_target
combat_miss_others
combat_miss_rea   
combat_miss_reatar
combat_miss_reaoth
                  
combat_hit        
combat_hit_target 
combat_hit_others 
combat_hit_rea    
combat_hit_reatar 
combat_hit_reaoth 

combat          array of "combat_in_progress" objects
attacking

can_be_snooped  avoid being snooped
snooper         hash (name,ref) of who is snooping this living
snoopee         ref of living you're snooping
snoopee_name    name of snoopee, for documentation purpose
silenced
silenced_by
frozen
frozen_by       name of wizard who frozen this user.

error_message

emote_target
emote_adverb
emote_where

wizardhood      stub
ansi_color      stub
brief           stub
debugging       stub
wrap_col        stub

heart_beat
catch_tell
cannot_get
armour_class
weapon_class
death
query_hp_stat
add_hp
add_sp
catch_hit
catch_flee

examine_object  returns a description of the living.
color           custom color
channel_switch





=cut

# Interactive properties
# ---------------------------------------------------------------------
sub gender          {(@_)>1 ? ($_[0]->{Gender}         = $_[1],$_[0]) : $_[0]->{Gender}         }
sub race            {(@_)>1 ? ($_[0]->{Race}           = $_[1],$_[0]) : $_[0]->{Race}           }
sub land            {(@_)>1 ? ($_[0]->{Land}           = $_[1],$_[0]) : $_[0]->{Land}           }
sub level           {(@_)>1 ? ($_[0]->{Level}          = $_[1],$_[0]) : $_[0]->{Level}          } 
sub money           {(@_)>1 ? ($_[0]->{Money}          = $_[1],$_[0]) : $_[0]->{Money}          }
sub ghost           {(@_)>1 ? ($_[0]->{Ghost}          = $_[1],$_[0]) : $_[0]->{Ghost}          }
#sub ghost           { $_[0]->{HitPoints} < 0 }
sub echo            {0}

# routing
# ---------------------------------------------------------------------
sub message_in      {(@_)>1 ? ($_[0]->{MessageIn}      = $_[1],$_[0]) : $_[0]->{MessageIn}      } 
sub message_out     {(@_)>1 ? ($_[0]->{MessageOut}     = $_[1],$_[0]) : $_[0]->{MessageOut}     } 
sub message_tin     {(@_)>1 ? ($_[0]->{MessageTIn}     = $_[1],$_[0]) : $_[0]->{MessageTIn}     } 
sub message_tout    {(@_)>1 ? ($_[0]->{MessageTOut}    = $_[1],$_[0]) : $_[0]->{MessageTOut}    } 
sub message_clone   {(@_)>1 ? ($_[0]->{MessageClone}   = $_[1],$_[0]) : $_[0]->{MessageClone}   } 
sub message_home    {(@_)>1 ? ($_[0]->{MessageHome}    = $_[1],$_[0]) : $_[0]->{MessageHome}    } 
sub following       {(@_)>1 ? ($_[0]->{Following}      = $_[1],$_[0]) : $_[0]->{Following}      } 
sub follower        {(@_)>1 ? ($_[0]->{Follower}       = $_[1],$_[0]) : $_[0]->{Follower}       } 
sub party           {(@_)>1 ? ($_[0]->{Party}          = $_[1],$_[0]) : $_[0]->{Party}          } 

# setup-combat data
# ---------------------------------------------------------------------
sub hit_points      {(@_)>1 ? ($_[0]->{HitPoints}      = $_[1],$_[0]) : $_[0]->{HitPoints}      }
sub wounds          {(@_)>1 ? ($_[0]->{Wounds}         = $_[1],$_[0]) : $_[0]->{Wounds}         }
sub spell_points    {(@_)>1 ? ($_[0]->{SpellPoints}    = $_[1],$_[0]) : $_[0]->{SpellPoints}    }
sub power           {(@_)>1 ? ($_[0]->{Power}          = $_[1],$_[0]) : $_[0]->{Power}          }
sub weapon_skill    {(@_)>1 ? ($_[0]->{WeaponSkill}    = $_[1],$_[0]) : $_[0]->{WeaponSkill}    }
sub ballistic_skill {(@_)>1 ? ($_[0]->{BallisticSkill} = $_[1],$_[0]) : $_[0]->{BallisticSkill} }
sub agility         {(@_)>1 ? ($_[0]->{Agility}        = $_[1],$_[0]) : $_[0]->{Agility}        }
sub strength        {(@_)>1 ? ($_[0]->{Strength}       = $_[1],$_[0]) : $_[0]->{Strength}       }
sub resistance      {(@_)>1 ? ($_[0]->{Resistance}     = $_[1],$_[0]) : $_[0]->{Resistance}     }
sub damage_dice     {(@_)>1 ? ($_[0]->{DamageDice}     = $_[1],$_[0]) : $_[0]->{DamageDice}     }
sub initiative      {(@_)>1 ? ($_[0]->{Initiative}     = $_[1],$_[0]) : $_[0]->{Initiative}     }
sub presence        {(@_)>1 ? ($_[0]->{Presence}       = $_[1],$_[0]) : $_[0]->{Presence}       }
sub movement        {(@_)>1 ? ($_[0]->{Movement}       = $_[1],$_[0]) : $_[0]->{Movement}       }
sub left_handed     {(@_)>1 ? ($_[0]->{LeftHanded}     = $_[1],$_[0]) : $_[0]->{LeftHanded}     } 

# armour data
# ---------------------------------------------------------------------
# garment [Body, Shield, Cloak, Boots, Gloves, Helmet, Ring, Amulet, Earring, Belt]
sub armour_helmet   {(@_)>1 ? ($_[0]->{ArmourHelmet}   = $_[1],$_[0]) : $_[0]->{ArmourHelmet}   }
sub armour_gloves   {(@_)>1 ? ($_[0]->{ArmourGloves}   = $_[1],$_[0]) : $_[0]->{ArmourGloves}   }
sub armour_cloak    {(@_)>1 ? ($_[0]->{ArmourCloak}    = $_[1],$_[0]) : $_[0]->{ArmourCloak}    }
sub armour_body     {(@_)>1 ? ($_[0]->{ArmourHead}     = $_[1],$_[0]) : $_[0]->{ArmourHead}     }
sub armour_boots    {(@_)>1 ? ($_[0]->{ArmourBoots}    = $_[1],$_[0]) : $_[0]->{ArmourBoots}    }
sub armour_shield   {(@_)>1 ? ($_[0]->{ArmourShield}   = $_[1],$_[0]) : $_[0]->{ArmourShield}   }
sub armour_righthand{(@_)>1 ? ($_[0]->{ArmourRightHand}= $_[1],$_[0]) : $_[0]->{ArmourRightHand}}
sub armour_lefthand {(@_)>1 ? ($_[0]->{ArmourLeftHand} = $_[1],$_[0]) : $_[0]->{ArmourLeftHand} }

# combat messages
# ---------------------------------------------------------------------
# These members returns the array of messages.
sub armed_with         { getsetup( 'ArmedWith'        ) } 
sub barehanded         { getsetup( 'Barehanded'       ) }
sub combat_miss        { getsetup( 'CombatMiss'       ) } # Message to you
sub combat_miss_target { getsetup( 'CombatMissTarget' ) } # Message to target
sub combat_miss_others { getsetup( 'CombatMissOthers' ) } # Message to others
sub combat_miss_rea    { getsetup( 'CombatMissRea'    ) } # Immediate effect
sub combat_miss_reatar { getsetup( 'CombatMissReaTar' ) } # Immediate effect
sub combat_miss_reaoth { getsetup( 'CombatMissReaOth' ) } # Immediate effect
sub combat_hit         { getsetup( 'CombatHit'        ) } # Message to you   
sub combat_hit_target  { getsetup( 'CombatHitTarget'  ) } # Message to target
sub combat_hit_others  { getsetup( 'CombatHitOthers'  ) } # Message to others
sub combat_hit_rea     { getsetup( 'CombatHitRea'     ) } # Immediate effect 
sub combat_hit_reatar  { getsetup( 'CombatHitReaTar'  ) } # Immediate effect 
sub combat_hit_reaoth  { getsetup( 'CombatHitReaOth'  ) } # Immediate effect 

# attack system
# ---------------------------------------------------------------------
sub combat          {(@_)>1 ? ($_[0]->{Combat}         = $_[1],$_[0]) : $_[0]->{Combat}         } 
sub attacking       {(@_)>1 ? ($_[0]->{Attacking}      = $_[1],$_[0]) : $_[0]->{Attacking}      } 
sub corpse          {(@_)>1 ? ($_[0]->{Corpse}         = $_[1],$_[0]) : $_[0]->{Corpse}         } 
# ---------------------------------------------------------------------

# snoop
# ---------------------------------------------------------------------
sub can_be_snooped  {(@_)>1 ? ($_[0]->{CanBeSnooped}   = $_[1],$_[0]) : $_[0]->{CanBeSnooped}   } 
sub snooper         {(@_)>1 ? ($_[0]->{Snooper}        = $_[1],$_[0]) : $_[0]->{Snooper}        } 
sub snoopee         {(@_)>1 ? ($_[0]->{Snoopee}        = $_[1],$_[0]) : $_[0]->{Snoopee}        } 
sub snoopee_name    {(@_)>1 ? ($_[0]->{SnoopeeName}    = $_[1],$_[0]) : $_[0]->{SnoopeeName}    } 

# silence/freeze # custom
# ---------------------------------------------------------------------
sub silenced        {(@_)>1 ? ($_[0]->{Silenced}           = $_[1],$_[0]) : $_[0]->{Silenced}          } 
sub silenced_by     {(@_)>1 ? ($_[0]->{SilencedByUsername} = $_[1],$_[0]) : $_[0]->{SilencedByUsername}} 
sub frozen          {(@_)>1 ? ($_[0]->{Frozen}             = $_[1],$_[0]) : $_[0]->{Frozen}            } 
sub frozen_by       {(@_)>1 ? ($_[0]->{FrozenByUsername}   = $_[1],$_[0]) : $_[0]->{FrozenByUsername}  } 

# notify fail
# ---------------------------------------------------------------------
sub error_message   {(@_)>1 ? ($_[0]->{NotifyFail}     = $_[1],$_[0]) : $_[0]->{NotifyFail}     } 
# ---------------------------------------------------------------------

# transient data
# ---------------------------------------------------------------------
sub emote_target    {(@_)>1 ? ($_[0]->{EmoteTarget}    = $_[1],$_[0]) : $_[0]->{EmoteTarget}    } 
sub emote_adverb    {(@_)>1 ? ($_[0]->{EmoteAdverb}    = $_[1],$_[0]) : $_[0]->{EmoteAdverb}    } 
sub emote_where     {(@_)>1 ? ($_[0]->{EmoteWhere}     = $_[1],$_[0]) : $_[0]->{EmoteWhere}     } 

# stub
# ---------------------------------------------------------------------
sub wizardhood    { (@_)>1 ? $_[0] :   0 }
sub ansi_color    { (@_)>1 ? $_[0] :   0 }
sub brief         { (@_)>1 ? $_[0] : 255 } # Bits
sub debugging     { (@_)>1 ? $_[0] :   0 }
sub wrap_col      { (@_)>1 ? $_[0] :  70 }

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $name  = shift || 0;
    my $self  = $this->SUPER::new( $name ); 
    bless $self, $class;

    $self->gender         ( std_msg('None') ) 
         ->race           ( std_msg('None') ) 
         ->land           ( std_msg('None') ) 
         ->level          (    1 ) 
         ->money          (    0 ) 
         ->ghost          (    0 ) 
         
         ->message_in     ( std_msg('Enters') ) 
         ->message_out    ( std_msg('Leaves') ) 
         ->message_tin    ( std_msg('TranEnters') ) 
         ->message_tout   ( std_msg('TranLeaves') ) 
         ->message_clone  ( std_msg('Clones') ) 
         ->message_home   ( std_msg('Home') ) 
         ->follower       (   [] ) 
         ->following      (    0 ) 
         ->party          (   [] ) 
         
         ->hit_points     (   10 ) 
         ->wounds         ( $self->hit_points ) 
         ->spell_points   (   10 ) 
         ->power          ( $self->spell_points ) 
         ->movement       (   10 ) 
         ->weapon_skill   (    1 ) 
         ->ballistic_skill(    1 ) 
         ->strength       (    1 ) 
         ->damage_dice    (    1 ) 
         ->resistance     (    1 ) 
         ->initiative     (    1 ) 
         ->agility        (    1 ) 
         ->presence       (    1 ) 
         ->left_handed    (    0 ) 
         
         ->armour_helmet   (   0 ) 
         ->armour_gloves   (   0 ) 
         ->armour_cloak    (   0 ) 
         ->armour_body     (   0 ) 
         ->armour_boots    (   0 ) 
         
         ->armour_shield   (   0 ) 
         ->armour_righthand(   0 ) 
         ->armour_lefthand (   0 ) 
         
         ->attacking       (   0 ) 
         ->combat          (   0 ) 
         
         ->can_be_snooped (   1 ) 
         ->snooper        (  [] )  
         ->snoopee        (   0 ) 
         ->snoopee_name   (  '' ) 
         ->frozen_by      (  '' ) 
         
         ->emote_target   (   0 ) 
         ->emote_adverb   (   0 ) 
         ->emote_where    (   0 ) 

         # should be in base of gender/race/land 
         ->bulk           ( 100 )  # lt
         ->weight         ( 100 )  # kg
         ->capacity       ( 100 )  # lt
         ->payload        ( 100 )  # kg
         
         
         ->short( $name ) 
         ->descs( 0 ) 
         ->living( 1 )
         
         ->set_property('transparent')  # any lantern carried will light the room.
         ;
    
    return $self;
}

# ---------------------------------------------------------------------
sub config {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $file    = shift;

    $this->SUPER::config($file) 

         ->inventory       ( [] ) 
                                  
         ->snooper         ( [] ) 
         ->snoopee         (  0 ) 
         ->snoopee_name    ( '' ) 
                                  
         ->follower        ( [] ) 
         ->following       (  0 ) 
         ->party           ( [] ) 
                                  
         ->combat          (  0 ) 
         ->attacking       (  0 ) 
                                  
         ->armour_helmet   (  0 ) 
         ->armour_gloves   (  0 ) 
         ->armour_cloak    (  0 ) 
         ->armour_body     (  0 ) 
         ->armour_boots    (  0 ) 
                                  
         ->armour_shield   (  0 ) 
         ->armour_righthand(  0 ) 
         ->armour_lefthand (  0 ) 
         ;
     return $this;
}

# ---------------------------------------------------------------------
sub destroy {
    my $this  = shift;
    my $class = ref($this) || $this;
    $this->SUPER::destroy; 
    my @ary;

    # remove who is snooping me
    @ary = @{ $this->snooper } ;
    foreach my $pl ( @ary ) {
        if ( ref($pl) && $pl->isa('User') && $pl->snoopee() == $this ) {
            tell_object( $pl, parse_std_msg('Actions_Snoop_stop', $this->short ) ) ;
            $pl->snoopee( 0 );
        }
    }
    
    # stop snooping
    my $snoop;
    $snoop = $this->snoopee();
    if ( ref($snoop) ) {
        remove_from_array( $snoop->snooper, $this );
    }

    # remove who is following me
    my $follow;
    @ary = @{ $this->follower } ;
    foreach my $pl ( @ary ) {
        if ( ref($pl) && $pl->following eq $this->name ) {
            tell_object( $pl, parse_std_msg('Actions_Follow_stop', $this->short ) ) ;
            remove_from_array( $this->follower, $pl->name );
            $pl->following( 0 );
        }
    }
    
    # stop following
    my $leader = find_living( $this->following );
    if ( $leader && ref($leader) && $leader->isa('Living') ) {
        tell_object( $leader, parse_std_msg('Actions_Follow_stop2',$this->short ) ) ;
        remove_from_array( $leader->follower, $this->name );
        $this->following( 0 );    
    }
    return $this;
}

# ---------------------------------------------------------------------
# do command
sub force_to {    
    my $this  = shift;
    my $class = ref($this) || $this;
    my $input_line = shift;
    my @param      = ();
    my $result     = 0;
    
    # normal socket processing
    # process input string is splitted by spaces
    $input_line =~ s/^\s+//; 
    @param = split( /\s+/, wipe_bs( $input_line ) );
    
    # if there is something different from a space in the input_line
    if ( $input_line =~ m/\S/ ) {
        my $command = shift @param;
    
        # do_command result's is 0 for fail or 1 for success (match)
        if ( $command ) {
            my $saved_pl = current_user();
            current_user( $this );
            $result = do_command( $command, @param ) ;
            current_user( $saved_pl );
        }
    }

    return $result; 
}

# ---------------------------------------------------------------------
# during attack, this function do the interactive part of the game.
sub heart_beat  { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $tt      = shift || time();
    my $driver  = driver();
    $this->SUPER::heart_beat($tt);
    
    # --- follow party ---
    if ( $this->following ) {
    }
    return $this;
} 

# ---------------------------------------------------------------------
sub catch_tell { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my @ary     = @_;
    $this->SUPER::catch_tell( @ary );
    write_snoopees( $this, @ary ) if $this->can_be_snooped; # Snoop handler
}

# ---------------------------------------------------------------------
sub cannot_get { 
    my $this  = shift;
    my $class = ref($this) || $this;
    notify_fail( parse_std_msg('CannotGet' , $this->short  ));
    return 1; # cannot get living objects
}

# ---------------------------------------------------------------------
sub armour_class {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $helmet = (ref($this->armour_helmet ) && $this->armour_helmet->isa('Garment')) ? $this->armour_helmet->armour_class : 0 ;
    my $gloves = (ref($this->armour_gloves ) && $this->armour_gloves->isa('Garment')) ? $this->armour_gloves->armour_class : 0 ;
    my $cloak  = (ref($this->armour_cloak  ) && $this->armour_cloak ->isa('Garment')) ? $this->armour_cloak ->armour_class : 0 ;
    my $body   = (ref($this->armour_body   ) && $this->armour_body  ->isa('Garment')) ? $this->armour_body  ->armour_class : 0 ;
    my $boots  = (ref($this->armour_boots  ) && $this->armour_boots ->isa('Garment')) ? $this->armour_boots ->armour_class : 0 ;
    my $shield = (ref($this->armour_shield ) && $this->armour_shield->isa('Garment')) ? $this->armour_shield->armour_class : 0 ;
    return 1 + $body + $shield + $cloak + $boots + $gloves + $helmet;
}

# ---------------------------------------------------------------------
sub weapon_class {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $right  = (ref($this->armour_righthand) && $this->armour_righthand->isa('Weapon')) ? $this->armour_righthand->weapon_class : 0;
    my $left   = (ref($this->armour_lefthand ) && $this->armour_lefthand ->isa('Weapon')) ? $this->armour_lefthand ->weapon_class : 0;
    return $right + $left;
}

# ---------------------------------------------------------------------
sub death { 
    my $this     = shift;
    my $class    = ref($this) || $this;
    my $attacker = shift || 0 ;

    # stop this combat
    if ( ref($this->combat) ) {
        eval { $this->combat->remove_friend($this) } ;
        eval { $this->combat->remove_foe($this) } ;
        if ( ref( $attacker ) && $attacker->isa('Living') ) {
            eval { $attacker->combat->remove_friend($this) } ;
            eval { $attacker->combat->remove_foe($this) } ;
        }
    }
    $this->combat( 0 );
    $this->attacking( 0 );

    # set-up corpse.
    my $corpse = clone_object( 'std/obj/corpse', $this );
    if (ref($corpse)) {
        $corpse->trans_object_in( $this->environment ); 
        $corpse->inventory( $this->inventory() );
        $this->inventory( [] );
        $this->corpse( $corpse );
    }

    # death.
    daemon('combat','living_dies', $this, $attacker );

    return $this ;
}

# ---------------------------------------------------------------------
# adds or subtract hit-points (wounds).
# returns the final hit-points.
sub query_hp_stat{ 
    my $this     = shift;
    my $class    = ref($this) || $this;
    my $wounds     = $this->wounds;
    my $hit_points = $this->hit_points;
    my $msg = "Non si capisce come stia.";
    
    ###if ( $hit_points > 0 ) { $msg = daemon('combat','query_hp_stat', $this ) }
       
    return $msg;
}

# ---------------------------------------------------------------------
# adds or subtract hit-points (wounds).
# returns the final hit-points.
sub add_hp{ 
    my $this     = shift;
    my $class    = ref($this) || $this;
    my $points   = shift || 0;
    my $attacker = shift ;
    my $wounds     = $this->wounds;
    my $hit_points = $this->hit_points;
    $wounds += $points ;
    $wounds = 0 if $wounds < 0;
    $wounds = $hit_points if $wounds > $hit_points;
    $this->wounds( $wounds );
    $attacker = current_user() unless ( ref($attacker) && $attacker->isa('Living') ) ;

    # the target is dying.        
    #$this->death( $attacker ) if $wounds < 1;

    return $wounds;
}

# ---------------------------------------------------------------------
sub add_sp{ (@_)>1 ? ($_[0]->{SpellPoints} += $_[1],$_[0]) : $_[0] }

# ---------------------------------------------------------------------
# every hit is received by this function
sub catch_hit {
    my $this     = shift;
    my $class    = ref($this) || $this;
    my $damage   = shift || 1 ;
    my $attacker = shift || 0 ;
    my $message  = shift || '' ;
    my $wounds   = $this->add_hp( - $damage, $attacker );
    
    ##if ( $wounds < 1 ) {
    ##    $this->attacking( 0 );
    ##    if ( ref($attacker) && $attacker->isa('Living') ) {
    ##        ###remove_from_array( $attacker->attack_target, $this ) ;
    ##        ###remove_from_array( $this->attack_target, $attacker ) ;
    ##    }
    ##    #$this->death( $attacker );
    ##    return 0;
    ##}
    
    ##if ( $damage > 0 && ref($attacker) && $attacker != $this 
    ##                 ###&& -1 == pos_array( $this->attack_target, $attacker ) 
    ##   ) {
    ##    ###$this->attack_flipflop( 0 );
    ##    ###$this->attacking( 1 );
    ##    ###$this->attack_target_distance->{$pl} = 0 ;
    ##    ###push @{$this->attack_target}, $attacker;
    ##}
    return $this;
}

# ---------------------------------------------------------------------
sub catch_flee {
    my $this     = shift;
    my $class    = ref($this) || $this;
    my $ob       = shift;
    #unless ( find_object( $ob->keyname, $this->environment ) ) {
    #    tell_object( $ob, $this->short, " smette di attaccare.\n" );
    #    delete $this->attack_target->{ $ob->keyname } if exists $this->attack_target->{ $ob->keyname };
    #}
    return $this;
}

# ---------------------------------------------------------------------
sub catch_hit_2 {
    my $this     = shift;
    my $class    = ref($this) || $this;
    my $attacker = shift;
    ###print "called catch_hit_2( ", $attacker->keyname, "\n";
    ###$this->attack_target->{ $attacker->keyname } = $attacker;
    return $this;
}

# ---------------------------------------------------------------------
sub examine_object {
    my $this     = shift;
    my $class    = ref($this) || $this;
    my ($me,$ro,$ta) = $this->SUPER::examine_object( @_ );
    my $obj_desc = "Osservi " . $this->short . "\n" ;

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

    my $helmet = ($this->armour_helmet    && $this->armour_helmet   ->desc ) || '';
    my $gloves = ($this->armour_gloves    && $this->armour_gloves   ->desc ) || '';
    my $cloak  = ($this->armour_cloak     && $this->armour_cloak    ->desc ) || '';
    my $body   = ($this->armour_body      && $this->armour_body     ->desc ) || '';
    my $boots  = ($this->armour_boots     && $this->armour_boots    ->desc ) || '';
    
    my $shield = ($this->armour_shield    && $this->armour_shield   ->desc ) || '';
    my $right  = ($this->armour_righthand && $this->armour_righthand->desc ) || '';
    my $left   = ($this->armour_lefthand  && $this->armour_lefthand ->desc ) || '';

  ##my $distance        = $this->attack_distance || 0 ;
    
    $obj_desc .= "Classe d'armatura " . $this->armour_class . "\n" ;
    $obj_desc .= "Elmetto           $helmet      \n"  if $helmet;
    $obj_desc .= "Guanti            $gloves      \n"  if $gloves;
    $obj_desc .= "Mantello          $cloak       \n"  if $cloak;
    $obj_desc .= "Corazza           $body        \n"  if $body;
    $obj_desc .= "Stivali           $boots       \n"  if $boots;
   #$obj_desc .= "Arma                           \n"  if ;
   #$obj_desc .= "Scudo                          \n"  if ;
    $obj_desc .= "Abilita` armi     $weapon      \n"  if $weapon;
    $obj_desc .= "Abilita` lancio   $ballistic   \n"  if $ballistic;
    $obj_desc .= "Agilita`          $agility     \n"  if $agility;
    $obj_desc .= "Forza             $strength    \n"  if $strength;
    $obj_desc .= "Numero lanci      $damage_dice \n"  if $damage_dice;
    $obj_desc .= "Resistenza        $resistance  \n"  if $resistance;
    $obj_desc .= "Punti ferita      $hit_points  \n"  if $hit_points;
    $obj_desc .= "Punti magia       $spell_points\n"  if $spell_points;

    return ($obj_desc, $ro, $ta);
}

# ---------------------------------------------------------------------
# sets and retrieve ColorCccc as member
sub color {
    my $this   = shift;
    my $class  = ref($this) || $this;
    my $color  = shift || '';
    return '' unless $color =~ /^Color/;
    return (@_)>0 ? $this->{$color} = $_[0] : $this->{$color} ;
}

# ---------------------------------------------------------------------
# sets and retrieve ChannelNnnn as member
sub channel_switch {
    my $this   = shift;
    my $class  = ref($this) || $this;
    my $chan   = shift || '';
    return '' unless $chan =~ /^Channel/;
    return (@_)>0 ? $this->{$chan} = $_[0] : $this->{$chan} ;
}

# ---------------------------------------------------------------------
# accepts a race-name to be found among RaceListM, RaceListF, RaceList.
# returns the corresponding race-name in RaceList.
sub translate_race {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $race  = shift;
    my $arm = pos_array( getsetup('RaceListM'), $race );
    my $arf = pos_array( getsetup('RaceListF'), $race );
    my $arx = pos_array( getsetup('RaceList'), $race );
    my @races = @{getsetup('RaceList')};
    return $races[$arm] if $arm >= 0;
    return $races[$arf] if $arf >= 0;
    return $races[$arx] if $arx >= 0;
    return $race;
}

# ---------------------------------------------------------------------
sub set_stats {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $level = shift || 1;
    my $race  = 'Umani';
    my $msg = '';
 
    $level = 0 if $level < 0;
    $level = getsetup('LevelMax') if $level > getsetup('LevelMax');
    
    $race = $this->translate_race( $this->race ) ;
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ select * from engine_standard_level where race=? and level=? ]) ;
    $sth->execute( $race, $level );
    my $data = $sth->fetchrow_hashref();
    
    if ( defined $data ) {
        $this->value            ( $data->{ gold            } );
      # $this->title            ( $data->{ title           } );
        $this->movement         ( $data->{ move            } );
        $this->weapon_skill     ( $data->{ weapon_skill    } );
        $this->ballistic_skill  ( $data->{ ballistic_skill } );
        $this->strength         ( $data->{ strength        } );
        $this->damage_dice      ( $data->{ damage_dice     } );
        $this->resistance       ( $data->{ toughness       } );
        $this->hit_points       ( $data->{ wounds          } );
        $this->initiative       ( $data->{ initiative      } );
      # $this->attacks          ( $data->{ attacks         } );
      # $this->luck             ( $data->{ luck            } );
      # $this->willpower        ( $data->{ willpower       } );
      # $this->skills           ( $data->{ skills          } );
      # $this->escape_pinning   ( $data->{ escape_pinning  } );
        $this->bulk             ( $data->{ bulk            } );
        $this->weight           ( $data->{ weight          } );
        $this->capacity         ( $data->{ capacity        } );
        $this->payload          ( $data->{ payload         } );
        $this->wounds           ( $this->hit_points )    if $this->wounds > $this->hit_points ;
        $this->power            ( $this->spell_points )  if $this->power  > $this->spell_points ;
    }
        
    $sth->finish();
    
    return $this;
}
1;

