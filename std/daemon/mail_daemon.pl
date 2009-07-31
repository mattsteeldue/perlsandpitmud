# mail_daemon.pl
# Created Feb 2007
# Author  flogisto

# ---------------------------------------------------------------------
use Daemon;

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( 'mail_daemon' );
    bless $self, $class ;

    my $dbh = dbi();
    my $sth = $dbh->table_info( '', '', 'engine_mailbox' );
    if ( ! $dbh->err && ! $sth->fetch() ) {
        $dbh->do( qq[ 
            create table engine_mailbox (
            username  char(64) not null,
            id_row    integer  not null,
            sender    char(64),
            recipient char(64),
            subject   char(256),
            header    char(256),
            datesend  integer,
            mailread  char(1),
            mailbody  blob,
            primary key (username, id_row) ) 
                    ] );
    }
    return $self;
}

# ---------------------------------------------------------------------
sub mail_list {
    my $me     = shift;
    my $pl     = current_user();
    my $name   = shift || $pl->name();
    my $dbh = dbi();
    my $sth = $dbh->prepare( qq| select * from engine_mailbox where username=?| );
    $sth->execute( $name );
    my @outp = ();
    my $row;
    my $fmt = parse_std_msg('Actions_Mail_listfmt')."\n";
    unless ( $dbh->err ) {
        $row = $sth->fetchrow_hashref();
        unless ( $row ) {
            tell_object( $pl, parse_std_msg('Actions_Mail_empty') 
                            . parse_std_msg('Actions_Mail_help') );
            return 1;
        }
        while ( $row ) {
            push @outp, 
                sprintf( $fmt, 
                ($row->{mailread} ? ' ' : '*' ),
                $row->{id_row}, $row->{sender}, $row->{subject}, $row->{datesend}
                ) ;
            $row = $sth->fetchrow_hashref();
        }
        push @outp, parse_std_msg('Actions_Mail_help');
        tell_object( $pl, @outp );
    }
    return 1;
}

# ---------------------------------------------------------------------
sub mail_read {
    my $me     = shift;
    my $pl     = current_user();
    my $who    = $pl->name;
    my $i      = shift || return 0;
    my $del    = shift || ' ';
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq| select * from engine_mailbox where username=? and id_row=?| );
    $sth->execute( $who, $i );
    my @outp = ();
    my $row = {};
    my $fmt = parse_std_msg('Actions_Mail_listfmt')."\n";
    unless ( $dbh->err ) {
        if ( $row = $sth->fetchrow_hashref() ) {
            push @outp, "-" x $pl->wrap_col, "\n";
            push @outp, parse_std_msg('Actions_Mail_From',$row->{sender});
            push @outp, parse_std_msg('Actions_Mail_Subject',$row->{subject});
            push @outp, parse_std_msg('Actions_Mail_Cc', $row->{header});
            push @outp, parse_std_msg('Actions_Mail_Date', $row->{datesend});
            push @outp, $row->{mailbody};
            push @outp, "\n";
            write_client(@outp);
            $sth = $dbh->prepare( 
            qq| update engine_mailbox set mailread=1 where username=? and id_row=?| );
            $sth->execute( $who, $i );
        }
        else {
            return 0;
        }
    }
    if ( $del =~ /del/i ) {
        write_client( parse_std_msg('Actions_Mail_askdelete',std_msg('yes'),std_msg('no')) );
        $pl->custom('MailDeleting', $i) ;
        $pl->input_to('mail_ask_delete');
        return 1;
    }
    # reply to this message
    if ( $del =~ /r/i ) {
        $who = lc($row->{sender}); 
        my $cl_who   = username_to_client( $who );
        my $pl_who   = client_to_user( $cl_who );
        write_client( "\n" );
        write_client( "\n" );
        write_client( parse_std_msg('Actions_Mail_username' ,ucfirst($who) ) );
        write_client( parse_std_msg('Actions_Mail_Subject', $row->{subject} ) ) ;  # prompt
        $pl->custom('MailAddressee', $who);
        $pl->custom('MailSubject', $row->{subject} ); 
        $pl->custom('MailSubject', "R: " . $pl->custom('MailSubject') ) unless $pl->custom('MailSubject') =~ /^R:/i;
        write_client( "(".$pl->custom('MailSubject').")"  ) ;  # prompt
        $pl->input_to('mail_subject');
    }
    return 1;
}

# ---------------------------------------------------------------------
# referenced from mail_read via input_to('mail_ask_delete')
sub mail_ask_delete {
    my $pl     = current_user();
    my $reply  = wipe_bs( "@_" );
    my $i      =  $pl->custom('MailDeleting') ;
    my $match    = std_msg('yes');
    if ( $reply =~ m/^\s*$match\s*/i ) {
        daemon('mail')->mail_delete( $i ) ;
    }
    return 1
}

# ---------------------------------------------------------------------
sub mail_delete {
    my $me     = shift;
    my $k      = shift || return 0;
    my $pl     = current_user();
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq| select max(id_row) from engine_mailbox where username=? | );
    $sth->execute( $pl->name );
    my $row  = $sth->fetch();
    my $num = 0;
    $num += $row->[0] if defined $row && defined $row->[0];
    $sth = $dbh->prepare( 
        qq| delete from engine_mailbox where username=? and id_row=? | );
    $sth->execute( $pl->name, $k );
    $sth = $dbh->prepare( 
        qq| update engine_mailbox set id_row=id_row-1
             where username=? and id_row=? | );
    for( my $i = 1; $i <= $num; $i++ ) {
       $sth->execute( $pl->name, $i ); 
    }
    write_client( parse_std_msg('Actions_Mail_deleted',$k) ."\n" );
    return 1;
}

# ---------------------------------------------------------------------
# starts the mail writing: called by command _mail
sub mail_init {
    my $me     = shift;
    my $pl     = current_user();
    $pl->input_to('mail_subject');    
    return 1;    
}

# ---------------------------------------------------------------------
# mail writing chain from mail_init or mail_read
sub mail_subject {
    my $pl       = current_user();
    $pl->custom('MailSubject', "@_") if ( length("@_") > 0 );
    write_client( parse_std_msg('Actions_Mail_Cc_list') ); # prompt
    $pl->input_to('mail_carboncopy');
    return 1;    
}

# ---------------------------------------------------------------------
# mail writing chain from mail_subject
sub mail_carboncopy {
    my $pl       = current_user();
    $pl->custom('MailCarboncopy', "@_" );
    $pl->custom('MailLines', [ ] );
    write_client( parse_std_msg('Actions_Mail_input') );
    $pl->input_to('mail_line');
    return 1;    
}

# ---------------------------------------------------------------------
# mail writing chain from mail_carboncopy or mail_line
sub mail_line {
    my $pl       = current_user();
    my $line = "@_";
    if ( $line eq '.' || scalar @{$pl->custom('MailLines')} >= driver()->maxmaillines ) {
        my $who = $pl->custom('MailAddressee') ;
        write_client( "-" x $pl->wrap_col, "\n" );
        write_client( parse_std_msg('Actions_Mail_Mail_To',ucfirst($who) ) );
        write_client( parse_std_msg('Actions_Mail_Subject', $pl->custom('MailSubject') ) );
        write_client( parse_std_msg('Actions_Mail_Cc','' ) );
        foreach my $addressee ( split /\s+/, $pl->custom('MailCarboncopy') ) {
            write_client( " " . ucfirst($addressee) );
        }
        write_client( "\n" );
        foreach $line ( @{$pl->custom('MailLines')} ) {
            write_client( $line, "\n" );
        } 
        write_client( "-" x $pl->wrap_col, "\n" );
        write_client( "\n" );
        write_client( parse_std_msg('Actions_Mail_asktosend',std_msg('yes'),std_msg('no')) );
        $pl->input_to('mail_ask_send');
    }
    else {    
        $pl->custom('MailLines')->[ scalar @{$pl->custom('MailLines')} ] = $line ;
        $pl->input_to('mail_line') ;
    }
    return 1;    
}

# ---------------------------------------------------------------------
# mail writing chain from mail_line
sub mail_ask_send {
    my $pl     = current_user();
    my $reply  = wipe_bs( "@_" );
    my $match  = std_msg('yes');
    $pl->status('Ok'); # important!
    if ( $reply =~ m/^\s*$match\s*/i ) {
        $pl->custom('MailTimestamp', time_to_str( time(), "YYYY-MM-DD HH.mi.ss" ) );
        mail_send_mail( $pl->custom('MailAddressee') ) ;
        foreach my $addressee ( split /\s+/, $pl->custom('MailCarboncopy') ) {
            next unless ( user_exists(lc($addressee)) ) ; 
            mail_send_mail( $addressee ) ;
        }
    }
    return 1
}

# ---------------------------------------------------------------------
# mail writing end of chain
sub mail_send_mail {
    my $pl     = current_user();
    my $who    = shift || return 0;
    my $ob     = find_object( $who );
    daemon('mail')->send_mail(
        $who,
        $pl->cap_name,
        $pl->custom('MailSubject'),
        $pl->custom('MailCarboncopy'),
        $pl->custom('MailTimestamp'),
        $pl->custom('MailLines')
        );
    tell_object( $ob, parse_std_msg('YouHaveNewMail',$ob->cap_name) ) if $ob ;
    return 1;
}

# ---------------------------------------------------------------------
# send mail method
sub send_mail {
    my $me     = shift;
    my $who    = shift || return 0;
    my $from = shift ;
    my $subj = shift ;
    my $cc = shift ;
    my $tm = shift ;
    my $ln = shift;
    my $dbh = dbi();
    my $sth = $dbh->prepare( 
        qq| select max(id_row) from engine_mailbox where username=? | );
    $sth->execute( $who );
    my $row  = $sth->fetch() || [0];
    my $num = 1;
    $num += $row->[0] if defined $row && defined $row->[0];
    my $text = join( "\n", @{$ln} ); 
    $sth = $dbh->prepare( 
        qq| insert into engine_mailbox values ( ?, ?, ?, ?, ?, ?, ?, ?, ? ) | );
    $sth->execute( $who, $num, $from, $who, $subj, $cc, $tm, 0, $text  );
    return 1;
}

