# channel_daemon.pl
# Created Jan 2007
# Author  flogisto

# ---------------------------------------------------------------------
use Daemon;

# ---------------------------------------------------------------------
my @chanlist;
my @chandesc;
my @chanwiz;
my @chanadmin;
my @chanlength;

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( 'channel_daemon' );
    bless $self, $class ;

    my $dbh = dbi();
    my $sth = $dbh->table_info( '', '', 'engine_channel_subscriber' );
    if ( ! $dbh->err && ! $sth->fetch() ) {
        $dbh->do( qq[ 
            create table engine_channel_subscriber (
            channel char(64) not null,
            member  char(64) not null,
            primary key (channel, member) ) 
                    ] );
        # begin migration
        ##my $db = arc_open( '_channel_subscribers' ); # pro migration
        ##$sth = $dbh->prepare( qq[ insert into engine_channel_subscriber values ( ?, ? ) ]);
        ##foreach my $elm ( keys %$db ) {
        ##    my $row = $db->{$elm};
        ##    $sth->execute( $row->{channel}, $row->{member} );
        ##}
        ##$sth->finish();
        # end migration
    }
    $sth = $dbh->table_info( '', '', 'engine_channel_buffer' );
    if ( ! $dbh->err && ! $sth->fetch() ) {
        $dbh->do( qq[ 
            create table engine_channel_buffer (
            channel char(64) not null,
            id_row  integer not null,
            text    char(1024),
            primary key (channel, id_row) ) 
                    ] );
    }
        
    @chanlist   = @{ getsetup('ChannelList'  ) }; 
    @chandesc   = @{ getsetup('ChannelDesc'  ) }; 
    @chanwiz    = @{ getsetup('ChannelWizard') }; 
    @chanadmin  = @{ getsetup('ChannelAdmin' ) }; 
    @chanlength = @{ getsetup('ChannelLength') }; 
    
    return $self;
}

# ---------------------------------------------------------------------
sub load_subscribers{ 
    my $me       = shift;
}

# ---------------------------------------------------------------------
# called at first set-up from startup room to set-up channels.
sub startup_setup {
    my $me     = shift;
    my $class = ref($me) || $me;
    my $pl = current_user();
    $pl->alias->{ 'off' } = "channel off" ;
    $pl->alias->{ 'tag' } = "channel tag" ;
    $pl->alias->{ 'rpg' } = "channel rpg" ;
    $pl->color('ColorChannel_off','green');
    $pl->color('ColorChannel_rpg','Yellow');
    $pl->color('ColorChannel_tag','Green');
    $me->channel_on('off', 1); 
    $me->channel_on('tag', 1); 
    $me->channel_on('rpg', 1); 
    $pl->stand_prompt( '[' . $pl->cap_name . '] $ ' );
    #$pl->display_startup_info() ;
}

# ---------------------------------------------------------------------
# command "channel" handler. parses the arguments following the command
# and dispatches to the correctu function
sub cmd_channel { 
    my $me     = shift;
    my $verb   = shift;
    my $chan   = shift || 0;
    my $param  = $_[0] || 0;
    my $pl     = current_user();
    my $color  = '';
    
    unless( $chan ) {
        my @outp = ();
        push @outp, parse_std_msg('Actions_Channel_avail', $verb ) ;
        my $k = 0;
        for( my $i = 0; $i <= $#chanlist; $i++ ) { 
            next if $chanwiz[$i] && ! $pl->wizardhood ;
            next if $chanadmin[$i] && ! $pl->wizardhood ;
            $color = $pl->color("ColorChannel_$chanlist[$i]") || '';
            $color = parse_color("{$color}") if $color;
            push @outp, "$color".
                sprintf( "%-5s %-30s", $chanlist[$i], $chandesc[$i] )
                ;
            push @outp, "\n" if $k % 2 ;
            $k++;
        }
        push @outp, "\n";
        tell_object( $pl, @outp );
        return 1;
    }

    if ( -1 == pos_array( @chanlist, $chan ) ) {
        notify_fail( parse_std_msg('Actions_Channel_no', $chan ) );
        return 0;
    }
    
    return $me->channel_on( $chan )        if $param eq '/on' ;
    return $me->channel_off( $chan )       if $param eq '/off' ;
    return $me->channel_rev( $chan )       if $param eq '/rev' ;
    return $me->channel_users( $chan, @_ ) if $param eq '/users' ;
    return $me->channel_color( $chan, $_[1] ) if $param eq '/color' ;
    
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ select * from engine_channel_subscriber where channel=? and member=? ]) ;
    $sth->execute( $chan, $pl->name );
    if ( ! $dbh->err && ! $sth->fetch() ) {
        notify_fail( parse_std_msg('Actions_Channel_noconn', $verb, $chan ) );
        $sth->finish();
        return 0;
    }
    $sth->finish();

    return $me->channel_text( $chan, @_ ) if scalar( @_ );
    notify_fail( parse_std_msg('Actions_Channel_help', $verb, $chan ) );
    return 0 ;
}

# ---------------------------------------------------------------------
sub channel_users{ 
    my $me     = shift;
    my $chan   = shift || return 0;
    my $pl = current_user();
    ###my @users = (); @{ $channel->{$chan} }  ;
    my $sth = dbi()->prepare( 
        qq[ select member from engine_channel_subscriber where channel = ? ]);
    $sth->execute( $chan );
    my @users = @{ $sth->fetchall_arrayref };
    my $color = $pl->color("ColorChannel_$chan") || '';
    $color = parse_color("{$color}") if $color;
    my @outp = ();
    push @outp, "${color}". parse_std_msg('Actions_Channel_users', $chan) . ansi_clear() . ":" ;
    foreach my $name ( @users) {
        next unless find_user($name->[0]); 
        push @outp, " ".$name->[0] ;
    }
    push @outp, "\n";
    tell_object( $pl, @outp ) ;
}
# ---------------------------------------------------------------------
sub channel_notify{ 
    my $me     = shift;
    my $chan   = shift || return 0;
    my $user;
    my $pl = current_user();
    my $color ;
    my $sth = dbi()->prepare( 
        qq[ select member from engine_channel_subscriber where channel = ?  ]);
    $sth->execute( $chan );
    my @users = @{ $sth->fetchall_arrayref };
    foreach my $name ( @users) {
        $user = find_user($name->[0]);
        next unless $user && ref($user) && $user->isa('User');
        $color = $user->color("ColorChannel_$chan") || '';
        $color = parse_color("{$color}") if $color;
        tell_object( $user, "$color@_\n" ) 
    }
}

# ---------------------------------------------------------------------
sub channel_on {
    my $me     = shift;
    my $chan   = shift || return 0;
    my $silent = shift || 0;
    my $pl     = current_user();
    my $member = $pl->name;
    my $color = $pl->color("ColorChannel_$chan") || '';
    $color = parse_color("{$color}") if $color;
    $pl->channel_switch("Channels_$chan", 1) ;
    ###if ( -1 == pos_array( @{ $channel->{$chan} }, $member ) ) {
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ select * from engine_channel_subscriber where channel=? and member=? ]) ;
    $sth->execute( $chan, $member );
    if ( ! $dbh->err && ! $sth->fetch() ) {
        tell_object( $pl, $color.parse_std_msg('Actions_Channel_on1',$chan ) ) ;
        $me->channel_notify( $chan, parse_std_msg('Actions_Channel_on',$pl->cap_name,$chan )) unless $silent;
        $sth = $dbh->prepare( qq[ insert into engine_channel_subscriber values (?,?) ]) ;
        $sth->execute( $chan, $member );
    }
    else {
        tell_object( $pl, $color.parse_std_msg('Actions_Channel_on2',$chan ) ) ;
    }
    return 1;
}

# ---------------------------------------------------------------------
sub channel_off {
    my $me     = shift;
    my $chan   = shift || return 0;
    my $pl     = current_user();
    my $member = $pl->name;
    my $color = $pl->color("ColorChannel_$chan") || '';
    $color = parse_color("{$color}") if $color;
    $pl->channel_switch("Channels_$chan", 0) ;
    ###unless ( -1 == pos_array( @{ $channel->{$chan} }, $member ) ) {
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ select * from engine_channel_subscriber where channel=? and member=? ]) ;
    $sth->execute( $chan, $member );
    if ( ! $dbh->err && $sth->fetch() ) {
        tell_object( $pl, $color.parse_std_msg('Actions_Channel_off1',$chan ) ) ;
        $sth = $dbh->prepare( 
            qq[ delete from engine_channel_subscriber where channel=? and member=? ]) ;
        $sth->execute( $chan, $member );
        $me->channel_notify( $chan, parse_std_msg('Actions_Channel_off',$pl->cap_name,$chan ));
    }
    else {
        tell_object( $pl, $color.parse_std_msg('Actions_Channel_off2',$chan ) ) ;
    }
    $sth->finish();
    return 1;
}

# ---------------------------------------------------------------------
sub channel_off_all {
    my $me       = shift;
    my $username = shift || return 0;

    my $dbh = dbi();
    my $sth = $dbh->prepare( qq[ delete from engine_channel_subscriber where member=? ]) ;
    $sth->execute( $username );
    $sth->finish();
    
    return 1;
}

# ---------------------------------------------------------------------
sub channel_color {
    my $me     = shift;
    my $chan   = shift || return 0;
    my $color  = shift || '';
    my $pl     = current_user();

    $color = $pl->color("ColorChannel_$chan") if $color eq '' ;

    # check color keyword
    unless ( $color =~ m/^Black$|^Blue$|^Red$|^Magenta$|^Green$|^Cyan$|^Yellow$|^White$|
                         ^black$|^blue$|^red$|^magenta$|^green$|^cyan$|^yellow$|^white$|
                         ^default$/ ) {
      notify_fail( parse_std_msg('Actions_Channel_colorko', $color ));
      return -1;
    }
    $color = getsetup('ColorChannel') if $color eq 'default';
    
    $pl->color("ColorChannel_$chan",$color) ; # keep keyword
    if ( $color ) {
        my $ansicolor = parse_color("{$color}") ;
        tell_object( $pl, "${ansicolor}" . parse_std_msg('Actions_Channel_color', $chan) . "\n" )
    }
    
    return 1;
}

# ---------------------------------------------------------------------
sub channel_rev {
    my $me     = shift;
    my $chan   = shift || return 0;
    my $pl     = current_user();
    my $color = $pl->color("ColorChannel_$chan") || '';
    my @ary = ();
    ##my $filename = getdir('dirdbsqlite') . "_channel_${chan}.txt";
    ##@ary = cat_array( $filename, - getsetup('ChannelMaxBuf')) if -f $filename;
    ##return 1 unless (scalar @ary );
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ select * from engine_channel_buffer where channel=? order by id_row ]) ;
    $sth->execute( $chan );
    $color = parse_color("{$color}") if $color;
    my @outp = ();
    unless ( $dbh->err ) {
        while ( my $row = $sth->fetchrow_hashref() ) {
            push @outp, $color .$row->{text} . "\n" ;
        }
        tell_object( $pl, @outp );
    }
    return 1;
}

# ---------------------------------------------------------------------
sub channel_text{ 
    my $me     = shift;
    my $chan   = shift || return 0;
    my $pl     = current_user();
    my $msg    = "[$chan " .
                 time_to_str( time(), 'DD/MM HH.MI' ) . 
                 "] ". $pl->cap_name .": @_";
    log_file( "_channel_${chan}.log", "@_" );
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq[ select * from engine_channel_subscriber where channel=? and member=? ]) ;
    $sth->execute( $chan , $pl->name );
    if ( ! $dbh->err && ! $sth->fetch() ) {
        $me->channel_on( $chan ) ;
    }
    $me->channel_notify( $chan, $msg );

    my $i = pos_array( @chanlist, $chan );
    $sth = $dbh->prepare( 
        qq[ select max(id_row) from engine_channel_buffer where channel=? ]) ;
    $sth->execute( $chan );
    my $row  = $sth->fetch();
    my $num = 0;
    $num += 1+$row->[0] if defined $row && defined $row->[0];
    $sth = $dbh->prepare( 
        qq[ insert into engine_channel_buffer values ( ?, ? ,? ) ]) ;
    $sth->execute( $chan, $num, $msg );
    my $limit = $chanlength[ $i ]||1000 ;
    $num -= $limit;
    $sth = $dbh->prepare( 
        qq[ delete from engine_channel_buffer where channel=? and id_row<? ] ) ;
    $sth->execute( $chan, $num );
    $sth->finish();
    return 1;
}
