=pod

Uso: try <comandi perl>
Tenta di eseguire come espressione i comandi libreria o i comandi perl specificati.
Esempio: try current_user()->short()
Esempio: try 12+3

=cut

##use Archive; 

# ---------------------------------------------------------------------
sub cmd_try { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();
    my $room   = $pl->environment();
    my $ob;
    
    # only interactive can
    return -1 unless $pl->isa('User');

    # only wizards can     
    return -1 unless $pl->wizardhood;
    
    return -1 unless ($pl->name eq 'flogisto' || $pl->name eq 'mattsteel');

    unless ( @_ ) { 
        notify_fail( parse_std_msg('Actions_Try_ko') ); 
        return -1; 
    }

    my $result = undef;

    $pl->inputline =~ m/$verb\s+/;
    $pl->inputline( '' );
    
    my $statement = $';

    {
        ##tell_object( $pl, "$statement\n" );
        local $SIG{__DIE__} = sub { eval { showcomperr($verb,"$_[0]") } ; } ;
        local $SIG{__WARN__} = sub { eval { showwarnerr($verb,"$_[0]") } ; } ;
        $result = eval qq{ $statement };
    }
    

    if ( defined($result) ) {
        tell_object( $pl, parse_std_msg('Actions_Try_result', $result) );
    }
    else {
        tell_object( $pl, "$@\n") ;
    }
    
    return 1; 
}
