# random.pl
# Created Nov 2007
# Author  flogisto

use Mobile;

# ---------------------------------------------------------------------
use constant {
    MOVE               =>  0,
    WEAPON_SKILL       =>  1,
    BALLISTIC_SKILL    =>  2, # Threshold number to hit
    STRENGTH           =>  3, # negative means that they do massive attacks: strength is added
    TOUGHNESS          =>  4,
    WOUNDS             =>  5,
    ATTACKS            =>  6,
    NUMBER             =>  7, # negative means number of Dices.
    GOLD               =>  8,
    DISTANCE_STRENGTH  =>  9, # strength of distance weapon
    NOTES              => 10,
};


my $monster = {
    #                          M  WS   BS Str  Dam  T   W   A  No. Gold  
    'Orc Warrior'         => [ 4,  3,  4,  3,  1,   4,  3,  1, -1,   55,  0, ''] ;
    'Orc Archer'          => [ 4,  3,  4,  3,  1,   4,  3,  1, -1,   55,  3, 'Armed with Bow (Str 3)'] ;
    'Goblin Warrior'      => [ 4,  2,  5,  3,  1,   3,  2,  1, -1,   20,  5, 'Armed with Spear'] ;
    'Night Goblin Archer' => [ 4,  2,  5,  3,  1,   3,  2,  1, -1,   20,  1, 'Armed with Bow (Str 1)'] ;
    'Snotlings'           => [ 4,  1,  0, -1,  1,   1,  1,  1, -1,   10,  0, ''] ;
    'Skaven Warrior'      => [ 5,  3,  0,  3,  1,   3,  3,  1, -1,   40,  0, ''] ;
    'Minotaur'            => [ 6,  4,  4,  4,  1,   4, 15,  2,  1,  440,  0, 'Causes 2D6+4 Wounds'] ;
    'Giant Spider'        => [ 6,  2,  4,  0,  1,   2,  1,  1, -1,   15,  0, ''] ;
    'Giant Rat'           => [ 6,  2,  0,  2,  1,   2,  1,  1, -1,   20,  0, ''] ;
    'Giant Bat'           => [ 8,  2,  0,  2,  1,   2,  1,  1, -1,   15,  0, ''] ;
}
;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    

    $self->name('fantoccio');
    $self->short('fantoccio');
    $self->shorts('fantocci');
    $self->desc( "Un fantoccio da combattimento."
               );
    $self->hit_points(10);
    
    return $self;
}
