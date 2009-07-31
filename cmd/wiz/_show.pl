=pod

Uso: show [recursive] <object> [prop] | clone|exits|actions | objects|all|living driver...
Mostra alcune informazioni della stanza dove ti trovi.
 all       - mostra tutti gli oggetti registrati (oggetti, stanze, mob, utenti...)
 driver    - mostra il driver (oppure un suo elemento)
 objects   - mostra gli oggetti nella stanza
 actions   - mostra i verbi disponibili nella stanza
 living    - mostra i mob e i personaggi
 emotes    - mostra i verbi associati alle 'emotes'
 exits     - mostra le stanze adiacenti accessibili
 clone     - mostra gli oggetti clonati ad ogni 'restart'
 details   - mostra i dettagli della stanza
 prop      - mostra le properties
 <nome>    - mostra i dettagli di un oggetto, utente o mob.
 recursive - effettua una ricorsione durante la ricerca ***
 
=cut

# ---------------------------------------------------------------------
sub cmd_show { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift || 0;
    my $filter = shift || '.*';
    my $pl     = current_user();

    if ($what eq 'all') { 
        tell_object( $pl, parse_std_msg('Actions_Show_all' ) );
        my @output = ();
        while ( my ($key,$value) = each %{ driver()->objects } ) { 
            my $room = '--';
            if ( ref($value) && ref($value->environment)) {
                $room = $value->environment->module ;
                $room = $value->environment->short if $value->environment->isa('User');
            }
            my $lin = sprintf( '%-35s (%-35s)', $key, $room) . ansi_clear() . "\n";
            next unless $lin =~ m/$filter/i;
            push @output, $lin;
        }
        tell_object( $pl, sort @output );
        return 1;    
    }
    elsif ($what =~ /^driver\.(.*)$/ ) { 
        $what = $1;
        tell_object( $pl, $what, ' = ', driver->{"$what"}, "\n" ) ;
        return 1;
    }
    elsif ($what eq 'driver') { 
        tell_object( $pl, parse_string('{Red}Master object\n' ) );
        my @output = ();
        while ( my ($key,$value) = each %{ driver() } ) { 
            my $lin = $key . ' = ' . $value . ansi_clear() ;
            $lin .= " (" . time_to_str($value,'WW YYYY-MM-DD HH.MI.SS') . ")" if $value =~ m/^\d+$/ && $value > 1000000000;
            $lin .= " [@{$value}]" . ansi_clear()  if ref($value) eq 'ARRAY';
            if ( ref($value) eq 'HASH' ) { while ( my ($hk,$hj) = each %{$value} ) { $lin .= " $hk=>$hj" } }
            next unless $lin =~ m/$filter/i;
            push @output, $lin . "\n" ;
        }
        tell_object( $pl, sort @output );
        return 1;    
    }
    elsif ($what eq 'env') { 
        tell_object( $pl, parse_std_msg('Actions_Show_env'));
        my @output = ();
        foreach my $value (@{ $pl->environment->inventory } ) { 
            my $lin = " " . $value->keyname . "\n" ;
            next unless $lin =~ m/$filter/i;
            push @output, $lin;
        }
        tell_object( $pl, sort @output );
        return 1;    
    }
    elsif ($what eq 'act') { 
        tell_object( $pl, parse_std_msg('Actions_Show_act'));
        my @output = ();
        while ( my ($key,$value) = each %{ $pl->environment->actions } ) { 
            my $lin = $key . ' -> ' . $value . "\n";
            next unless $lin =~ m/$filter/i;
            push @output, $lin ;
        }
        tell_object( $pl, sort @output );
        return 1;    
    }
    elsif ($what eq 'living') { 
        tell_object( $pl, parse_std_msg('Actions_Show_living'));
        my @output = ();
        while ( my ($key,$value) = each %{ driver()->objects } ) { 
            next unless (ref($value) && $value->isa('Living')) ;
            my $room = '--';
            if ( ref($value) && ref($value->environment)) {
                $room = $value->environment->module ;
                $room = $value->environment->short if $value->environment->isa('User');
            }
            my $lin = sprintf( '%-35s (%-35s)', $key, $room) . ansi_clear() . "\n";
            next unless $lin =~ m/$filter/i;
            push @output, $lin;
        }
        tell_object( $pl, sort @output );
        return 1;    
    }
    elsif ($what eq 'emote') { 
        tell_object( $pl, parse_std_msg('Actions_Show_emote'));
        my @output = ();
        while ( my ($key,$value) = each %{ getsetup('Emote') } ) { 
            my $lin = $key . ' ';
            next unless $lin =~ m/$filter/i;
            push @output, $lin;
        }
        tell_object( $pl, sort @output );
        return 1;    
    }
    elsif ($what eq 'exit') { 
        tell_object( $pl, parse_std_msg('Actions_Show_exit'));
        my @output = ();
        while ( my ($key,$value) = each %{ $pl->environment->obvious_exits } ) { 
            my $lin = $key . ': ' .$value . "\n";
            next unless $lin =~ m/$filter/i;
            push @output, $lin;
        }
        tell_object( $pl, sort @output );
        return 1;    
    }
    elsif ($what eq 'clone') { 
        tell_object( $pl, parse_std_msg('Actions_Show_clone'));
        my $room = $pl->environment;
        my @output = ();
        for( my $i = 0; $i < scalar ( @{ $room->cloned_objects } ); $i++ ) {
            my $lin = $room->cloned_objects->[$i];
            next unless $lin =~ m/$filter/i;
            push  @output, $room->cloned_objects->[$i] ;
            push @output, " ( ", @{ $room->cloned_params->[$i] }, " )" ;
            push @output, " ; Unique:", $room->cloned_unique->[$i] ? "Yes" : "No" ;
            #push @output, "\n  Pointer:", $room->cloned_pointer->[$i] ;
            push @output, "\n  Keyname:", $room->cloned_keyname->[$i] ;
            push @output, "\n" ;
        }
        tell_object( $pl, @output );
        return 1;    
    }
    elsif ($what eq 'detail') { 
        tell_object( $pl, parse_std_msg('Actions_Show_detail'));
        my @output = ();
        while ( my ($key,$value) = each %{ $pl->environment->details } ) { 
            my $lin = $key . ': ' .$value . "\n";
            next unless $lin =~ m/$filter/i;
            push @output, $lin;
        }
        tell_object( $pl, sort @output );
        return 1;    
    }
    elsif ($what eq 'prop') { 
        tell_object( $pl, parse_std_msg('Actions_Show_properties'));
        my @output = ();
        while ( my ($key,$value) = each %{ $pl->environment->properties } ) { 
            my $lin = $key . ': ' .$value . "\n";
            next unless $lin =~ m/$filter/i;
            push @output, $lin;
        }
        tell_object( $pl, sort @output );
        return 1;    
    }
    elsif ($what eq 'callout') { 
        my @output = ();
        while ( my ($key,$value) = each %{ driver()->callouts() } ) { 
            my $lin = $key . '(' . time_to_str($key) . '): '
               . join(',',@{$value} )
               . "\n";
            next unless $lin =~ m/$filter/i;
            push @output, $lin;
        }
        tell_object( $pl, sort @output );
        return 1;    
    }
    elsif ($what eq 'conn') { 
        my @output = ();
        while ( my ($key,$value) = each %{ driver()->clients() } ) { 
            my $lin = $value->clientname . ', ' 
               . $value->peerhost . ': ' 
               . $value->name 
               . (exists driver()->user_names->{$value->name} ? '': ' (busy at logon)' )
               . "\n";
            next unless $lin =~ m/$filter/i;
            push @output, $lin;
        }
        tell_object( $pl, sort @output );
        return 1;    
    }
    elsif ($what eq 'recursive') { 
        $what = shift ;
        my $ob = find_object( effective_file_name($what)  );
        $ob = $pl->environment() unless ref($ob);
        my @accu = $ob->recursive_inventory() if ref($ob);
        my @output = ();
        foreach my $value ( @{accu} ) {
            my $lin = $value->name . ' - ' . $value . "\n";
            next unless ref($ob) && $lin =~ m/$filter/i;
            push @output, $lin;
        }
        tell_object( $pl, sort @output );
        return 1;    
    }
    else {

        unless ( $what ) { 
            notify_fail( parse_std_msg('Actions_Show_ko'));
            return -1; 
        }

        my $ob = find_object( effective_file_name($what) ) if $what;
        $ob = $pl->environment() if $what eq 'here';

        unless ( ref($ob) ) { 
            notify_fail( parse_std_msg('Actions_Show_notfound',$what));
            return -1; 
        }

        my @output = ();
        while ( my ($key,$value) = each %{ $ob } ) { 
            my $lin = $key . ' = ' . $value . ansi_clear() ;
            $lin .= " (" . time_to_str($value,'WW YYYY-MM-DD HH.MI.SS') . ")" if $value =~ m/^\d+$/ && $value > 1000000000;
            if (ref($value) eq 'ARRAY' ) {
                foreach my $elt ( @{$value} ) { 
                    $lin .= ref($elt) ? $elt->name : $elt;
                    $lin .= ' ';
                }
            }
            $lin .= ansi_clear();
            #$lin .= " [@{$value}]" . ansi_clear()  if ref($value) eq 'ARRAY';
            if ( ref($value) eq 'HASH' ) { while ( my ($hk,$hj) = each %{$value} ) { $lin .= " $hk=>$hj" } }
            next unless $lin =~ m/$filter/i;
            push @output, $lin . "\n" ;
        }
        if ( $filter eq 'prop' ) {
            $filter = shift || '.*';
            tell_object( $pl, parse_std_msg('Actions_Show_properties'));
            while ( my ($key,$value) = each %{ $ob->properties } ) { 
                my $lin = " " . $key . ': ' .$value . "\n";
                next unless $lin =~ m/$filter/i;
                push @output, $lin;
            }
        }
        tell_object( $pl, sort @output );
        return 1;    
    }    
}

sub navigate {
    
    my $cont = shift;
    my $n = shift || 0;
    my $pl = current_user();
    
    while ( my ($key,$value) = each %{$cont} ) { 

        tell_object( $pl, '  ' x $n,  "$key = $value", "\n" );
        if ( ref($value) ) { 
            if ( $key eq 'Actions' ) { 
                navigate ( $value, $n + 1 ) }
            if ( $key eq 'Inventory' ) { 
                navigate ( $value, $n + 1 ) }
            if ( $key eq 'ObviousExits' ) { 
                navigate ( $value, $n + 1 ) }
                if ( $key eq 'Snooper' ) { 
                navigate ( $value, $n + 1 ) }
            if ( $key =~ m'^User'  ) { 
                tell_object( $pl,' : ', $value->name, "\n" ); 
                #navigate( \%{$value}, $n+1 ) 
                };
        }
    }    
}
