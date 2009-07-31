=pod

Uso: ed <filename> 

=cut

sub pagesize { 5 };

# ---------------------------------------------------------------------
sub cmd_ed { 
    my $me     = shift;
    my $verb   = shift;
    my $file   = clean_root(shift);
    my $pl     = current_user();
    my $pwd    = $pl->custom('CurrentWorkDirectory') || '/home/'.$pl->name;
    $pwd = clean_root($pwd);

    unless( $file ) {
        notify_fail( parse_std_msg('Actions_Ed_ko') );
        return -1;
    }

    $file = "$pwd/$file" unless( -f $file ) ;
    
    unless( basedepth($file) > 0 ) {
        notify_fail( parse_std_msg('Actions_Ed_illegal', $file) );
        return -1;
    }

    my @ary = () ;
    if( -f $file ) {
        @ary = cat_array($file);
        tell_object( $pl, parse_std_msg('Actions_Ed_old',$file) );
    }
    else {
        tell_object( $pl, parse_std_msg('Actions_Ed_new',$file) );
    }
    $pl->custom('Edfilename',$file);
    $pl->custom('Edarray', \@ary );
    $pl->custom('Edpage',0);
    
    cmd_ed_help();
    cmd_ed_list( 0 );
    cmd_ed_prompt();
    return 1;
}

# ---------------------------------------------------------------------
sub main_ed { 
    my $line     = wipe_bs(shift);
    my @param    = split( /\s/, $line );
    my $pl       = current_user();
    my $file     = $pl->custom('Edfilename');
    my $i = 0;
    $i++ while( $param[$i] =~ /^\d+$/ );
    my $cmd = $param[$i] ;
    my %switch = (
        "h" => \&cmd_ed_help,      # help
        "q" => \&cmd_ed_quit,      # quit
        "s" => \&cmd_ed_save,      # save
        "l" => \&cmd_ed_list,      # list
        "n" => \&cmd_ed_next,      # next
        "b" => \&cmd_ed_previous,  # back 
        "p" => \&cmd_ed_put,       # put row
        "i" => \&cmd_ed_insert,    # insert row
       );
    
    my $status = 0;
    $status = $switch{$cmd}->(@param) if defined $switch{$cmd} ;  
    unless ($status) {
        cmd_ed_prompt();
    }
}

# ---------------------------------------------------------------------
sub cmd_ed_prompt { 
    my $pl       = current_user();
    $pl->input_to('main_ed');
    tell_object( $pl, "* " ); # prompt
}
    
# ---------------------------------------------------------------------
sub cmd_ed_help { 
    my $pl = current_user();
    tell_object( $pl, 
        "-----------------------\n" 
    .   "h  help.               \n" 
    .   "q  quit without saving.\n"
    .   "s  save and backup.    \n"
    .   "l  list       1 l      \n"
    .   "n  next page           \n"
    .   "b  previous            \n"
    .   "p  put line   9 p      \n"
    .   "i  insert     9 i      \n"
    .   "-----------------------\n" 
    );
    return 0;
}

# ---------------------------------------------------------------------
sub cmd_ed_quit { 
    my $pl = current_user();
    $pl->input_to( 0 );
    $pl->custom('Edfilename','');
    $pl->custom('Edarray', [] );
    $pl->custom('Edpage',0);
    return -1; # to force exit from cmd_main using $status <> 0
}

# ---------------------------------------------------------------------
sub cmd_ed_save { 
    my $pl = current_user();
    my $filename = $pl->custom('Edfilename');
    my $ary      = $pl->custom('Edarray'); 
    rename_file( $filename, "$filename.bak" );
    append_file( $filename, join( "\n", @$ary ) );
    cmd_ed_quit(); #?
    return -1;
}

# ---------------------------------------------------------------------
sub cmd_ed_list {
    my $pl = current_user();
    my $page = (@_)>1 ? $_[0] : ($pl->custom('Edpage')||0) ;
    my $ary = $pl->custom('Edarray');
    $pl->custom('Edpage',$page);
    my @ary = ();
    foreach my $i ( $page*pagesize() .. $page*pagesize()+9 ) { 
        next unless defined $ary->[$i];
        push @ary, sprintf( "%4d: %s\n", $i, $ary->[$i] ) ;
    } 
    tell_object( $pl, @ary);
    return 0;
}

# ---------------------------------------------------------------------
sub cmd_ed_next {
    my $pl = current_user();
    my $page = (@_)>1 ? $_[0] : ($pl->custom('Edpage')||0) ;
    my $ary = $pl->custom('Edarray');
    if ( $#$ary > ($page+1) * pagesize() ) {
        $pl->custom('Edpage',$page + 1) 
    }
    cmd_ed_list();
    return 0;
}

# ---------------------------------------------------------------------
sub cmd_ed_previous {
    my $pl = current_user();
    my $page = (@_)>1 ? $_[0] : ($pl->custom('Edpage')||0) ;
    $pl->custom('Edpage',$page - 1) if $page > 0;
    cmd_ed_list();
    return 0;
}

# ---------------------------------------------------------------------
sub cmd_ed_put {
    my $linenum = 0;
    my $verb = shift ;
    ($linenum,$verb) = ($verb,shift) if $verb =~ /^\d+/ ;
    my $pl = current_user();
    my $text = $pl->inputline();
    $text = $1 if $text =~ /$verb\s(.*)$/ ;
    push @{$pl->custom('Edarray')}, $text unless $linenum;
    $pl->custom('Edarray')->[$linenum] = $text if $linenum >= 0 && $linenum <= scalar(@{$pl->custom('Edarray')});
    return 0;
}

# ---------------------------------------------------------------------
sub cmd_ed_insert {
    print "insert @_\n";
    my $pl = current_user();
    return 0;
}
