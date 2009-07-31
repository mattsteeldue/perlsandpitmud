=pod

Uso: poweron

=cut

# ---------------------------------------------------------------------
sub cmd_poweron { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();
    my $this   = driver();
    my @accu   = @{$pl->inventory};

    tell_object( $pl, "Poweron!\n" ) if $pl->echo();

    foreach my $ob ( @accu ) { 
        my $file = basename($ob->module);
        #tell_object( $pl, $ob->name, ": " );
        if ( $ob->isa('Garment') ) { $pl->force_to('wear '  . $ob->name) }
        if ( $ob->isa('Weapon') )  { $pl->force_to('wield ' . $ob->name) }
    }

    return 1;    
}

