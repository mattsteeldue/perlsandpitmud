=pod

Uso: attacca <chi>

=cut

# ---------------------------------------------------------------------
sub cmd_attack { 
    my $me     = shift;
    my $verb   = shift;
    my $who    = shift; $who = lc($who);

    my $this   = driver();
    my $pl     = current_user();
    my $ob     = find_object( $who );

    unless ( $who ) {
        notify_fail( parse_std_msg('Actions_Attack_ko') );
        return -1;
    }        

    if ( $pl->level() <= getsetup('Level2Attack') ) {
        notify_fail( parse_std_msg('Actions_Attack_level' ) );
        return -1;
    }
    
    if ( $who eq $pl->name ) {
        notify_fail( parse_std_msg('Actions_Attack_self' ) );
        return -1;
    }

    unless ( ref($ob) && $ob->environment == $pl->environment) {
        notify_fail( parse_std_msg('Actions_Attack_target', ucfirst($who) ) );
        return -1;
    }        

    tell_object( $pl, "Attacchi \u$who.\n" ) if $pl->echo();
    tell_object( $ob, $pl->short , " ti attacca.\n" );  

    if ( ref($ob) && $ob->isa('Living') && $ob != $pl ) {
        my $combat = $ob->combat;
        $combat = clone_object( 'std/obj/combat_in_progress', $ob, $pl ) unless ref($combat );
        unless ( ref($combat ) ) {
            notify_fail( 'Cannot start combat' );
            return -1;
        }
        my $result = $combat->move( $pl->environment ) ;
        unless ( $result > 0 ) {
            notify_fail( 'Cannot move combat object' );
            return -1;
        }
        return 1;
    }
    
    return 1;    
}

