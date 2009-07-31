# trash_can.pl
# Created Aug 2006
# Author  flogisto

# Trash can object. Automatically loaded within any shop.

use Object;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;    

    $self->add_id( ['trash','bidone'] );
    $self->short('bidone della spazzatura');
    $self->shorts('bidoni della spazzatura');
    $self->desc( 'Un bidone della spazzatura: qui puoi "buttare" quanto non ti serve più');

    $self->add_action( 'cestina'    ,'do_trash'   );
    $self->add_action( 'butta'      ,'do_trash'   );
    $self->add_action( 'buttare'    ,'do_trash'   );
    $self->add_action( 'trash'      ,'do_trash'   );
    
    return $self;
}

# ---------------------------------------------------------------------
sub cannot_get { return 1; }

# ---------------------------------------------------------------------
sub do_trash {
    my $this   = shift;
    my $verb   = shift;
    my $what   = shift;
    my $which  = shift || 1;
    my $pl     = current_user();
    my $room   = $pl->environment();

    unless( $what ) {
        notify_fail( parse_std_msg('Actions_Trash_no_what') );
        return -1;
    }
    if ( ! $room ) { 
        notify_fail( parse_std_msg('Actions_no_environment') );
        return -1 
    }
    if ( $pl->ghost() ) {
        notify_fail( parse_std_msg('NotifyGhost') ) ;
        return -1;
    }

    if ( $what eq 'all' || $what eq std_msg('all') ) {
        my @ary =  @{ $pl->inventory } ;
        foreach my $ob ( @ary ) {
            $ob->trans_object_out( $pl );
            tell_object( $pl, parse_std_msg('Actions_Trash_ok', $ob->short) ) ;
            say ( parse_std_msg('Actions_Trash_ok2', $ob->short), $pl );
            tell_object( $ob, parse_std_msg('Actions_Trash_ok1') );
            $ob->destroy();
        }
        return 1;
    }
    
    my $ob = find_object( $what, $pl, $which - 1 );
    if ( $ob && ref($ob) ) {
        $ob->trans_object_out( $pl );
        tell_object( $pl, parse_std_msg('Actions_Trash_ok', $ob->short) ) ;
        say ( parse_std_msg('Actions_Trash_ok2', $ob->short), $pl );
        tell_object( $ob, parse_std_msg('Actions_Trash_ok1') );
        $ob->destroy();
        return 1;
    }

    notify_fail( parse_std_msg('Actions_Trash_ko', $what) ) if( $which == 1 );
    notify_fail( parse_std_msg('Actions_Trash_ko1', $what) ) unless( $which == 1 );
    return -1;
}

