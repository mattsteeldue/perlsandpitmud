=pod

Uso: debug_dice <dice_id> <number>

=cut

# ---------------------------------------------------------------------
sub cmd_debug_dice { 
    my $me       = shift;
    my $verb     = shift;
    my $dice_id  = shift || ''; 
    my $number   = shift || 0;

    my $this     = driver();
    my $pl       = current_user();

    # only interactive can
    return -1 unless $pl;
    
    # only wizards can     
    return -1 unless $pl->wizardhood(); # silently returns
    
    $pl->debug_dice = {} unless ref($pl->debug_dice);

    if ( $dice_id ) {
        $pl->debug_dice->{ $dice_id } = 0 unless exists $pl->debug_dice->{ $dice_id };
        if ( $number ) {
            delete $pl->debug_dice->{$dice_id};; 
            tell_object( $pl, "Debug of dice $dice_id is disabled.\n" );
        }
        else {
            $pl->debug_dice->{$dice_id} = abs($number); 
            tell_object( $pl, "Dice $dice_id set to $number\n" );
        }
    }
    else {
        while ( my ($key,$value) = each %{ $pl->debug_dice() } ) { 
            tell_object( $pl, " $key -> $value\n" );
        }
    }
    
    return 1;    
}
    