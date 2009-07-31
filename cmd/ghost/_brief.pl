=pod

Uso: brief [desc|short|note|combat]
Per i wizard: brief [desc|short|note|sys|kal|wea|combat]

=cut

# ---------------------------------------------------------------------
sub cmd_brief { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift;
    my $this   = driver();
    my $pl     = current_user();
    my $bits   = $pl->brief;
    
    unless( $what ) {
        notify_fail( parse_std_msg('Actions_Brief_ko',
                            ' desc'   . ($bits &  1 ? '+' : '-'),
                            ' short'  . ($bits &  2 ? '+' : '-'),  
                            ' note'   . ($bits &  4 ? '+' : '-'), 
          $pl->wizardhood ? ' sys'    . ($bits &  8 ? '+' : '-')   : '',
          $pl->wizardhood ? ' kal'    . ($bits & 16 ? '+' : '-')   : '',
          $pl->wizardhood ? ' wea'    . ($bits & 32 ? '+' : '-')   : '',
                            ' combat' . ($bits & 64 ? '+' : '-'),
            ));
        return -1;
    }
    $bits ^=  1 if $what eq 'desc';   
    $bits ^=  2 if $what eq 'short';   
    $bits ^=  4 if $what eq 'note';   
    $bits ^=  8 if $what eq 'sys';   
    $bits ^= 16 if $what eq 'kal';   
    $bits ^= 32 if $what eq 'wea';   
    $bits ^= 64 if $what eq 'combat';   
    $pl->brief( $bits );
    return 1;
}

