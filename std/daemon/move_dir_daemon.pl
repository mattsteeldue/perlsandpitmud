# move_dir_daemon.pl
# Created May 2007
# Author  flogisto

# ---------------------------------------------------------------------
use Daemon;

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( 'move_dir_daemon' );
    bless $self, $class ;
    return $self;
}

# ---------------------------------------------------------------------
# move current user in another location using the standard directions.
# the verb used is eventually translated using the "directions" hash
# if there is no way in the "verb" direction a message is issued
# the user is transfered at the new location and forced to "look"
sub do_move_dir { 
    my $me     = shift;
    my $verb   = shift; 
    my $pl     = current_user();
    my $this   = driver();
    my $here   = $pl->environment();

    unless( $here ) {
        notify_fail( std_msg('Actions_no_environment') );
    }
    
    # translates directions
    my $msg_act = getsetup("Direction_${verb}_act") || $verb;
    $verb = getsetup("Direction_$verb") || $verb;

    if ( exists $here->obvious_exits()->{ "$verb" } ) {
        my $where  = $here->obvious_exits()->{ "$verb" };
        my $result = $pl->move( $where ) ;
        #
        if ( $result > 0 ) {
            my $msg_out = $here->obvious_exit_msg()->{ "$verb" } || $pl->message_out();
            #$msg_out =~ s/\n$//;
            #$msg_out .= "." unless $msg_out =~ /\.$/;
            #$msg_out .= "\n";
            tell_room( $here, parse_string( $msg_out, $msg_act ) );
            say( parse_string( $pl->message_in(), $msg_act ), $pl );
            $pl->force_to('look');
            
            my @ary = @{ $pl->follower } ;
            foreach my $usr ( @ary ) {
                my $ob = find_living( $usr, $here );
                unless ( $ob ) {
                    # dead living or lost follower
                    #print "$ob $usr\n";
                    remove_from_array( $pl->follower, $usr );
                    next;
                }
                # same room?
                next unless $ob->environment == $here;
                $result = $ob->move( $where ) ;
                if ( $result > 0 ) {
                    tell_object( $ob, parse_std_msg('Follow', $pl->short ) );
                    current_user( $ob );
                    tell_room( $here, parse_string( $ob->message_out(), $verb ) );
                    say( parse_string( $ob->message_in(), $verb ), $ob );
                    current_user( $pl );
                    $ob->force_to('look');
                }
            }
            
            return 1;
        }
        else {
            notify_fail( parse_std_msg('Actions_do_move_dir_ko2', $verb ) ) if $result == -2;
            notify_fail( parse_std_msg('Actions_do_move_dir_ko3', $verb ) ) if $result == -3;
            return -1 ;
        }
    }
    else {
        notify_fail( parse_std_msg('Actions_do_move_dir_ko', $verb ) );
        return -1
    }    
}

