=pod

Uso: users
Presenta a video l'elenco degli utenti attualmente collegati.

=cut

# ---------------------------------------------------------------------
###use Archive;
sub cmd_users { 
    my $me     = shift;
    my $verb   = shift;
    my $param  = shift || '';
    my $filter = shift || $param;
    my $this   = driver();
    my $pl     = current_user();
    my @header = ();
    my @output = ();
    my @footer = ();
    my ($k,$v) ;
    my $ob;
    my $tt   = time();
    
    while ( ($k,$v) = each %{$this->user_names} ) { 
        next if $filter && $k !~ m/$filter/i;
        $ob = $this->objects->{ $k } ;
        push @output, sprintf( "%3i %-25s %4s %-8s %-17s", 
             $ob->level,
             $ob->short . " (" . $ob->query_title . ")" , 
             (($ob->idletime + 60 < $tt ) ? 'I ' : '  ') . ( $ob->earmuffed ? 'E ' : '  ' ) ,
             $ob->race , 
             $ob->land ) 
             . "\n"  ;
    }
    push @header, "\n" ;
    push @header, "-"x $pl->wrap_col . "\n"  ;
    push @header, "Ci sono " . scalar(@output) . " utenti collegati.\n" if scalar(@output) > 1 ;
    push @header, "Sei l'unico utente collegato.\n" if scalar(@output) == 1 ;
    push @header, "\n" ;
    push @header, sprintf( "%3s %-25s %4s %-8s %-17s", 
             'Liv', 'Nome', 'Idle', 'Razza', 'Terra' ) . "\n"  ;
    push @header, "-"x $pl->wrap_col . "\n"  ;
    push @footer, "-"x $pl->wrap_col . "\n"  ;
            
    tell_object( $pl, @header );
    tell_object( $pl, sort @output );
    tell_object( $pl, @footer );

    return 1;
}

