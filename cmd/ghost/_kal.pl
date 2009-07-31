=pod

Uso: kal

=cut

# ---------------------------------------------------------------------
sub cmd_kal { 
    my $me      = shift;
    my $verb    = shift;
    my $pl      = current_user();
    my $user    = find_user( shift ) || $pl ;
    
    $user = $pl unless $pl->wizardhood();

    tell_object( $pl, getcolor('Weather') . "* At " . $user->short, " *\n" ) unless $user == $pl;
    tell_object( $pl, getcolor('Weather') . daemon('time')->query_kal( $user ), "\n" );
    tell_object( $pl, getcolor('Weather') . $pl->custom('WeatherLastMessage'), ".\n" );
    return 1;
}
