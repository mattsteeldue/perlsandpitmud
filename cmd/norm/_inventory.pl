=pod

Per interagire con gli oggetti mobili hai a disposizione i seguenti comandi; alcuni comandi sono disponibili in due lingue, italiano e inglese.

- prendi  - get     - per prendere un oggetto
- lascia  - drop    - per lasciare un oggetto
- dai     - give    - per dare un oggetto a qualcuno
- esamina - examine - per esaminare un oggetto disponibile
- i       - inventory - lista degli oggetti che stai portando.

=cut

# ---------------------------------------------------------------------
# list current user's inventory
sub cmd_inventory { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();
    my $this   = driver();
    my $cols   = $pl->wrap_col;
    my $deslen = $cols - 22;
    #my %accu   = %{$pl->inventory()};
    my @accu   = @{$pl->inventory};
    my %coun   = ();
    my %sing   = ();
    my %plur   = ();
    my $something = 0;
    
    if ( $pl->ghost() ) {
        notify_fail( parse_std_msg('NotifyGhost') ) ;
        return -1;
    }

    # examines your inventory, count objects (for plurals)
    #while ( my ($key,$value) = each %accu ) { 
    foreach my $value (@accu) { 
        my $name   = $value->name();
        $coun{ $name } = 0 unless exists $coun{ $name };
        $coun{ $name } += 1;
        $sing{ $name } = $value->short() || "?";
        $plur{ $name } = $value->shorts() || $value->short();
        $something = 1;
        $sing{ $name } .= ' (indosso)' if $value->isa('Garment') && $value->wearing();
        $plur{ $name } .= ' (indosso)' if $value->isa('Garment') && $value->wearing();
        $sing{ $name } .= ' (in uso)' if $value->isa('Weapon') && $value->wielding();
        $plur{ $name } .= ' (in uso)' if $value->isa('Weapon') && $value->wielding();
    }

    # display
    if ( $something ) {
        tell_object( $pl, parse_std_msg('Actions_Inventory' ) );
        tell_object( $pl, '-'x $cols . "\n" );
        while ( my ($key,$value) = each %coun ) { 
            my $short  = $sing{ $key }; 
            my $shorts = $plur{ $key }; 
            tell_object( $pl, sprintf( "%4u %-16s %-${deslen}s\n", $value, $key, 
                       ($value==1 ? $sing{ $key } : $plur{ $key } ) ) ); 
        }
        tell_object( $pl, '-'x $cols . "\n" );
    }
    else {
        tell_object( $pl, parse_std_msg('Actions_Inventory_no' ) );
    }
           
    return 1; 
}

