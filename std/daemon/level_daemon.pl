# level_daemon.pl
# Created Nov 2007
# Author  flogisto

# ---------------------------------------------------------------------
use Daemon;

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( 'level_daemon' );
    bless $self, $class ;
    
    $this->preload();
    
    return $self;
}

# ---------------------------------------------------------------------
sub preload {
    my $dbh = dbi();
    my $sth = $dbh->table_info( '', '', 'engine_standard_level' );
    if ( $dbh->err || ! $sth->fetch() ) {
        $dbh->do( qq[ 
            create table engine_standard_level (
            race             char(64) not null,
            level            integer not null,
            gold             integer,
            title            char(64),
            move             integer,
            weapon_skill     integer,
            ballistic_skill  integer,
            strength         integer,
            damage_dice      integer,
            toughness        integer,
            wounds           integer,
            initiative       integer,
            attacks          integer,
            luck             integer,
            willpower        integer,
            skills           integer,
            escape_pinning   integer,
            bulk             integer,
            weight           integer,
            capacity         integer,
            payload          integer,
            primary key (race,level) )
                    ] );

        my $data = [];
        my @race = ();

    # Umani # BARBARIAN
        $race[ 0 ] = 'Umani';
        $data->[ 0 ] = [
    #          0    1   2   3   4   5   6   7    8   9  10  11  12  13  14   15   16   17   18
    #       Gold        M  WS  BS+ Str Dam  T    W   I   A   L  WP  Sk  Pin+ Bul Wei  Cap  Payl
         [     0,  '',  4,  3,  5,  4,  1,  3,  20,  3,  1,  0,  3,  0,  6, 100, 100, 100, 100, ],
         [  2000,  '',  4,  3,  5,  4,  1,  4,  30,  3,  1,  1,  3,  1,  6, 100, 100, 120, 120, ],
         [  4000,  '',  4,  4,  4,  4,  1,  4,  40,  3,  2,  1,  3,  2,  6, 100, 100, 140, 140, ],
         [  8000,  '',  4,  4,  4,  4,  1,  4,  53,  4,  2,  2,  3,  3,  6, 100, 100, 160, 160, ],
         [ 12000,  '',  4,  5,  4,  4,  2,  4,  71,  4,  3,  2,  4,  4,  5, 100, 100, 180, 180, ],
         [ 18000,  '',  4,  5,  3,  4,  2,  4,  95,  5,  3,  2,  4,  4,  5, 100, 100, 200, 200, ],
         [ 24000,  '',  4,  5,  3,  4,  2,  4, 127,  5,  3,  3,  4,  5,  5, 100, 100, 220, 220, ],
         [ 32000,  '',  4,  6,  3,  4,  2,  4, 169,  5,  4,  3,  4,  6,  5, 100, 100, 240, 240, ],
         [ 45000,  '',  4,  6,  2,  4,  3,  4, 225,  6,  4,  3,  4,  6,  5, 100, 100, 260, 260, ],
         [ 50000,  '',  4,  6,  2,  4,  3,  4, 300,  6,  4,  3,  4,  7,  5, 100, 100, 280, 280, ],
        ];

    # Mezzelfi # ELF first Skill is "dodge".
        $race[ 1 ] = 'Mezzelfi';
        $data->[ 1 ] = [
    #          0    1   2   3   4   5   6   7    8   9  10  11  12  13  14   15   16   17   18  
    #       Gold        M  WS  BS+ Str Dam  T    W   I   A   L  WP  Sk  Pin+ Bul Wei  Cap  Payl 
         [     0,  '',  4,  4,  4,  3,  1,  3,  20,  6,  1,  0,  2,  1,  0, 100, 100, 100, 100, ],
         [  2000,  '',  4,  5,  4,  3,  1,  3,  30,  6,  2,  1,  2,  1,  0, 100, 100, 120, 120, ],
         [  4000,  '',  4,  5,  4,  4,  1,  3,  40,  7,  2,  2,  3,  1,  0, 100, 100, 140, 140, ],
         [  8000,  '',  4,  5,  3,  4,  1,  4,  53,  7,  2,  2,  3,  2,  0, 100, 100, 160, 160, ],
         [ 12000,  '',  4,  5,  3,  4,  2,  4,  71,  8,  3,  2,  3,  2,  0, 100, 100, 180, 180, ],
         [ 18000,  '',  4,  6,  3,  4,  2,  4,  95,  8,  3,  3,  3,  3,  0, 100, 100, 200, 200, ],
         [ 24000,  '',  4,  6,  2,  4,  2,  4, 127,  9,  3,  3,  3,  3,  0, 100, 100, 220, 220, ],
         [ 32000,  '',  4,  6,  2,  4,  2,  4, 169,  9,  4,  3,  3,  4,  0, 100, 100, 240, 240, ],
         [ 45000,  '',  4,  7,  2,  4,  3,  4, 225,  9,  4,  3,  4,  5,  0, 100, 100, 260, 260, ],
         [ 50000,  '',  4,  7,  1,  4,  3,  4, 300,  9,  4,  4,  4,  6,  0, 100, 100, 280, 280, ]
        ];

    # Gnomo # DWARF extra +1 Dam when using Great Axe.
        $race[ 2 ] = 'Gnomi';
        $data->[ 2 ] = [
    #          0    1   2   3   4   5   6   7    8   9  10  11  12  13  14   15   16   17   18  
    #       Gold        M  WS  BS+ Str Dam  T    W   I   A   L  WP  Sk  Pin+ Bul Wei  Cap  Payl 
         [     0,  '',  4,  4,  5,  3,  1,  4,  20,  2,  1,  0,  4,  0,  5, 100, 100,  80,  80, ],
         [  2000,  '',  4,  5,  5,  3,  1,  4,  30,  2,  2,  0,  4,  1,  5, 100, 100, 100, 100, ],
         [  4000,  '',  4,  5,  5,  3,  1,  5,  40,  3,  2,  1,  5,  2,  5, 100, 100, 120, 120, ],
         [  8000,  '',  4,  5,  4,  4,  1,  5,  53,  3,  2,  1,  5,  2,  5, 100, 100, 140, 140, ],
         [ 12000,  '',  4,  6,  4,  4,  2,  5,  71,  3,  3,  1,  5,  3,  4, 100, 100, 160, 160, ],
         [ 18000,  '',  4,  7,  4,  4,  2,  5,  95,  3,  3,  2,  5,  3,  4, 100, 100, 180, 180, ],
         [ 24000,  '',  4,  7,  3,  4,  2,  5, 127,  3,  3,  2,  5,  4,  4, 100, 100, 200, 200, ],
         [ 32000,  '',  4,  7,  3,  4,  2,  5, 169,  4,  4,  2,  5,  4,  4, 100, 100, 220, 220, ],
         [ 45000,  '',  4,  7,  2,  4,  3,  5, 225,  4,  4,  3,  6,  5,  4, 100, 100, 240, 240, ],
         [ 50000,  '',  4,  7,  2,  4,  3,  5, 300,  5,  4,  3,  6,  6,  4, 100, 100, 260, 260, ],
        ];
   
    # folletto # WIZARD Skill means nD6 power. * using the same of Priest.
        $race[ 3 ] = 'Folletti';
        $data->[ 3 ] = [
    #          0    1   2   3   4   5   6   7    8   9  10  11  12  13  14   15   16   17   18  
    #       Gold        M  WS  BS+ Str Dam  T    W   I   A   L  WP  Sk  Pin+ Bul Wei  Cap  Payl 
         [     0,  '',  4,  2,  6,  3,  1,  3,  20,  3,  1,  0,  3,  3,  4,  40,  40,  40,  40, ],
         [  2000,  '',  4,  2,  6,  3,  1,  3,  30,  4,  1,  0,  4,  4,  4,  40,  40,  60,  60, ],
         [  4000,  '',  4,  3,  6,  3,  1,  3,  40,  4,  2,  1,  4,  5,  4,  40,  40,  80,  80, ],
         [  8000,  '',  4,  3,  5,  3,  1,  3,  53,  4,  2,  1,  4,  5,  4,  40,  40, 100, 100, ],
         [ 12000,  '',  4,  3,  5,  3,  2,  4,  71,  4,  2,  2,  4,  5,  3,  40,  40, 120, 120, ],
         [ 18000,  '',  4,  4,  5,  4,  2,  4,  95,  4,  2,  2,  5,  6,  3,  40,  40, 140, 140, ],
         [ 24000,  '',  4,  4,  5,  4,  2,  4, 127,  4,  3,  2,  5,  7,  3,  40,  40, 160, 160, ],
         [ 32000,  '',  4,  4,  5,  4,  2,  4, 169,  5,  3,  3,  5,  7,  3,  40,  40, 180, 180, ],
         [ 45000,  '',  4,  4,  4,  4,  3,  4, 225,  5,  3,  3,  5,  8,  3,  40,  40, 200, 200, ],
         [ 50000,  '',  4,  4,  4,  4,  3,  4, 300,  6,  3,  3,  5,  9,  3,  40,  40, 220, 220, ],
        ];
   
    # ninfa # PRIEST Skill is blessing.
        $race[ 4 ] = 'Ninfe';
        $data->[ 4 ] = [
    #          0    1   2   3   4   5   6   7    8   9  10  11  12  13  14   15   16   17   18  
    #       Gold        M  WS  BS+ Str Dam  T    W   I   A   L  WP  Sk  Pin+ Bul Wei  Cap  Payl 
         [     0,  '',  4,  2,  5,  3,  1,  2,  20,  2,  1,  0,  3,  3,  4, 100, 100, 100, 100, ],
         [  2000,  '',  4,  3,  5,  3,  1,  2,  30,  3,  1,  1,  3,  4,  4, 100, 100, 120, 120, ],
         [  4000,  '',  4,  3,  5,  3,  1,  3,  40,  3,  2,  1,  3,  5,  4, 100, 100, 140, 140, ],
         [  8000,  '',  4,  4,  5,  3,  1,  3,  53,  3,  2,  2,  4,  5,  4, 100, 100, 160, 160, ],
         [ 12000,  '',  4,  4,  5,  3,  2,  3,  71,  4,  2,  2,  4,  5,  3, 100, 100, 180, 180, ],
         [ 18000,  '',  4,  4,  5,  4,  2,  3,  95,  4,  3,  3,  4,  6,  3, 100, 100, 200, 200, ],
         [ 24000,  '',  4,  4,  5,  4,  2,  4, 127,  4,  3,  3,  5,  7,  3, 100, 100, 220, 220, ],
         [ 32000,  '',  4,  5,  5,  4,  2,  4, 169,  5,  3,  3,  5,  7,  3, 100, 100, 240, 240, ],
         [ 45000,  '',  4,  5,  5,  4,  3,  4, 225,  5,  3,  3,  6,  8,  3, 100, 100, 260, 260, ],
         [ 50000,  '',  4,  5,  4,  4,  3,  4, 300,  5,  3,  3,  6,  9,  3, 100, 100, 280, 280, ],
        ];
   
    # drago # IMPERIAL NOBLE
        $race[ 5 ] = 'Draghi';
        $data->[ 5 ] = [
    #          0    1   2   3   4   5   6   7    8   9  10  11  12  13  14   15   16   17   18  
    #       Gold        M  WS  BS+ Str Dam  T    W   I   A   L  WP  Sk  Pin+ Bul Wei  Cap  Payl 
         [     0,  '',  4,  4,  4,  3,  1,  3,  20,  5,  1,  0,  3,  0,  5, 100, 100, 100, 100, ],
         [  2000,  '',  4,  4,  4,  3,  1,  3,  30,  5,  2,  1,  3,  1,  5, 100, 100, 120, 120, ],
         [  4000,  '',  4,  5,  4,  3,  1,  3,  40,  5,  2,  1,  3,  2,  4, 100, 100, 140, 140, ],
         [  8000,  '',  4,  5,  4,  3,  1,  3,  53,  5,  2,  2,  4,  2,  4, 100, 100, 160, 160, ],
         [ 12000,  '',  4,  5,  4,  4,  2,  4,  71,  5,  3,  2,  4,  2,  4, 100, 100, 180, 180, ],
         [ 18000,  '',  4,  6,  4,  4,  2,  4,  95,  5,  3,  2,  4,  3,  4, 100, 100, 200, 200, ],
         [ 24000,  '',  4,  6,  4,  4,  2,  4, 127,  5,  3,  3,  4,  4,  4, 100, 100, 220, 220, ],
         [ 32000,  '',  4,  6,  4,  4,  2,  4, 169,  5,  4,  3,  4,  5,  3, 100, 100, 240, 240, ],
         [ 45000,  '',  4,  6,  4,  4,  3,  4, 225,  6,  4,  3,  4,  5,  3, 100, 100, 260, 260, ],
         [ 50000,  '',  4,  7,  4,  4,  3,  4, 300,  7,  5,  4,  4,  6,  3, 100, 100, 280, 280, ],
        ];
   
    # sirenide # PRIEST Skill is blessing.
        $race[ 6 ] = 'Sirenidi';
        $data->[ 6 ] = [
    #          0    1   2   3   4   5   6   7    8   9  10  11  12  13  14   15   16   17   18  
    #       Gold        M  WS  BS+ Str Dam  T    W   I   A   L  WP  Sk  Pin+ Bul Wei  Cap  Payl 
         [     0,  '',  4,  2,  5,  3,  1,  2,  20,  2,  1,  0,  3,  3,  4, 100, 100, 100, 100, ],
         [  2000,  '',  4,  3,  5,  3,  1,  2,  30,  3,  1,  1,  3,  4,  4, 100, 100, 120, 120, ],
         [  4000,  '',  4,  3,  5,  3,  1,  3,  40,  3,  2,  1,  3,  5,  4, 100, 100, 140, 140, ],
         [  8000,  '',  4,  4,  5,  3,  1,  3,  53,  3,  2,  2,  4,  5,  4, 100, 100, 160, 160, ],
         [ 12000,  '',  4,  4,  5,  3,  2,  3,  71,  4,  2,  2,  4,  5,  3, 100, 100, 180, 180, ],
         [ 18000,  '',  4,  4,  5,  4,  2,  3,  95,  4,  3,  3,  4,  6,  3, 100, 100, 200, 200, ],
         [ 24000,  '',  4,  4,  5,  4,  2,  4, 127,  4,  3,  3,  5,  7,  3, 100, 100, 220, 220, ],
         [ 32000,  '',  4,  5,  5,  4,  2,  4, 169,  5,  3,  3,  5,  7,  3, 100, 100, 240, 240, ],
         [ 45000,  '',  4,  5,  5,  4,  3,  4, 225,  5,  3,  3,  6,  8,  3, 100, 100, 260, 260, ],
         [ 50000,  '',  4,  5,  4,  4,  3,  4, 300,  5,  3,  3,  6,  9,  3, 100, 100, 280, 280, ],
        ];
   
    # fammin # IMPERIAL NOBLE
        $race[ 7 ] = 'Fammin';
        $data->[ 7 ] = [
    #          0    1   2   3   4   5   6   7    8   9  10  11  12  13  14   15   16   17   18
    #       Gold        M  WS  BS+ Str Dam  T    W   I   A   L  WP  Sk  Pin+ Bul Wei  Cap  Payl
         [     0,  '',  4,  4,  4,  3,  1,  3,  20,  5,  1,  0,  3,  0,  5, 100, 100, 100, 100, ],
         [  2000,  '',  4,  4,  4,  3,  1,  3,  30,  5,  2,  1,  3,  1,  5, 100, 100, 120, 120, ],
         [  4000,  '',  4,  5,  4,  3,  1,  3,  40,  5,  2,  1,  3,  2,  4, 100, 100, 140, 140, ],
         [  8000,  '',  4,  5,  4,  3,  1,  3,  53,  5,  2,  2,  4,  2,  4, 100, 100, 160, 160, ],
         [ 12000,  '',  4,  5,  4,  4,  2,  4,  71,  5,  3,  2,  4,  2,  4, 100, 100, 180, 180, ],
         [ 18000,  '',  4,  6,  4,  4,  2,  4,  95,  5,  3,  2,  4,  3,  4, 100, 100, 200, 200, ],
         [ 24000,  '',  4,  6,  4,  4,  2,  4, 127,  5,  3,  3,  4,  4,  4, 100, 100, 220, 220, ],
         [ 32000,  '',  4,  6,  4,  4,  2,  4, 169,  5,  4,  3,  4,  5,  3, 100, 100, 240, 240, ],
         [ 45000,  '',  4,  6,  4,  4,  3,  4, 225,  6,  4,  3,  4,  5,  3, 100, 100, 260, 260, ],
         [ 50000,  '',  4,  7,  4,  4,  3,  4, 300,  7,  5,  4,  4,  6,  3, 100, 100, 280, 280, ],
        ];

    # Nessuno # BARBARIAN
        $race[ 8 ] = 'Nessuno';
        $data->[ 8 ] = [
    #          0    1   2   3   4   5   6   7    8   9  10  11  12  13  14   15   16   17   18
    #       Gold        M  WS  BS+ Str Dam  T    W   I   A   L  WP  Sk  Pin+ Bul Wei  Cap  Payl
         [     0,  '',  4,  3,  5,  4,  1,  3,  20,  3,  1,  0,  3,  0,  6, 100, 100, 100, 100, ],
         [  2000,  '',  4,  3,  5,  4,  1,  4,  30,  3,  1,  1,  3,  1,  6, 100, 100, 120, 120, ],
         [  4000,  '',  4,  4,  4,  4,  1,  4,  40,  3,  2,  1,  3,  2,  6, 100, 100, 140, 140, ],
         [  8000,  '',  4,  4,  4,  4,  1,  4,  53,  4,  2,  2,  3,  3,  6, 100, 100, 160, 160, ],
         [ 12000,  '',  4,  5,  4,  4,  2,  4,  71,  4,  3,  2,  4,  4,  5, 100, 100, 180, 180, ],
         [ 18000,  '',  4,  5,  3,  4,  2,  4,  95,  5,  3,  2,  4,  4,  5, 100, 100, 200, 200, ],
         [ 24000,  '',  4,  5,  3,  4,  2,  4, 127,  5,  3,  3,  4,  5,  5, 100, 100, 220, 220, ],
         [ 32000,  '',  4,  6,  3,  4,  2,  4, 169,  5,  4,  3,  4,  6,  5, 100, 100, 240, 240, ],
         [ 45000,  '',  4,  6,  2,  4,  3,  4, 225,  6,  4,  3,  4,  6,  5, 100, 100, 260, 260, ],
         [ 50000,  '',  4,  6,  2,  4,  3,  4, 300,  6,  4,  3,  4,  7,  5, 100, 100, 280, 280, ],
        ];

        my $dbh = dbi();
        my $sth = $dbh->prepare( 
            qq[ insert into engine_standard_level values ( 
                ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? ) ]);
        foreach my $i ( 0 .. $#{$data} ) { 
            foreach my $j ( 0 .. $#{$data->[$i] } ) {
                $sth->execute (
                    $race[$i],               
                    $j+1,                      
                    $data->[$i]->[$j]->[0]  , # gold           
                    $data->[$i]->[$j]->[1]  , # title          
                    $data->[$i]->[$j]->[2]  , # move           
                    $data->[$i]->[$j]->[3]  , # weapon_skill   
                    $data->[$i]->[$j]->[4]  , # ballistic_skill
                    $data->[$i]->[$j]->[5]  , # strength       
                    $data->[$i]->[$j]->[6]  , # damage_dice    
                    $data->[$i]->[$j]->[7]  , # toughness      
                    $data->[$i]->[$j]->[8]  , # wounds         
                    $data->[$i]->[$j]->[9]  , # initiative     
                    $data->[$i]->[$j]->[10] , # attacks        
                    $data->[$i]->[$j]->[11] , # luck           
                    $data->[$i]->[$j]->[12] , # willpower      
                    $data->[$i]->[$j]->[13] , # skills         
                    $data->[$i]->[$j]->[14] , # escape_pinning 
                    $data->[$i]->[$j]->[15] , # bulk           
                    $data->[$i]->[$j]->[16] , # weight         
                    $data->[$i]->[$j]->[17] , # capacity       
                    $data->[$i]->[$j]->[18] , # payload        
                );                              
            }                                   
        }                                       
        $sth->finish();                         
    }
}

# ---------------------------------------------------------------------
# accepts a race-name to be found among RaceListM, RaceListF, RaceList.
# returns the corresponding race-name in RaceList.
sub translate_race {
    my $this  = shift;
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
# query_xxx()
# Input: string key - the key name in the format "desc#type"
# Output: the price stored in std_price
sub query_f {
    my $me      = shift;
    my $key     = shift;  
    my $field   = shift;
    my ($race,$level) = ($1,$2) if $key =~ /(\w+),(\d+)/;
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ select * from engine_standard_level where race=? and level=? ]) ;
    $sth->execute( $race, $level );
    my $data = $sth->fetchrow_hashref();
    $sth->finish();
    return $data->{$field};
}
    
# ---------------------------------------------------------------------
sub stats {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $level = shift || 0;
    my $pl    = shift || current_user();
    my $race  = 0;
    my $msg = '';

    return '' unless ref($pl) && $pl->isa('Living');
    $level = $pl->level if 0 == $level;
    $level = 1 if $level < 0;
    $maxlevel = getsetup('LevelMax');
    $level =  1 if $level > $maxlevel;
    
    $race = $this->translate_race( $pl->race ) ;
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ select * from engine_standard_level where race=? and level=? ]) ;
    $sth->execute( $race, $level );
    my $data = $sth->fetchrow_hashref();
    
    $msg .= "\nStats:          " . $pl->short();
    $msg .= "\nLevel:          $level ($race)" ;
    $msg .= "\nGold            " .($pl->value||0)     .'/'. $data->{ gold            } ;
  # $msg .= "\nTitle           " .$pl->title          .'/'. $data->{ title           } ;
    $msg .= "\nMove            " .$pl->movement       .'/'. $data->{ move            } ;
    $msg .= "\nWeapon skill    " .$pl->weapon_skill   .'/'. $data->{ weapon_skill    } ;
    $msg .= "\nBallistic skill " .$pl->ballistic_skill.'/'. $data->{ ballistic_skill } ;
    $msg .= "\nStrength        " .$pl->strength       .'/'. $data->{ strength        } ;
    $msg .= "\nDamage dice     " .$pl->damage_dice    .'/'. $data->{ damage_dice     } ;
    $msg .= "\nToughness       " .$pl->resistance     .'/'. $data->{ toughness       } ;
    $msg .= "\nWounds          " .$pl->hit_points     .'/'. $data->{ wounds          } ;
    $msg .= "\nInitiative      " .$pl->initiative     .'/'. $data->{ initiative      } ;
  # $msg .= "\nAttacks         " .$pl->attacks        .'/'. $data->{ attacks         } ;
  # $msg .= "\nLuck            " .$pl->luck           .'/'. $data->{ luck            } ;
  # $msg .= "\nWillpower       " .$pl->willpower      .'/'. $data->{ willpower       } ;
  # $msg .= "\nSkills          " .$pl->skills         .'/'. $data->{ skills          } ;
  # $msg .= "\nEscape_pinning  " .$pl->escape_pinning .'/'. $data->{ escape_pinning  } ;
    $msg .= "\nBulk            " .$pl->bulk           .'/'. $data->{ bulk            } ;
    $msg .= "\nWeight          " .$pl->weight         .'/'. $data->{ weight          } ;
    $msg .= "\nCapacity        " .$pl->capacity       .'/'. $data->{ capacity        } ;
    $msg .= "\nPayload         " .$pl->payload        .'/'. $data->{ payload         } ;
    $msg .= "\n";

    $sth->finish();
    
    return $msg;
}

# ---------------------------------------------------------------------
sub set_stats {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $level = shift || 1;
    my $pl    = shift || current_user();
    my $race  = 'Umani';
    my $msg = '';
 
    return 0 unless ref($pl) && $pl->isa('Living');
    $level = 1 if $level < 1;
    $maxlevel = getsetup('LevelMax') || 10;
    $level = $maxlevel if $level > $maxlevel;
    
    $race = $this->translate_race( $pl->race ) ;
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ select * from engine_standard_level where race=? and level=? ]) ;
    $sth->execute( $race, $level );
    my $data = $sth->fetchrow_hashref();
    
    $pl->value            ( $data->{ gold            } );
  # $pl->title            ( $data->{ title           } );
    $pl->movement         ( $data->{ move            } );
    $pl->weapon_skill     ( $data->{ weapon_skill    } );
    $pl->ballistic_skill  ( $data->{ ballistic_skill } );
    $pl->strength         ( $data->{ strength        } );
    $pl->damage_dice      ( $data->{ damage_dice     } );
    $pl->resistance       ( $data->{ toughness       } );
    $pl->hit_points       ( $data->{ wounds          } );
    $pl->initiative       ( $data->{ initiative      } );
  # $pl->attacks          ( $data->{ attacks         } );
  # $pl->luck             ( $data->{ luck            } );
  # $pl->willpower        ( $data->{ willpower       } );
  # $pl->skills           ( $data->{ skills          } );
  # $pl->escape_pinning   ( $data->{ escape_pinning  } );
    $pl->bulk             ( $data->{ bulk            } );
    $pl->weight           ( $data->{ weight          } );
    $pl->capacity         ( $data->{ capacity        } );
    $pl->payload          ( $data->{ payload         } );

    $pl->wounds           ( $pl->hit_points ) if $pl->wounds > $pl->hit_points ;
    $pl->power            ( $pl->spell_points ) if $pl->power > $pl->spell_points ;
    
    $sth->finish();
    
    return 1;
}


