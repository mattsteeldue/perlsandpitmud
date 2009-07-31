=pod

Uso: set object.member[.submember] = <value>
     set object.member[.submember]?
Consente di modificare il valore di un qualunque membro o sottomembro appartenente ad un personaggio, mob o oggetto disponibile.
Oppure visualizza il valore senza modificarlo. 

=cut

# ---------------------------------------------------------------------
sub cmd_set { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = 0;
    my $obj;
    my $member;
    my $submember;
    my $value = 0;
    my $pl    = current_user();
    my $ope   = 0;
    my $arg;

    if ( $pl->inputline =~ /^set\s*([\w\/]+\#?\d*)\.(\w+)\.(\w+)\s*=\s*(.*)$/ ) {
        ($what,$member,$submember,$value) = ($1,$2,$3,$4) ;
        $ope = 1;
        #tell_object( $pl, "Found 1 $what $member $submember $value \n");
    }
    elsif ( $pl->inputline =~ /^set\s*([\w\/]+\#?\d*)\.(\w+)\s*=\s*(.*)$/ ) {
        ($what,$member,$value) = ($1,$2,$3) ;
        $ope = 1;
        #tell_object( $pl, "Found 2 $what $member $value \n");
    }
    elsif ( $pl->inputline =~ /^set\s*(\w+\#?\d*)\s*=\s*(.*)$/ ) {
        ($member,$value) = ($1,$2) ;
        $ope = 1;
        #tell_object( $pl, "Found 3 $member $value \n");
    }
    elsif ( $pl->inputline =~ /^set\s*([\w\/]+\#?\d*)\.(\w+)\.(\w+)\s*\?/ ) {
        ($what,$member,$submember) = ($1,$2,$3) ;
        #tell_object( $pl, "Found 4 $what $member $submember \n");
    }
    elsif ( $pl->inputline =~ /^set\s*([\w\/]+\#?\d*)\.(\w+)\s*\?/ ) {
        ($what,$member) = ($1,$2) ;
        #tell_object( $pl, "Found 5 $what $member \n");
    }
    elsif ( $pl->inputline =~ /^set\s*(\w+\#?\d*)\s*\?/ ) {
        ($member) = ($1) ;
        #tell_object( $pl, "Found 6 $member \n");
    }
    else { 
        notify_fail( parse_std_msg('Actions_Set_ko'));
        return -1; 
    }

    if ( $what ) {
        $obj = find_object( $what );
        if( $obj ) {
            #tell_object( $pl, "Found $obj $member $value\n");
            if ($submember) {
                if ( exists($obj->{"$member"}) && exists($obj->{"$member"}->{"$submember"}) ) { 
                    if ( $ope ) {
                        $obj->{"$member"}->{"$submember"} = "$value" ;
                        #tell_object( $pl, "Changed $what.$member.$submember=$value\n" ) ;
                        tell_object( $pl, parse_std_msg('Actions_Set_ok', "$what.$member.$submember","$value" ));
                    }
                    else {
                        # display
                        tell_object( $pl, "$what.$member.$submember: " . 
                                 $obj->{"$member"}->{"$submember"} . "\n" ) ;
                        print_array( $pl, $obj->{"$member"}->{"$submember"} ) if ref($obj->{"$member"}->{"$submember"}) =~ m/ARRAY/;
                    }
                                
                }
                else {
                    if( exists($obj->{"$member"}) ) { 
                        tell_object( $pl, parse_std_msg('Actions_Set_notfound',"$what.$member.$submember" ));
                    }
                    else {
                        tell_object( $pl, parse_std_msg('Actions_Set_notfound',"$what.$member" ));
                    }
                }
            }
            else {
                if ( exists($obj->{"$member"}) ) { 
                    if ( $ope ) {
                        $obj->{"$member"} = "$value" ;
                        tell_object( $pl, parse_std_msg('Actions_Set_ok',"$what.$member","$value" ) ) ;
                    }
                    else {
                        tell_object( $pl, "$what.$member: ".
                                     $obj->{"$member"} . "\n" );
                        print_array( $pl, $obj->{"$member"} ) if ref($obj->{"$member"}) =~ m/ARRAY/;
                    }                 
                }
                else {
                    tell_object( $pl, parse_std_msg('Actions_Set_notfound',"$member" ));
                } 
            }
        }
        else {
            tell_object( $pl, parse_std_msg('Actions_Set_notfound',"$what..." ) );
        }
    }
    else {
        #tell_object( $pl, "here ($ope)\n" );
        if ( $ope ) {
            tell_object( $pl, "Too dangerous.\n" );
            #driver()->{"$member"} = "$value" ;
            #tell_object( $pl, parse_std_msg('Actions_Set_ok',"Muddrv.$member","$value" )) ;
        }
        else {
            tell_object( $pl, driver()->{"$member"} ) ;
            print_array( $pl, driver()->{"$member"} ) if ref(driver()->{"$member"}) =~ m/ARRAY/;
        }
    }

    return 1;
}

sub print_array {
    my $pl = shift;
    foreach my $elt ( @_ ) {
        tell_object( $pl, "$elt " ) ;
    }
    tell_object( $pl, "\n" ) ;
}
