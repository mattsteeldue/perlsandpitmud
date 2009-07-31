=pod

Uso: quit
Chiude il collegamento, si usa per uscire dal Mondo Emerso.

=cut

# ---------------------------------------------------------------------
sub cmd_quit { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();
    my $this   = driver();
    my @accu   = @{$pl->inventory};

    foreach my $ob ( @accu ) { 
        unless ( $ob->query_property('permanent') ) {
            if( ($ob->value||0) < getsetup('MaxValueToDrop') ) { 
                do_command('drop' , $ob );
            }
            else {
                $ob->destroy();
            }
        }
    }

    if ( $pl->status ne 'Quit' ) {
        log_file( 'command.log',  'Cannot save ' ) unless do_command( 'save' );
        
        shout ( parse_std_msg('ShoutQuitsTheGame') );
        
        tell_object( $pl, parse_std_msg('Actions_Quit') );
        $pl->status( 'Quit' );
    }

    return 1;
}

