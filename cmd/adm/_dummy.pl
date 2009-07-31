
sub cmd_dummy { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();
    
    tell_object($pl, "DUMMY!\n");
    while(1) { } # loop infinito: causa il crash del driver.

}
    
=pod

    sql_exec('select dummy from dual;');
    
}

=pod

    
    #my ($name,$passwd,$uid,$gid,$quota,$comment,$gcos,$dir,$shell) = getpw...
    #my ($name,$passwd,$gid,$members) = getgr...
    #my ($name,$aliases,$addrtype,$length,@addrs) = gethost...
    #my ($name,$aliases,$addrtype,$net) = getnet...
    #my ($name,$aliases,$proto) = getproto...
    #my ($name,$aliases,$port,$proto) = getserv...

       
    my ($sockfamily, $sockport, $sockaddr) = unpack('S n a4 x8',getsockname( $pl->client ));    
    print "peeraddr " . $pl->client->peeraddr . "\n";
    print "$sockfamily $sockport $sockaddr\n";

    my $hostinfo = Net::hostent::gethostbyaddr($sockaddr);
    my ($name,$aliases,$addrtype,$length,@addrs) = gethostbyaddr($sockaddr,$sockfamily); 
    print "hostinfo @$hostinfo\n";
    print "$name,$aliases,$addrtype,$length,@addrs\n";

}

=pod

    open( AFILE , 'help/color.txt' );
    my @accu = <AFILE>;
    my $startl = shift || 0;
    my $numl   = shift || scalar(@accu);
    my $msg;
    map {$_ = parse_color($_)} @accu;
    #$msg = wrap_string( @accu[ $startl .. $startl + $numl - 1 ] ) if $startl >= 0;
    #$msg = wrap_string( @accu[ $numl + $startl .. $numl - 1 ] ) if $startl < 0;
    #tell_object( $pl, $msg );
    
    # if $. >= $startl && ($numl == 0 || $. < $startl + $numl ) ;
    close( AFILE );

    return 1;

    my $res = 0;
    $res = eval q{ print 1 }; ##showexecerr( $res );
    
    return 1;


    map {$_ = parse_color($_)} @accu;
    my $pl      = shift;
    $pl = current_user() unless ref($pl) && $pl->isa('User');
    return "@_" unless ref($pl) && $pl->isa('User');
    #$Text::Wrap::columns = $pl->wrap_col;
    #my @ary = split( /\n/, "@tmp") ; #wrap( '','', "@_" ) );
    my @tmp = @_;
    my @ary = ();
    foreach my $elm ( @tmp ) {
        my $len = $pl->wrap_col;
        $len += 1 while $elm =~ ?\e\[\d{1}m? ;
        reset;
        $len += 2 while $elm =~ ?\e\[\d{2}m? ;
        
        $len--;
        $len-- while( $elm =~ /.{$len}\S/ ; );
        $len-- while( $elm =~ /.{$len}\s/ ; );
        while ( length($elm) > $len ) {
            push @ary, substr($elm,0,$len) ;
            $elm = substr($elm,$len) ;
        }
    }
    my $out = join( "\n", @ary );
    return $out;

    my @said = @_ ;
    
    for( my $i = 0; $i <= $#said; $i++ ) { 
        write_client( "$said[$i]\n" ); 
        while ( my ($key,$value) = each %{ $pl->char_decode() } ) { 
            $said[$i] =~ s/$key/$value/g;
        }
        
        write_client( "$said[$i]\n" ); 
    }
     
    return 1;

    write_client( call( time(),'WW YYYY-MM-DD HH.MI.SS D DDD YY YY' ) );


    return 1;
    
    my $x = shift;
    write_client( "$x " );
    write_client( ord($x) );
    #use utf8;
    #$x =~ tr/\x133\x138\x130\x141\x149\x151/aeeiou/;
    $x =~ tr/\x85\x8A\x82\x8D\x95\x97/aeeiou/;
    #$x =~ tr/àèéioù/aeeiou/;
    write_client( " $x" );
    
    return 1;

    foreach my $item (@{getsetup('Banish')}) {
        write_client( "$item " );
    }
    
    return 1;    

    #unless (@_) { notify_fail( "Usage: test cmd param");  return -1; }
    print"Here\n";

    $pl->set_property( 'prova', 'A', 3 ) ;
    tell_object( $pl, ' - ' . $pl->query_property( 'prova' ) );

    #call_out( 1, 'cmd/wiz/_dummy', 'dummy_test', 'A', 2 );
    call_out( 10, $me, 'dummy_test', 'A' );
    return 1;    

    cat( '../test.txt' );

    write_client( scalar localtime );
    return 1;    

    cx( '/rovina/ti.pl' )->goodbye;
    return 1;    


    my @ary =
    ( parse_color("{BLACK}##{BLUE}H{RED}e{GREEN}l{YELLOW}l{MAGENTA}o{CYAN}!{WHITE}## {RESET}")
    , parse_color("{BOLD}{BLACK}##{BLUE}H{RED}e{GREEN}l{YELLOW}l{MAGENTA}o{CYAN}!{WHITE}##\n{RESET}")
    #( "${BLACK}##${BLUE}H${RED}e${GREEN}l${YELLOW}l${MAGENTA}o${CYAN}!${WHITE}## $RESET"
    #, "${BOLD}${BLACK}##${BLUE}H${RED}e${GREEN}l${YELLOW}l${MAGENTA}o${CYAN}!${WHITE}##\n$RESET"
    );

    map $_ =~ s/\e\[..m//g, @ary;

    write_client( @ary );
    print number_to_string(7);

    return 1;    

    my $ary = { dummy => 
        [ "1234567890", "abcdefghij", "ABCDEFGHIJ" ],
        [ "1234567890", "abcdefghij", "ABCDEFGHIJ" ] 
        };
    
    my @sto = store_string( $ary );
    
    print "@sto\n";
    
    return 1;    

    do_command( @_ );
    
    print effective_file_name('./cross_north');
    print effective_file_name('area/skull');
    
    return 1;    

    my $skull = area::skull->nothing('A');
    print "skull: $skull\n";

    return 1;    

    
    #use Text::Wrap;
    
    my $t = "Text::Wrap::wrap() is a very simple paragraph formatter. It formats a single paragraph at a time by breaking lines at word boundries. Indentation is controlled for the first line ($initial_tab) and all subsquent lines ($subsequent_tab) independently. Please note: $initial_tab and $subsequent_tab are the literal strings that will be used: it is unlikley you would want to pass in a number.";
    
    $Text::Wrap::columns = 60;
    my @ary = split( /\n/, wrap( '','', $t ) );
    my $EOL = "\015\012";
    
    print "$t\n";
    print wrap( '','', $t ), "\n";
    print $#ary, "\n";
    print join( "$EOL" , @ary );
    
    return 1;    
    
    
    use strict;
    #use warnings;
    use diagnostics;
    use lib './std';
    use Commons;
    
    
    write_parsed( 'a','n','d');
    
    return 1;    
    
    print effective_file_name( './aviary' ), "\n";
    print basedirname('/pippo/pluto/ciao.txt'), "\n";
    print basefilename('/pippo/pluto/ciao.txt'), "\n";
    print baseextname('/pippo/pluto/ciao.txt'), "\n";
    
    return 1;    
    
    print parse_string( '$U\'s password', 'a', 'b' );
    
    return 1;    
    
    
    
    
    my ($obj,$member,$value) = ($1,$2,$3) if /^set\s*(\w+).(\w+)\s*=\s*(.*)$/ ;
    
    return 1;    
    
    my @list;
    my $c;
    my $n;
    print basename('ciao.123.att');
    
    return 1;    
    
    
    $n = sysread STDIN , $c, 1 ;
    print $n, ' ', $c, "\n";
    
    return 1;    
    
    my $var = "ciao\015come\012stai|?";
    print $var, "\n";
    $var =~ s/[\015\012]/-/g;
    print $var, "\n";


}

=cut


# ---------------------------------------------------------------------
sub dummy_test {
    my $pl     = current_user();
    #print"Here again @_\n";
    #my $zero = 0;
    tell_object( $pl,  ' - '.$pl->query_property( 'prova' ) );
    return 1;
}

sub call {
    my $tm = shift || time() ;
    my $fm = shift || 'YYYY-MM-DD HH.MI.SS' ;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime( $tm );
    my $centuryear = $year+1900;
    my $yy = $year; $yy -= 100 if $yy > 100; $yy = '0'.$yy if $yy < 10;
    $mon++; $mon = '0'.$mon if $mon < 10;
    my $weekday = ('Dom','Lun','Mar','Mer','Gio','Ven','Sab','Dom')[$wday];
    my $dt = $fm;
    $dt =~ s/YYYY/$centuryear/gi;
    $dt =~ s/YY/$yy/gi;
    $dt =~ s/MM/$mon/gi;
    $dt =~ s/DDD/$yday/gi;
    $dt =~ s/DD/$mday/gi;
    $dt =~ s/WW/$weekday/gi;
    $dt =~ s/D/$wday/gi;
    $dt =~ s/HH/$hour/gi;
    $dt =~ s/MI/$min/gi;
    $dt =~ s/SS/$sec/gi;
    print "$sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst\n";
    return $dt;
}

