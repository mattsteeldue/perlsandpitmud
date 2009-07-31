# Shop.pm
# Created Jul 2007
# Author  flogisto

package Shop;
use strict;
##use diagnostics;

use Commons;
use Room;

our @ISA = qw(Room);

# ---------------------------------------------------------------------
sub back_shop       { (@_)>1 ? ($_[0]->{BackShop}      = $_[1],$_[0]) : $_[0]->{BackShop}       } 
sub shop_clerk      { (@_)>1 ? ($_[0]->{ShopClerk}     = $_[1],$_[0]) : $_[0]->{ShopClerk}      } 
sub trash_can       { (@_)>1 ? ($_[0]->{TrashCan}      = $_[1],$_[0]) : $_[0]->{TrashCan}       } 

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    my $fn = 0;
    my $clerk = 0;
    
    $self->short('Shop')
         ->desc( "Un semplice negozio\n" )
         ->add_detail( ['sign','cartello'] , \&do_sign )
         
         ->add_action( 'lista'    ,'do_list'    ) 
         ->add_action( 'list'     ,'do_list'    ) 
         ->add_action( 'valuta'   ,'do_value'   ) 
         ->add_action( 'value'    ,'do_value'   ) 
         ->add_action( 'compra'   ,'do_buy'     ) 
         ->add_action( 'buy'      ,'do_buy'     ) 
         ->add_action( 'vendi'    ,'do_sell'    ) 
         ->add_action( 'sell'     ,'do_sell'    ) 
                                                  
         # wizard only!                                
         ->add_action( 'stock'    ,'do_stock'   ) 
         ->add_action( 'unstock'  ,'do_unstock' ) 
         #->add_action( 'restock'  ,'do_restock' )
         ->add_action( 'store'    ,'do_go_store'    )
    
         ->trash_can( $self->add_unique_object( 'std/obj/trash_can' ) )
         ;

    # creates the back-shop room
    $fn = basename($self->module) . "_back";
    $self->back_shop( $fn );
    unless ( find_object( $fn ) ) {
        call_other( $fn, 'new', basename($self->module) );
        unless ( find_object( $fn ) ) {
            $self->back_shop( 'std/room/general_store_back' ) ;
            #call_other( $fn, 'new', basename($self->module) ) 
            #    unless ( find_object( $self->back_shop ) );
        }
    }

    # adds the shop-clerk    
    $fn = basenavdir(     
        basedirname($self->module) . '/../mon/' .
        basefilename($self->module) . '_clerk' ) ;
    $self->shop_clerk( $fn );
    unless ( find_object( $fn ) ) {
        $clerk = call_other( $fn, 'new', basename($self->module) );
        unless ( ref($clerk) ) {
            $fn = 'std/mon/general_store_clerk';
            $self->shop_clerk( $fn ) ;
            $clerk = call_other( $fn, 'new', basename($self->module) ) ;
        }
        $clerk->move( $self ) if ref($clerk);
    }
    
    return $self;
}

# ---------------------------------------------------------------------
sub do_sign {
    my $this  = shift;
    my $what  = shift ;
    my $verb  = shift; 
    my $pl    = current_user();

    tell_object( $pl, <<'END' );
  In questo negozio sono disponibili i comandi
    lista    per vedere gli articoli disponibili (filtrabile)
    compra   per comprare un articolo in lista
    vendi    per vendere un articolo al prezzo di mercato
    valuta   per decidere il prezzo di mercato di un articolo
END

    if ($pl->wizardhood) {
        tell_object( $pl, <<'END' );
    store    per accedere al retrobottega (back ritorna qui)
    stock    per vedere il listino di borsa (filtrabile)
    unstock  per rimuovere un item dal listino
END
    }

        say( $pl->short . " esamina il cartello appeso al muro.\n", $pl );    
        return "\n";
}

# ---------------------------------------------------------------------
sub do_stock {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $verb  = shift; 
    my $filter = shift;
    my $pl = current_user();
    return -1 unless $pl->wizardhood();
    daemon('stock','stock_list', $filter );
    return 1;
}

# ---------------------------------------------------------------------
sub do_unstock {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $verb  = shift; 
    my $key   = "@_"; # in the format "type.desc"
    my $pl = current_user();
    return -1 unless $pl->wizardhood();
    return -1 unless $key;
    my $result = daemon('stock','remove_item', $key );
    return $result;
}

# ---------------------------------------------------------------------
sub do_go_store {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $verb  = shift; 
    my $pl = current_user();
    return -1 unless $pl->wizardhood();

    my $here   = $pl->environment();
    my $where  = effective_file_name(  $this->back_shop() , $this);
    if ( $pl->move( $where ) > 0 ) {
        tell_room( $here, parse_string( '$n va nel retro.\n' ) );
        say( parse_string( $pl->message_in(), $verb ), $pl );
        $pl->force_to('look');
    }
    return 1;
}

# ---------------------------------------------------------------------
sub do_list {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $verb  = shift;
    my $filter = shift;
    my $pl = current_user();
    daemon('stock','shop_list', $this, $filter );
    return 1;
}

# ---------------------------------------------------------------------
sub do_buy {
    my $this   = shift;
    my $verb   = shift;
    my $what   = shift;
    my $which  = shift || 1;
    my $pl     = current_user();
    #my $driver = driver();
    my $room   = find_object(effective_file_name( $this->back_shop() )) || $pl->environment();
    my $clerk  = find_object(effective_file_name( $this->shop_clerk() )) || 0;

    unless( $what ) {
        notify_fail( parse_std_msg('Actions_Buy_no_what') );
        return -1;
    }
    if ( ! $clerk ) { 
        notify_fail( parse_std_msg('Actions_no_shop_clerk') );
        return -1 
    }
    if ( $pl->ghost() ) {
        notify_fail( parse_std_msg('NotifyGhost') ) ;
        return -1;
    }

    my $ob = find_object( $what, $room, $which - 1 );
    if ( $ob && ref($ob) ) {
        return daemon('stock','buy_one_item', $ob, $room );
    }

    notify_fail( parse_std_msg('Actions_Buy_ko', $what) ) if( $which == 1 );
    notify_fail( parse_std_msg('Actions_Buy_ko1', $what) ) unless( $which == 1 );
    return -1;
}

# ---------------------------------------------------------------------
sub do_sell {
    my $this   = shift;
    my $verb   = shift;
    my $what   = shift;
    my $which  = shift || 1;
    my $pl     = current_user();
    #my $driver = driver();
    my $room   = find_object(effective_file_name( $this->back_shop() )) || $pl->environment();
    my $clerk  = find_object(effective_file_name( $this->shop_clerk() )) || 0;

    unless( $what ) {
        notify_fail( parse_std_msg('Actions_Sell_no_what') );
        return -1;
    }
    if ( ! $room ) { 
        notify_fail( parse_std_msg('Actions_no_environment') );
        return -1 
    }
    if ( ! $clerk ) { 
        notify_fail( parse_std_msg('Actions_no_shop_clerk') );
        return -1 
    }
    if ( $pl->ghost() ) {
        notify_fail( parse_std_msg('NotifyGhost') ) ;
        return -1;
    }

    if ( $what eq 'all' || $what eq std_msg('all') ) {
        my @ary =  @{ $pl->inventory } ;
        my $totalprice = 0;
        my @outp = ();
        my $reply;
        foreach my $ob ( @ary ) {
            my $price = daemon('stock','sell_one_item',$ob, $room );
            $reply = $ob->short . " è senza valore." if $price < 1;
            $reply = $ob->short . " vale $price." if $price >= 1;
            $totalprice += $price if $price > 0;
            $clerk->force_to( "say $reply" );
        }
        tell_object( $pl, parse_std_msg('Actions_Sell_total', $totalprice) );
        return 1;
    }
    
    my $ob = find_object( $what, $pl, $which - 1 );
    if ( $ob && ref($ob) ) {
        return daemon('stock','sell_one_item', $ob, $room );
    }

    notify_fail( parse_std_msg('Actions_Sell_ko', $what) ) if( $which == 1 );
    notify_fail( parse_std_msg('Actions_Sell_ko1', $what) ) unless( $which == 1 );
    return -1;
}

# ---------------------------------------------------------------------
sub do_value {
    my $this   = shift;
    my $verb   = shift;
    my $what   = shift;
    my $which  = shift || 1;
    my $pl     = current_user();
    #my $driver = driver();
    my $room   = find_object(effective_file_name( $this->back_shop() )) || $pl->environment();
    my $clerk  = find_object(effective_file_name( $this->shop_clerk() )) || 0;

    unless( $what ) {
        notify_fail( parse_std_msg('Actions_Value_no_what') );
        return -1;
    }
    if ( ! $room ) { 
        notify_fail( parse_std_msg('Actions_no_environment') );
        return -1 
    }
    if ( ! $clerk ) { 
        notify_fail( parse_std_msg('Actions_no_shop_clerk') );
        return -1 
    }
    if ( $pl->ghost() ) {
        notify_fail( parse_std_msg('NotifyGhost') ) ;
        return -1;
    }

    my $ob = find_object( $what, $pl, $which - 1 );

    if ( $ob && ref($ob) ) {
        my $price = int(0.5 * daemon('stock','query_price', $ob ) );
        tell_object( $pl, parse_std_msg('Actions_Value_result',$price) ) ;
        return 1;
    }

    notify_fail( parse_std_msg('Actions_Value_ko', $what) ) if( $which == 1 );
    notify_fail( parse_std_msg('Actions_Value_ko1', $what) ) unless( $which == 1 );
    return -1;
}

1;
