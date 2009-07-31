=pod

Uso: poweroff

=cut

# ---------------------------------------------------------------------
sub cmd_poweroff { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();
    my $this   = driver();
    my @accu   = @{$pl->inventory};

    tell_object( $pl, "Poweron\n" ) if $pl->echo();

    foreach my $ob ( @accu ) { 
        my $file = basename($ob->module);
        #tell_object( $pl, $ob->name, ": " );
        if ( $ob->isa('Garment') ) { $pl->force_to('remove '  . $ob->name) }
        if ( $ob->isa('Weapon') )  { $pl->force_to('unwield ' . $ob->name) }
    }

    return 1;    
}

