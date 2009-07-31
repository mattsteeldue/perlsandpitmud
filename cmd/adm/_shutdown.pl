=pod

Uso: shutdown <secondi>
Arresta il MUD entro n secondi. Manda una comunicazione a tutto il Mondo Emerso. 
Questo comando non lascia scampo e perciò viene tracciato su un log.

=cut

# ---------------------------------------------------------------------
# kills the mud driver setting "drv_is_alive" to false.
sub cmd_shutdown { 
    my $me     = shift;
    my $verb   = shift;
    my $delay  = shift || 0;
    my $this   = driver();
    my $pl     = current_user();
    
    # only interactive can
    return -1 unless $pl->isa('User');

    # only wizards can     
    return -1 unless $pl->wizardhood;

    if ($delay =~ /^\d+$/ && $delay > 0) {
        $this->time_to_halt(time() + $delay);
        save_all_users ;
        tell_object( $pl, parse_std_msg('Actions_Shutdown1',$delay)) if $pl->echo();
        shout( parse_std_msg('Actions_Shutdown2',$delay));
        log_file ('command.log', $pl->name, " shutdowns the driver within $delay sec." );
    }
    else {
        notify_fail( parse_std_msg('Actions_Shutdown_ko'));
        return -1;
    }

    return 1;
}
