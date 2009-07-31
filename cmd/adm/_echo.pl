=pod

Uso: echo <text>
Scrive <text> su tutti i terminali

=cut

# ---------------------------------------------------------------------
sub cmd_echo { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();
    my $this   = driver();

    # only interactive can
    return -1 unless $pl->isa('User');

    # only wizards can     
    return -1 unless $pl->wizardhood;

    while ( my ($key,$user) = each %{$this->clients} ) { 
        if ( ref($user) && $user->isa('User') && ref($user->client()) ) {
            my $cl = $user->client;
            
            tell_object( $user, "@_\n" ) ; 
        }
    }
    return 1;    
}
