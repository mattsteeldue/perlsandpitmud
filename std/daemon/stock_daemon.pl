# stock_daemon.pl
# Created Jul 2007
# Author  flogisto

# see bottom of this file, for =pod

use Daemon;
##use Archive;

# ---------------------------------------------------------------------
use constant {

   FACTOR_RANGE_MIN    => 0.5 ,
   FACTOR_RANGE_MAX    => 2.0 ,

# The sum of the following two weight must be 1. (1/12 + 11/12 = 1)
   WEIGHT_SUPPLY       => 01.0/12.0 ,
   WEIGHT_MSUPPLY      => 11.0/12.0 ,

# The sum of the following two weight must be 1. (1/12 + 11/12 = 1)
   WEIGHT_DEMAND       => 01.0/12.0 ,
   WEIGHT_MDEMAND      => 11.0/12.0 ,

# Weight used to decide if the current supply/demand is too low
   DEMAND_THRESHOLD    => 0.1 ,
   SUPPLY_THRESHOLD    => 0.1 ,

# Starting epsilon
   STANDARD_EPSILON    => 1.5 ,

# 
   MOCK_DEMAND         => 12.0 ,
   MOCK_SUPPLY         => 12.0 ,

#
   BIT_NOTRADE         => 1 ,
   BIT_BUMP_MIN        => 2 ,
   BIT_BUMP_MAX        => 4 ,
};

# ---------------------------------------------------------------------
sub new {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $self    = $this->SUPER::new( 'stock_daemon' ) ;
    $self->desc('This daemon handles supply & demand.');
    
    my $dbh = dbi();
    my $sth = $dbh->table_info( '', '', 'engine_stock_exchange' );
    if ( ! $dbh->err && ! $sth->fetch() ) {
        $dbh->do( qq[ 
            create table engine_stock_exchange (
            type         char(32) not null, 
            tag          char(64) not null, 
            demand       integer, 
            supply       integer, 
            pfactor      real,
            range_min    real,
            range_max    real,
            epsilon      real,
            mdemand      real, 
            msupply      real, 
            ddelay       integer, 
            sdelay       integer, 
            no_trade     integer, 
            bump_min     integer, 
            bump_max     integer, 
            std_price    integer, 
            bumps        integer,
            primary key (type,tag)
            )
                    ] );
    }    
    bless $self, $class ;
    return $self;
}   
    
# ---------------------------------------------------------------------

#
# ----- Manually control prices -----
#

# the following functions needs a item-key in the (type,desc) format
# and a float to set a specific element of array.

# set_xxx() 
# Input: class ref
#        string ke y - the key name in the format "desc#type"
#        int    numb - the number to be bound to the specific array
sub set_fv {
    my $me      = shift;
    my $type    = shift; 
    my $tag     = shift;
    my $field   = shift;
    my $value   = shift;
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ update engine_stock_exchange set $field = ? where type=? and tag=? ]) ;
    $sth->execute( $value, $type, $tag );        
}
    
sub set_tag       { $_[0]->set_fv( $_[1], $_[2], qw| tag       | , $_[3] ) }
sub set_type      { $_[0]->set_fv( $_[1], $_[2], qw| type      | , $_[3] ) }
sub set_demand    { $_[0]->set_fv( $_[1], $_[2], qw| demand    | , $_[3] ) }
sub set_supply    { $_[0]->set_fv( $_[1], $_[2], qw| supply    | , $_[3] ) }
sub set_pfactor   { $_[0]->set_fv( $_[1], $_[2], qw| pfactor   | , $_[3] ) }
sub set_range_min { $_[0]->set_fv( $_[1], $_[2], qw| range_min | , $_[3] ) }
sub set_range_max { $_[0]->set_fv( $_[1], $_[2], qw| range_max | , $_[3] ) }
sub set_epsilon   { $_[0]->set_fv( $_[1], $_[2], qw| epsilon   | , $_[3] ) }
sub set_mdemand   { $_[0]->set_fv( $_[1], $_[2], qw| mdemand   | , $_[3] ) }
sub set_msupply   { $_[0]->set_fv( $_[1], $_[2], qw| msupply   | , $_[3] ) }
sub set_ddelay    { $_[0]->set_fv( $_[1], $_[2], qw| ddelay    | , $_[3] ) }
sub set_sdelay    { $_[0]->set_fv( $_[1], $_[2], qw| sdelay    | , $_[3] ) }
sub set_no_trade  { $_[0]->set_fv( $_[1], $_[2], qw| no_trade  | , $_[3] ) }
sub set_bump_min  { $_[0]->set_fv( $_[1], $_[2], qw| bump_min  | , $_[3] ) }
sub set_bump_max  { $_[0]->set_fv( $_[1], $_[2], qw| bump_max  | , $_[3] ) }
sub set_std_price { $_[0]->set_fv( $_[1], $_[2], qw| std_price | , $_[3] ) }
sub set_bumps     { $_[0]->set_fv( $_[1], $_[2], qw| bumps     | , $_[3] ) }

# ---------------------------------------------------------------------
# query_xxx()
# Input: string key - the key name in the (type,desc) format
# Output: the price stored in std_price
sub query_f {
    my $me      = shift;
    my $type    = shift; 
    my $tag     = shift;
    my $field   = shift;
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ select $field from engine_stock_exchange where type=? and tag=? ]) ;
    $sth->execute( $type, $tag );        
    my $data = $dbh->fetch();
    return $data->[0] if $data;
    return undef;
}
    
sub query_tag       { $_[0]->query_f( $_[1], $_[2], qw| tag       | ) }
sub query_type      { $_[0]->query_f( $_[1], $_[2], qw| type      | ) }
sub query_demand    { $_[0]->query_f( $_[1], $_[2], qw| demand    | ) }
sub query_supply    { $_[0]->query_f( $_[1], $_[2], qw| supply    | ) }
sub query_pfactor   { $_[0]->query_f( $_[1], $_[2], qw| pfactor   | ) }
sub query_range_min { $_[0]->query_f( $_[1], $_[2], qw| range_min | ) }
sub query_range_max { $_[0]->query_f( $_[1], $_[2], qw| range_max | ) }
sub query_epsilon   { $_[0]->query_f( $_[1], $_[2], qw| epsilon   | ) }
sub query_mdemand   { $_[0]->query_f( $_[1], $_[2], qw| mdemand   | ) }
sub query_msupply   { $_[0]->query_f( $_[1], $_[2], qw| msupply   | ) }
sub query_ddelay    { $_[0]->query_f( $_[1], $_[2], qw| ddelay    | ) }
sub query_sdelay    { $_[0]->query_f( $_[1], $_[2], qw| sdelay    | ) }
sub query_no_trade  { $_[0]->query_f( $_[1], $_[2], qw| no_trade  | ) }
sub query_bump_min  { $_[0]->query_f( $_[1], $_[2], qw| bump_min  | ) }
sub query_bump_max  { $_[0]->query_f( $_[1], $_[2], qw| bump_max  | ) }
sub query_std_price { $_[0]->query_f( $_[1], $_[2], qw| std_price | ) }
sub query_bumps     { $_[0]->query_f( $_[1], $_[2], qw| bumps     | ) }

#
# ----- Query Pricing by object-reference -----
#

# ---------------------------------------------------------------------
# query_trading()
# Input: object ob - the object reference
# Output: can trade? 1->OK, 0->cannot trade.
sub query_trading {
    my $me      = shift;
    my $ob      = shift;
    my $type    = ( ref($ob) ? 0 : "$ob" );
    my $tag     = ( ref($ob) ? $ob->short : shift );
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ select * from engine_stock_exchange where type=? and tag=? ]) ;
    $sth->execute( $type, $tag );        
    my $row = $sth->fetchrow_hashref();
    unless ( $row ) {
        $me->add_item( $ob, 1.0 ) if ref($ob);
        $me->add_item( $type, $tag, 1.0 ) unless ref($ob);
        $sth->execute( $type, $tag );        
        $row = $sth->fetchrow_hashref();
        return 0 unless $row;
    }
    return 1 if 0 == ($row->{ no_trade } ) ;
    return 0 if $row->{ pfactor } < $row->{ range_min } ;
    return 0 if $row->{ pfactor } > $row->{ range_max } ;
    return 1;
}            

# ---------------------------------------------------------------------
# query_price()
# return the current buy/sell price (in copper) of an object
# this calls the obvious function using ob->value() as "value"
# Input: string key - the key name in the format "desc#type" or object reference
# Output: the price of that object.
sub query_price {
    my $me      = shift;
    my $ob      = shift;
    my $type    = ( ref($ob) ? 0 : "$ob" );
    my $tag     = ( ref($ob) ? $ob->short : shift );
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ select * from engine_stock_exchange where type=? and tag=? ]) ;
    $sth->execute( $type, $tag );        
    my $row = $sth->fetchrow_hashref();
    unless ( $row ) {
        $me->add_item( $ob, 1.0 ) if ref($ob);
        $me->add_item( $type, $tag, 1.0 ) unless ref($ob);
        $sth->execute( $type, $tag );        
        $row = $sth->fetchrow_hashref();
        return 0 unless $row;
    }
    my $price   = ( ref($ob) ? $ob->value : $row->{ std_price } );
    $price = 1 unless $price;
    #$me->price_control( $type, $tag ); 
    $price *= $row->{ pfactor };
    $price = int($price);
    $price = 1 if $price < 1;
    return $price;
}  


#
# ----- Array Item setting -----
#

# ---------------------------------------------------------------------
# add_item()
# adds a new item to the list giving it a price and and epsilon
# other data are defaulted.
# Input: string key - the key name in the format "desc#type"
#        float  pfact - initial pfactor
sub add_item {
    my $me      = shift;
    my $ob      = shift;
    my $type    = ( ref($ob) ? 0 : "$ob" );
    my $tag     = ( ref($ob) ? $ob->short : shift ) ;
    my $pfact   = shift || 1.0;
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ select * from engine_stock_exchange where type=? and tag=? ]) ;
    $sth->execute( $type, $tag );        
    my $row = $sth->fetchrow_hashref();
    if ( $row ) { return -1 ; }
    $sth = $dbh->prepare(
        qq[ insert into engine_stock_exchange values ( 
            ?, ?, ?, ?, ?, 
            ?, ?, ?, ?, ?, 
            ?, ?, ?, ?, ?, 
            ?, ? )
          ] ); 
    $dbh = $sth->execute (        
          $type            # type      
        , $tag             # tag       
        , 0                # demand    
        , 0                # supply    
        , $pfact           # pfactor   
        , FACTOR_RANGE_MIN # range_min 
        , FACTOR_RANGE_MAX # range_max 
        , STANDARD_EPSILON # epsilon   
        , MOCK_DEMAND      # mdemand   
        , MOCK_SUPPLY      # msupply   
        , 0                # ddelay    
        , 0                # sdelay    
        , 0                # no_trade
        , 0                # bump_min  
        , 0                # bump_max  
        , 0                # std_price 
        , 0                # bumps     
        ) ;
    return 1;
}

# ---------------------------------------------------------------------
# remove_item()
# Input: string key - the key name in the format "desc#type"
# Output 1 success - 0 failure
sub remove_item {
    my $me      = shift;
    my $ob      = shift;
    my $type    = ( ref($ob) ? 0 : "$ob" );
    my $tag     = ( ref($ob) ? $ob->short : shift ) ;
    my $dbh = dbi();
    my $sth = $dbh->prepare(
        qq[ delete from engine_stock_exchange where type=? and tag=? ]) ;
    $sth->execute( $type, $tag );
}

# ---------------------------------------------------------------------
# price_control()
# keeps the price between some bottom-level and top-level.
# Input: int i - item index (already found elsewhere)
sub price_control {
    my $me      = shift;
    my $ob      = shift;
    my $type    = ( ref($ob) ? 0 : "$ob" );
    my $tag     = ( ref($ob) ? $ob->short : shift ) ;
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ select * from engine_stock_exchange where type=? and tag=? ]) ;
    $sth->execute( $type, $tag );        
    my $row = $sth->fetchrow_hashref();
    unless ( $row ) { return 0; }
    my $pfactor = $row->{ pfactor };
    my $bump_min= $row->{ bump_min};
    my $bump_max= $row->{ bump_max};
    if ( $pfactor > $row->{ range_max } ) {
        $pfactor = $row->{ range_max };
        $bump_max = 1;
    }
    elsif ( $pfactor < $row->{ range_min } ) { 
        $pfactor = $row->{ range_min };
        $bump_min = 1;
    }
    if ( $pfactor > $row->{ range_max } or $pfactor < $row->{ range_min } ) {
        $sth = $dbh->prepare( 
            qq[ update engine_stock_exchange 
                set pfactor=?, bump_max=?, bump_min=?
                where type=? and tag=? ]) ; 
        $sth->execute( $pfactor, $bump_max, $bump_min, $type, $tag );
    }
}  


#
# ----- Stock-Exchange data definitions -----
#

# ---------------------------------------------------------------------
# stock_sell()
# records the fact that one item has been sold (player's sale)
# this decrease the pfactor by a fractional number, so that
# the next time you ask the price via query_price it could be slightly lower
# Input: object ob - the object reference
#        float  frac - the number of items (can be fractional)
sub stock_sell {
    my $me      = shift;
    my $ob      = shift;
    my $type    = ( ref($ob) ? 0 : "$ob" );
    my $tag     = ( ref($ob) ? $ob->short : shift ) ;
    my $frac    = shift || 1;
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ select * from engine_stock_exchange where type=? and tag=? ]) ;
    $sth->execute( $type, $tag );        
    my $row = $sth->fetchrow_hashref();
    unless ( $row ) {
        $me->add_item( $ob, 1.0 ) if ref($ob);
        $me->add_item( $type, $tag, 1.0 ) unless ref($ob);
        $sth->execute( $type, $tag );        
        $row = $sth->fetchrow_hashref();
        return 0 unless $row;
    }
    $row->{ supply    } += $frac ;
    $row->{ sdelay    } = 0 ;
    $row->{ std_price } = $ob->value() if ref($ob) ;
    my $den = $row->{ msupply } * $row->{ epsilon } ;
    if ($row->{ msupply } >= 1.0 ) {
        $row->{ pfactor } *= 1.0 - (1.0 / $den );
        $sth = $dbh->prepare( 
            qq[ update engine_stock_exchange 
                set supply=?, sdelay=?, std_price=?, pfactor=?
                where type=? and tag=? ]) ;
        $sth->execute( $row->{supply}, $row->{sdelay}, 
                       $row->{std_price}, $row->{pfactor} ,
                       $type, $tag );
        $me->price_control( $ob, 1.0 ) if ref($ob);
        $me->price_control( $type, $tag, 1.0 ) unless ref($ob);
    }
    return 1;
}

# ---------------------------------------------------------------------
# stock_buy()
# records the fact that one item has been bought.
# this increase the pfactor by a fractional number, so that
# the next time you ask the price via query_price it could be slightly higher
# Input: object ob - the object reference
#        float  frac - the number of items (can be fractional)
sub stock_buy {
    my $me      = shift;
    my $ob      = shift;
    my $type    = ( ref($ob) ? 0 : "$ob" );
    my $tag     = ( ref($ob) ? $ob->short : shift ) ;
    my $frac    = shift || 1;
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ select * from engine_stock_exchange where type=? and tag=? ]) ;
    $sth->execute( $type, $tag );        
    my $row = $sth->fetchrow_hashref();
    unless ( $row ) {
        $me->add_item( $ob, 1.0 ) if ref($ob);
        $me->add_item( $type, $tag, 1.0 ) unless ref($ob);
        $sth->execute( $type, $tag );        
        $row = $sth->fetchrow_hashref();
        return 0 unless $row;
    }
    $row->{ demand    } += $frac ;
    $row->{ ddelay    } = 0 ;
    $row->{ std_price } = $ob->value() if ref($ob) ;
    my $den = $row->{ mdemand } * $row->{ epsilon } ;
    if ($row->{ mdemand } >= 1.0 ) {
        $row->{ pfactor } *= 1.0 + (1.0 / $den );
        $sth = $dbh->prepare( 
            qq[ update engine_stock_exchange 
                set demand=?, ddelay=?, std_price=?, pfactor=?
                where type=? and tag=? ]) ;
        $sth->execute( $row->{demand}, $row->{ddelay}, 
                       $row->{std_price}, $row->{pfactor} ,
                       $type, $tag );
        $me->price_control( $ob, 1.0 ) if ref($ob);
        $me->price_control( $type, $tag, 1.0 ) unless ref($ob);
    }
    return 1;
}

# ---------------------------------------------------------------------
# stock_inter_buy()
# records the fact that one item has been virtually bought by a shop
# or pub/inn to produce its typical output.
# this increase the pfactor by a fractional number, so that
# the next time you ask the price via query_price it could be slightly higher
# Input: string key - the key name in the format "desc#type"
#        float  frac - the number of items (can be fractional)
sub stock_inter_buy {
    my $me      = shift;
    my $ob      = shift;
    my $type    = ( ref($ob) ? 0 : "$ob" );
    my $tag     = ( ref($ob) ? $ob->short : shift ) ;
    my $frac    = shift || 1;
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ select * from engine_stock_exchange where type=? and tag=? ]) ;
    $sth->execute( $type, $tag );        
    my $row = $sth->fetchrow_hashref();
    $row->{ demand    } += $frac ;
    $row->{ ddelay    } = 0 ;
    my $den = $row->{ mdemand } * $row->{ epsilon } ;
    if ($row->{ mdemand } >= 1.0 ) {
        $row->{ pfactor } *= 1.0 + (1.0 / $den );
        $sth = $dbh->prepare( 
            qq[ update engine_stock_exchange 
                set demand=?, ddelay=?, pfactor=?
                where type=? and tag=? ]) ;
        $sth->execute( $row->{supply}, $row->{sdelay}, 
                       $row->{pfactor} ,
                       $type, $tag );
        $me->price_control( $ob, 1.0 ) if ref($ob);
        $me->price_control( $type, $tag, 1.0 ) unless ref($ob);
    }
    return 1;
}

# ---------------------------------------------------------------------
# stock_reset()
# called ONCE at reset by the time-daemon to update the whole stock-exchange list
sub stock_reset {
    my $me      = shift;
    # for each item, compute the mean demand and mean supply
    my $dbh = dbi();

    # weight old mean-demand with current-reset demand
    my $sth = $dbh->prepare( qq[ update engine_stock_exchange 
            set mdemand = mdemand * ? + demand  * ?
            where demand >= 1 and mdemand * ? + demand  * ? > 0 ]) ;
    $sth->execute( WEIGHT_MDEMAND, WEIGHT_DEMAND, WEIGHT_MDEMAND, WEIGHT_DEMAND );        

    # weight old mean-supply with current-reset supply
    $sth = $dbh->prepare( qq[ update engine_stock_exchange 
            set msupply = msupply * ? + supply  * ?
            where supply >= 1 and msupply * ? + supply  * ? > 0 ]) ;
    $sth->execute( WEIGHT_MSUPPLY, WEIGHT_SUPPLY, WEIGHT_MSUPPLY, WEIGHT_SUPPLY );        

    # demand too low... lower the price "as if" some item was bought
    $sth = $dbh->prepare( qq[ update engine_stock_exchange 
            set pfactor = pfactor * ( 1.0 - ((1.0 + ddelay ) / (mdemand * epsilon))
            where demand < int(? * mdemand) ]) ;
    $sth->execute( DEMAND_THRESHOLD );        
    
    # supply too low... raise the price "as if" some item was sold
    $sth = $dbh->prepare( qq[ update engine_stock_exchange 
            set pfactor = pfactor * ( 1.0 - ((1.0 + sdelay ) / (msupply * epsilon))
            where supply < int(? * msupply) ]) ;
    $sth->execute( SUPPLY_THRESHOLD );        

    # demand zero... keep track of that fact
    $sth = $dbh->prepare( qq[ update engine_stock_exchange 
            set ddelay = min ( ddelay,3 ) + 1
            where 1 >= demand ]) ;
    $sth->execute( );        

    # supply zero... keep track of that fact
    $sth = $dbh->prepare( qq[ update engine_stock_exchange 
            set sdelay = min ( sdelay,3 ) + 1
            where 1 >= supply ]) ;
    $sth->execute( );        

    # flushes the demand/supply
    $sth = $dbh->prepare( qq[ update engine_stock_exchange 
            set demand = 0, supply = 0 ]) ;
    $sth->execute( );        
    
    $sth = $dbh->prepare( qq[ update engine_stock_exchange 
            set pfactor = range_max where pfactor > range_max ]) ;
    $sth->execute( );        
    
    $sth = $dbh->prepare( qq[ update engine_stock_exchange 
            set pfactor = range_min where pfactor < range_min ]) ;
    $sth->execute( );        
}


#
# ----- List -----
#

# ---------------------------------------------------------------------
# stock_list()
# shows a formatted list of the arrays
sub stock_list {
    my $me      = shift;
    my $filter  = shift;
    my $pl      = current_user() ;
    my $hformat = "%-25s %5s %5s %7s %7s %6s %5s %5s %1s\n";
    my $wrap = 74 ;
    my @header = ();
    my @output = ();
    my @footer = ();
    push @header, "\n"  ;
    push @header, "-"x $wrap . "\n"  ;
    push @header, sprintf( $hformat, "Item", "Dom","Off", 
        "Dom M", "Off M", "Fact", "Stand", "Delay","F");
    push @header, "-"x $wrap . "\n"  ;
    push @footer, "-"x $wrap . "\n"  ;
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ select * from engine_stock_exchange ]) ;
    $sth->execute();        
    while( my $row = $sth->fetchrow_hashref() ) { 
        next if $filter && $row->{ tag } !~ m/^$filter/ ; 
        push @output, 
            sprintf( "%-25s "  , substr($row->{ tag       } ,0,25) ) .
            sprintf( "%5d "    ,        $row->{ demand    } ) .
            sprintf( "%5d "    ,        $row->{ supply    } ) .
            sprintf( "%7.1f "  ,        $row->{ mdemand   } ) .
            sprintf( "%7.1f "  ,        $row->{ msupply   } ) .
            sprintf( "%6.3f "  ,        $row->{ pfactor   } ) .
            sprintf( "%5d "    ,        $row->{ std_price } ) .
            sprintf( "%2d "    ,        $row->{ ddelay    } ) .
            sprintf( "%2d "    ,        $row->{ sdelay    } ) .
            sprintf( "%1d "    ,        $row->{ no_trade  } 
                                     +2*$row->{ bump_min  } 
                                     +4*$row->{ bump_max  } )  
            ."\n"
        ;
    }
    tell_object( $pl, @header );
    tell_object( $pl, sort @output );
    tell_object( $pl, @footer );
    return 1;
}

# ---------------------------------------------------------------------
# shop_list()
# non-wizard formatted list of items.
sub shop_list {
    my $me      = shift;
    my $shop    = shift;
    my $filter  = shift || '';
    my $pl     = current_user() ;
    my $this   = driver();

    my $cols   = $pl->wrap_col;
    my $deslen = $cols - 22;

    my $backshop = $shop;
    $backshop = find_object($shop->back_shop()) if $shop->isa('Shop') ;

    #tell_object( $pl, "shop: " . $shop->module . " , back: $backshop, filter: $filter " . "\n" );
    #tell_object( $pl, "back: " . $backshop->inventory . "\n" );

    my @accu   = @{$backshop->inventory};
    my %coun   = ();
    my %sing   = ();
    my %coin   = ();
    my $something = 0;

    # examines backshop inventory, count objects (for plurals)
    #while ( my ($key,$value) = each %accu ) { 
    foreach my $value (@accu) { 
        # item key: type.short
        my $tag   = $value->short();
        my $type  = 0;
        #
        next if ref($value) && $value->isa('Living');
        $coun{ "$type#$tag" } = 0 unless exists $coun{ $tag };
        $coun{ "$type#$tag" } += 1;
        $sing{ "$type#$tag" } = $value->short() || "?";
        $coin{ "$type#$tag" } = $value->value() || "0";
        $something = 1;
    }

    my @header = ();
    my @output = ();
    my @footer = ();

    if ( $something ) {
        push @header, "\n"  ;
        push @header, "-"x $cols . "\n"  ;
        push @header, "Lista degli articoli \n" ;
        push @header, sprintf( "%-${deslen}s %5s %4s \n","Descrizione","Prezzo","Disp");
        push @header, "-"x $cols . "\n"  ;

        my $dbh = dbi();
        my $sth = $dbh->prepare( 
            qq[ select * from engine_stock_exchange where type=? and tag=? ]) ;
        while ( my ($key,$quant) = each %coun ) { 
            my ($type,$tag) = split /#/, $key;
            next if $filter && $tag !~ m/^$filter/ ;
            $sth->execute( $type, $tag );        
            my $row = $sth->fetchrow_hashref();
            unless ( $row ) {
                $me->add_item( $type, $tag, 1.0 ); # pfactor
                $sth->execute( $type, $tag );        
                $row = $sth->fetchrow_hashref();
                return 0 unless $row;
            }
            my $coins =  (int( $row->{ pfactor } * $row->{ std_price } ) ) ;
                      ###|| $coin{ $key };
            $coins = 1 if $coins < 1;
            push @output, 
                sprintf( "%-${deslen}s %5d %4u \n",  # %-16s 
                    $sing{$key}, $coins, $quant #, $key
                       );
        }
        push @footer, "-"x $cols . "\n"  ;
    }
    else {
        push @header, "Il negozio è completamente vuoto!\n";
    }

    tell_object( $pl, @header );
    tell_object( $pl, sort @output ) if scalar(@output);
    tell_object( $pl, @footer );
    
    return 1;
}

#
# ----- Commands -----
#

# ---------------------------------------------------------------------
# sell_one_item()
sub sell_one_item {
    my $me      = shift;
    my $ob      = shift;
    my $room    = shift;

    unless ( ref($ob) && ref($room) ) {
        notify_fail( 'No ob or room' );
        return -1 ;
    }

    my $what    = $ob->short();
    my $pl      = current_user();
    
    # object will provide notify_fail
    return -1 if $ob->cannot_drop() ; # ask ob if it can be dropped
    
    my $price = int(0.5 * $me->query_price( $ob )); 
    
    if ( $price < 1 ) {
        notify_fail( parse_std_msg('Actions_Sell_ko4', $what ) ) ;
        return -1 ;
    }

    my $result = $ob->move( $room );
    
    if ( $result > 0 ) {
        tell_object( $pl, parse_std_msg('Actions_Sell_ok', $ob->short, $price) );
        say ( parse_std_msg('Actions_Sell_ok2', $ob->short, $price), $pl );
        tell_object( $ob, parse_std_msg('Actions_Sell_ok1', $ob->short, $price ) );
        $me->stock_sell( $ob ); 
        return 1; #$price;
    }
    else {
        notify_fail( parse_std_msg('Actions_Sell_ko2', $what ) ) if $result == -2;
        notify_fail( parse_std_msg('Actions_Sell_ko3', $what ) ) if $result == -3;
        return -1 ;
    }
}

# ---------------------------------------------------------------------
sub buy_one_item {
    my $me      = shift;
    my $ob      = shift;
    my $room    = shift;

    unless ( ref($ob) && ref($room) ) {
        notify_fail( 'No ob or room' );
        return -1 ;
    }

    my $what    = $ob->short();
    my $pl      = current_user();

    # object will provide notify_fail
    return -1 if $ob->cannot_get(); # asks ob if it can be gotten
    
    my $price = int($me->query_price( $ob )); 

    if ( $pl->money < abs($price) ) {
        notify_fail( parse_std_msg('Actions_Buy_ko4', $what ) ) ;
        return -1 ;
    }
    
    my $result = $ob->move( $pl ) ;
    if ( $result > 0 ) {
        $pl->money( $pl->money - $price );
        tell_object( $pl, parse_std_msg('Actions_Buy_ok', $ob->short, $price) );
        say ( parse_std_msg('Actions_Buy_ok2', $ob->short, $price), $pl );
        tell_object( $ob, parse_std_msg('Actions_Buy_ok1', $ob->short, $price ) );
        $me->stock_buy( $ob ); 
        return 1; #$price;
    }
    else {
        notify_fail( parse_std_msg('Actions_Buy_ko2', $what ) ) if $result == -2;
        notify_fail( parse_std_msg('Actions_Buy_ko3', $what ) ) if $result == -3;
        return -1 ;
    }
}

#   
# ----- "Economics" functions -----
#   
# these functions should return a correct value based on the fact
# that the object is a normal-item, luxury-item, inferior-item.
# Input: object reference
# Output: float value

# ---------------------------------------------------------------------
# compute_epsilon()
# Input: object reference
# Output: float value of "epsilon"
sub compute_epsilon {
    my $me      = shift;
    my $ob      = shift;
    if ( ! ref($ob) ) { return STANDARD_EPSILON } ; 
    if( $ob->value() > 1000 ) { return STANDARD_EPSILON * 0.7 } ;
    return STANDARD_EPSILON; 
}

# ---------------------------------------------------------------------
# compute_range_min()
# Input: object reference
# Output: float value of "min range"
sub compute_range_min {
    my $me      = shift;
    my $ob      = shift;
    if (! ref($ob) ) { return FACTOR_RANGE_MIN } ; 
    if( $ob->value() > 1000 ) { return FACTOR_RANGE_MIN / 0.7 } ;
    return FACTOR_RANGE_MIN; 
}

# ---------------------------------------------------------------------
# compute_range_max()
# Input: object reference
# Output: float value of "max range"
sub compute_range_max {
    my $me      = shift;
    my $ob      = shift;
    if (! ref($ob) ) { return FACTOR_RANGE_MAX } ; 
    if( $ob->value() > 1000 ) { return FACTOR_RANGE_MAX * 0.7 } ;
    return FACTOR_RANGE_MAX; 
}


=pod

---- Merchant daemon  ----

This is the "Supply & Demand" daemon.
Everithing in this daemon uses a "player" point of view:

The price to be used in transactions is evaluated multiplying the $ob->value()
by a "factor", so we choose to store the "factor" within this daemon, like a 
stock-exchange list. 
This let us retain the old-standard "value" of any object.

Obviously, this is a "anonymous" value: The rule of dividing it by two
for items sold by players or any bargain/appraisal will be applied "after" 
the call to this func.

The stock-exchange list is stored here in an hash-tied with a file.


---- Players' Purchases  ----

Any shop, pub, inn should signal to the stock-exchange all their sales 
calling   STOCKD->stock_buy(ob); 
This will slightly push up-ward the "factor", but since the price are always
rounded to integer, the effect will appear after few trades.


---- Players' Sales  ----

Any shop should signal to the stock-exchange all their purchases (player's sales)
calling   STOCKD->stock_sell(ob);
This will slightly push down-ward the "factor", but since the price are always
rounded to integer, the effect will appear after few trades.


---- Industrial input-output ----

Any factory that produce an output-item requires some input-items.
That factory should signal the number of input-items it consumes
calling STOCKD->stock_inter_buy(key, frac); 
for each item.

To determine the value of its output-item, the shop should then 
use a function that sums the current value of each input-item.


---- What happens at reset ----

On *each* reset the function "stock-reset" will be called ONCE
inside this daemon to update the stock-exchange list "en-masse".

The "mean supply" is updated adding the supply of the current reset-period.
The "mean demand" is updated adding the demand of the current reset-period.

The quantity sold in the last reset-period will slightly move
the mean-quantity used in the denominator of the formulas down or up
depending on the fact that the quantity sold has increased or 
decreased with respect of the mean of preivous periods.

The quantity bought in the last reset-period will slightly move
the mean-quantity used in the denominator of the formulas up or down
depending on the fact that the quantity bought has increased or 
decreased with respect of the mean of preivous periods.


---- The Stock-exchange List ----

For each "item in list" there is an entry in the following arrays.
array "mdemand" stores mean demand of the economy ( D[t] )
array "msupply" stores mean supply of the economy ( S[t] ) 
array "pfactor" stores the "factor" used for pricing ( pi[t] )
array "epsilon" stores the "elasticity" ( see Economics part below )
value "delta" is always "one", as we trigger for each item bought/sold.

Formula used are:  
pfactor[i] *= 1.0 + (1.0 / (mdemand[i] * epsilon[i]));  when players buy
pfactor[i] *= 1.0 - (1.0 / (msupply[i] * epsilon[i]));  when players sell

Anyway, the price must be between some bottom-level and top-level price.
for example enforcing the following condition:  pi[0]/2 <= pi[t] <= 2*pi[0]
so pi[t] (pfactor) ranges between 0.5 and 2, for example.
This keeps prices from being "absurdly" high or low. 

In this daemon, pfactor is updated each time a player buyes or sells any
item: an item is added to the list as soon as it is bought or sold

At reset, for each item listed, if someone bought or sold such an item
then we can recompute the mean-demand (mdemand) and mean-supply (msupply)
so the behaviour of the subsequent buy and sell will change slightly.

In this case we use a "weighted-mean" between the current mean demand
or supply and current level of demand/supply.
There is another feature: if demand/supply is too low then the price 
will go down/high (like a dealer would do).

Any room that handles with price/values should ask the current price
calling STOCKD->query_price(ob);
or
calling STOCKD->query_price_key(key);


---- Economics ----

Let us introduce the minimum "Economics" background ;-) 

We define "elasticity" of the quantity X with respect to price P of a
good the ratio between the percentage variations of X and P, i.e.

     E = (deltaX / X) / (deltaP / P)

that can be written

     E = (deltaX / deltaP) * ( P / X)

The "elasticity" is the "friction" in change of price with respect to 
quantity. The higher abs(E) is, the slower is the change. It should be greater
than 1 since, for our purpose, numbers less than 1 makes the price 
too reactive to quantity. So we can obtain deltaP

     deltaP = deltaX * P / ( X * E )

This can be used to describe the behaviour of the price P in base of
the behaviour of X and E. 

In general we can assume E as a constant for each good.

Let us define

  P[0]    Initial price, i.e. the old-standard item->value() 
  P[t]    The current value of sold/bought item.
  E       Elasticity of quantity sold/bought of item with respect to cost
          For supply and demand we use the same expression of elasticity.

Consider the Demand as everything players buy from the shop/pub

  D[t]    Demand of an item since last reset (here we use D in place of X)
   
if  D[t] > 0  then we can compute deltaP and the new price P[t+1]: 

  deltaD[t] := D[t+1] - D[t]
  deltaP[t] := P[t] / ( D[t] * E ) * deltaD
  P[t+1]    := P[t] + deltaP

Now, consider the Supply as everything players sell to the shop.

  S[t]    Supply of an item since last reset (here we use S in place of X)

if  S[t] > 0  then we can compute deltaP and the new price P[t+1]: 

  deltaS[t] := S[t+1] - D[t]
  deltaP[t] := P[t] / ( D[t] * E ) * deltaS
  P[t+1]    := P[t] + deltaP

As we said before, we store the factor "pi" that multiplied by the P[0] 
gives the price, i.e. 

  P[t] = pi[t] * P[0]

**** keep track of bumps 
**** The no-trade signal is under development.
**** develop a function that calcs the price of shop's output set_value()
**** without scratching every "std_price".
*/

=cut

