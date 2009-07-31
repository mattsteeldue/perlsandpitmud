# BackShop.pm
# Created Jul 2007
# Author  flogisto

package BackShop;
use strict;
##use diagnostics;

use Commons;
use Room;

our @ISA = qw(Room);

=pod

This is the backoffice of a shop.
Wizard can enter to check how the stock is.

=cut

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    my $the_shop = shift;
    $self->add_exit( 'shop', $the_shop )  
         ->the_shop( $the_shop ) 
         ->add_action( 'stock'    ,'do_stock'   ) 
         ->add_action( 'unstock'  ,'do_unstock' ) 
         ->short('General Store') 
         ->desc( "Default General store.\n" )
         ;
    ###print "$the_shop\n";

    return $self;
}

# ---------------------------------------------------------------------
sub the_shop       { (@_)>1 ? ($_[0]->{TheShop}      = $_[1],$_[0]) : $_[0]->{TheShop}       } 

# ---------------------------------------------------------------------
# shows a formatted list of the arrays
sub do_stock {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $verb  = shift; 
    my $pl = current_user();
    return -1 unless $pl->wizardhood();
    daemon('stock','stock_list');
    return $this;
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
    ###print "result $result\n";
    return $result;
}

1;
