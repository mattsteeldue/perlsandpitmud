# startup.pl
# Created Aug 2006
# Author  flogisto
# This is the STARTUP room

use Room;

# this function is called from Commons using an 
# eval { $room->startup( @param ) } if ref($room); 
sub startup {
    my $this  = shift;
    my $class = ref($this) || $this;
    my @param = @_;
    my $pl = current_user();
    my $result;
    my $step;

    #write_client( "A:step: ", $pl->step );
    #write_client( " param: @param \n" );
    
    $step = $pl->step;
    $result = eval qq{ startup_step$step( \@param ) };
    
    #write_client( "B:step: ", $pl->step );
    #write_client( " param: @param - result $result.\n" );

    $pl->step( 1 + $pl->step ) if $result;
    
    $step = $pl->step;
    eval qq{ display_step$step() };
    
    return 1;
}

sub epilog {
    my $pl = current_user();
    $pl->status('Ok');
    
    if ( $pl->level() == 0 ) {
        $pl->level( 1 ) ; # new user
        $pl->initial_room( driver()->initial_room() );
        $pl->desc( $pl->cap_name() );

        my $subj = parse_std_msg('StartupWelcome', $pl->cap_name() ) ;
        my $cc = '';
        my $tm = time_to_str( time(), "YYYY-MM-DD HH.mi.ss" );
        my $ln = std_msg('StartupLines');
        daemon('mail')->send_mail( $pl->name, 
            std_msg('StartupSender'), $subj, $cc, $tm, $ln );
    }
        
    daemon('channel')->startup_setup();
    $pl->move( $pl->initial_room() ); 
    daemon('patch','do_patch');
    save_user( $pl );
    $pl->display_startup_info() ;
    #$pl->force_to( 'look' ) ;
    #$pl->force_to( 'channel' ) ;
}

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->short('Welcome Room.');
    $self->desc( "This is the welcome room.");
    $self->add_action( "look", "do_look" );
    $self->add_action( "test", "test_startup" );

    #$self->add_exit('sud', 'std/room/scuola_01');
    $self->add_exit('alto', 'area/salazar/room/terrazza');
    
    return $self;
}

sub do_look{
    my $pl = current_user();
    if ( $pl->wizardhood() ) { 
        tell_object( $pl, "***Stanza di inizio: puoi effettuare un 'test'***.\n" 
                        . "***Attenzione: questo altera razza, genere, terra.***.\n" ); 
    }
    else {
        tell_object( $pl, "***Questo e` un posto vietato ai mortali.***\n" ); 
    }
    return 0;
}

sub test_startup {
    my $pl = current_user();
    return -1 unless ref($pl) && $pl->isa('User') && $pl->wizardhood();    
    my @outp = ();
    push @outp, ( "Attuali dati: " );
    push @outp, ( $pl->race, ", ", $pl->gender, ", ", $pl->land, "\n" );
    push @outp, ( "Simulazione startup... <premi invio>\n" );
    write_client( @outp );
    $pl->status('Start');
    return 1;
}

# Welcome
sub startup_step0 { 
    my $capn = current_user()->cap_name();
    my @outp = ();
    push @outp, ( "\n" );
    push @outp, ( "Ti do il benvenuto, $capn!\n\n");
    push @outp, ( "Ora e` necessario definire le caratteristiche del\n" );
    push @outp, ( "tuo nuovo personaggio rispondendo ad poche semplici domande.\n" );
    push @outp, ( "Al termine, ti verra` presentato un riepilogo delle risposte\n");
    push @outp, ( "che hai dato, e dovrai dare un'ultima conferma.\n");
    write_client( @outp );
    return 1;
}

# Ansi colour question
sub display_step1 { 
    my $pl   = current_user();
    my $capn = $pl->cap_name();
    my @outp = ();
    $pl->ansi_color( 1 );
    push @outp, ( "\n" );
    push @outp, ( parse_color("Riesci a vedere i colori di questa parola: " .
                  "{Red}co{Yellow}lo{Green}ra{Blue}ta{NORMAL}?.\n" ) );
    push @outp, ( "   si` o no (".std_msg('yes')."/".std_msg('no').") ?\n");
    push @outp, ( "> ");
    write_client( @outp );
}

# Ansi reply
sub startup_step1 { 
    return 0 unless (@_);
    my $reply = $_[0] ;
    my $pl = current_user();
    my $ok = 0;
    my $match    = std_msg('yes');
    if ( $reply =~ m/^\s*$match\s*/i ) {
        $pl->ansi_color( 1 );
        $ok = 1;
    }
    else {
        $pl->ansi_color( 0 );
        $ok = 1;
    }
    return $ok;
}

# Disclaimer question
sub display_step2 { 
    my $capn = current_user()->cap_name();
    my @outp = ();
    cat_wrap( getdir('dirdoc') . 'disclaimer.txt' );
    write_parsed( "   {B}Accetti le regole di questo MUD? (" . 
        std_msg('yes') . "/" . std_msg('no') . ") {/B}\n> ");
    write_client( @outp );
}

# Disclaimer reply
sub startup_step2 { 
    return 0 unless (@_);
    my $reply = $_[0] ;
    my $pl = current_user();
    my $ok = 0;
    my $match    = std_msg('yes');
    if ( $reply =~ m/^\s*$match\s*/i ) {
        $ok = 1;
    }
    else {
        quit_client( $pl->client );
        $ok = 0;
    }
    return $ok;
}

# Race question
sub display_step3 { 
    my $capn = current_user()->cap_name();
    my $this = driver();
    my @race = @{getsetup('RaceList')} ;
    my @outp = ();
    push @outp, ( "\n" );
    push @outp, ( "A quale razza appartiene il nuovo personaggio $capn?\n");
    push @outp, ( parse_color(
                  "    Puoi scrivere '{B}aiuto <nome>{/B}' per avere una breve descrizione.\n" ));
    push @outp, ( "    Per decidere la razza digita solo il nome o solo il numero.\n" );

    for( my $i = 0; $i <= $#race; $i++ ) {
        push @outp, ( $i+1, ") " , sprintf( "%-15s", $race[$i] ) ) ;
        push @outp, ( "\n" ) if 2 == $i % 3 ; 
    }

    push @outp, ( "\n" ) if 2 != $#race % 3;
    push @outp, ( "> ");
    write_client( @outp );
} 

# Race reply
sub startup_step3 { 
    return 0 unless (@_);
    my $reply = $_[0] ;
    my $pl = current_user();
    my $this = driver();
    my @race = @{getsetup('RaceList')} ;
    my $ok = 0;
    my $help = 0;
    my $dir = getdir('dirdochelp');
    my $voce = 0;
    my $g = $pl->gender();
    my $m = std_msg( 'Male' ) ; 
    my $f = std_msg( 'Female' ) ; 
    
    if ( $reply =~ m/^\s*AIUTO|HELP/i ) { $help = 1; $reply = $_[1] ||''; }
    $reply = lc($reply);
    
    my $i = pos_array( @race, ucfirst($reply) ) ;
    $i = $reply-1 if $reply =~ m/\d/ && $reply >= 1 && $reply <= $#race + 1 ;
    $voce = lc($race[$i]) if $i >= 0 ;
    
    if ( $help && $voce ) {
        $pl->force_to( "help $voce" );
    }
    elsif ( $voce ) {
        $pl->race( ucfirst($voce) );
        if ( $voce eq 'ninfe' ) { 
            $pl->step( 1 + $pl->step ) ;
            startup_step4($f);
        }
        $ok = 1;
    }
    return $ok;
} 

# Gender question
sub display_step4 { 
    my $capn = current_user()->cap_name();
    my @outp = ();
    push @outp, ( "\n" );
    push @outp, ( "Bene $capn. Ora e` necessario decidere il genere del personaggio\n");
    push @outp, ( "   maschile o femminile (M/F) ?\n");
    push @outp, ( "> ");
    write_client( @outp );
}

# Gender reply
sub startup_step4 { 
    return 0 unless (@_);
    my $reply = $_[0] ;
    my $pl = current_user();
    my $this = driver();
    my @race = @{getsetup('RaceList')} ;
    my @raceM = @{getsetup('RaceListM')} ;
    my @raceF = @{getsetup('RaceListF')} ;
    my $ok = 0;
    if ( $reply =~ m/^\s*M/i ) {
        $pl->gender( std_msg('Male') ) ; 
        my $i = pos_array( @race, $pl->race );
        $pl->race( $raceM[$i] );
        $ok = 1;
    }
    elsif ( $reply =~ m/^\s*F/i ) {
        $pl->gender( std_msg('Female') ) ; 
        my $i = pos_array( @race, $pl->race );
        $pl->race( $raceF[$i] );
        $ok = 1;
    }
    return $ok;
}

# Land question
sub display_step5 { 
    my $pl   = current_user();
    my $capn = $pl->cap_name();
    my $racn = $pl->race();
    my $this = driver();
    my @land = @{getsetup('LandL')} ; # Long desc
    my @outp = ();
    push @outp, ( "\n" );
    push @outp, ( "$racn $capn, ora devi dichiarare da quale Terra provieni? \n");
    push @outp, ( parse_color(
                  "  Puoi scrivere '{B}aiuto terre{/B}' per un'introduzione alle terre\n" ));
    push @outp, ( parse_color(
                  "  oppure '{B}aiuto <terra>{/B}' per avere una breve descrizione.\n"));
    push @outp, ( "  Per decidere la terra digita solo il nome o solo il numero.\n" );

    for( my $i = 0; $i <= $#land; $i++ ) {
        push @outp, ( $i, ") " , sprintf( "%-20s", $land[$i] ) );
        push @outp, ( "\n" ) if 2 == $i % 3 ;
    }

    push @outp, ( "\n" ) if 2 != $#land % 3 ;
    push @outp, ( "> ");
    write_client( @outp );
}

# Land reply
sub startup_step5 { 
    return 0 unless (@_);
    my $reply = $_[0] ;
    my $pl = current_user();
    my $this = driver();
    my @landl = @{getsetup('LandL')} ; # Long desc
    my @land = @{getsetup('Land')} ;   # keyword
    my $ok = 0;
    my $help = 0;
    my $dir = getdir('dirdochelp');
    my $voce = '';

    if ( $reply =~ m/^\s*AIUTO|HELP/i ) { $help = 1; $reply = $_[1] ||''; }
    if ( $reply =~ m/^\s*TERRE/i ) { $voce  = 'terre'; }
    $reply = lc($reply);
    
    my $i = pos_array( @land, "$reply" ) ;
    $i = $reply if $reply =~ m/\d/ && $reply >= 0 && $reply <= $#land ;
    $voce = lc($land[$i]) if $i >= 0 ;
    
    if ( $help && $voce ne '' ) {
        $pl->force_to( "help $voce" );
    }
    elsif ( $voce ne '' ) {
        $i = pos_array( @land, "$voce" ) ;
        $pl->land( $landl[$i] ) if $i > -1 ;
        $ok = 1 if $i > -1 ;
    }
    return $ok;
} 

# Confirm question
sub display_step6 { 
    my $pl   = current_user();
    my $capn = $pl->cap_name();
    my $racn = $pl->race();
    my $land = $pl->land();
    my @outp = ();
    push @outp, ( "\n" );
    push @outp, ( "Stai per entrare nel Mondo emerso con il seguente personaggio:\n" );
    push @outp, ( "$racn $capn della $land.\n") unless $land =~ /zanelia/i;
    push @outp, ( "$racn $capn di $land.\n")    if $land =~ /zanelia/i;
    push @outp, ( "\n" );
    push @outp, ( "Nome:    ", $pl->cap_name(), "\n" );
    push @outp, ( "Razza:   ", $pl->race(), "\n");
    push @outp, ( "Genere:  ", $pl->gender(), "\n");
    push @outp, ( "Terra:   ", $pl->land(), "\n");
    push @outp, ( "\n" );
    push @outp, ( "Tutto OK? (".std_msg('yes')."/".std_msg('no').") ?\n");
    push @outp, ( "> ");
    write_client( @outp );
}

# Confirm reply
sub startup_step6 { 
    return 0 unless (@_);
    my $reply = $_[0] ;
    my $pl = current_user();
    my $ok = 0;
    $ok = 1 if ( $reply =~ m/^\s*S/i );
    $pl->step( 1 ) unless $ok;
    return $ok;
} 

sub display_step7 { 
    my $pl   = current_user();
    my $capn = $pl->cap_name();
    my $racn = $pl->race();
    my $land = $pl->land();
    my @outp = ();
    push @outp, ( "\n" );
    push @outp, ( "\n" );
    push @outp, ( parse_string('Eccoti giunt$o nel Mondo Emerso, '));
    push @outp, ( "$racn $capn della $land.") unless $land eq 'zanelia';
    push @outp, ( "$racn $capn di $land.") if $land eq 'zanelia';
    push @outp, ( "\n" );
    push @outp, ( "\n" );
    write_client( @outp );
    epilog();
}

# ---

sub startup_step7 { 
    return 0 unless (@_);
    my $reply = $_[0] ;
    my $pl = current_user();
    my $ok = 0;
    return 0;
} 

