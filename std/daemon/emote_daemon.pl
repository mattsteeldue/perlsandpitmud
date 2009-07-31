# emote_daemon.pl
# Created May 2007
# Author  flogisto

use Daemon;

# ---------------------------------------------------------------------
use constant {
    USERNOARG => 0,
    ROOMNOARG => 1,
    USERFOUND => 2,
    ROOMFOUND => 3,
    TARGFOUND => 4,
    USERAUTO  => 5,
    ROOMAUTO  => 6,
    ADVERB    => 7,
    BODYPART  => 8,
    
};

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( 'emote_daemon' );
    bless $self, $class ;
    return $self;
}


# ---------------------------------------------------------------------
# do an emote verb.
sub do_emote { 
    my $me        = shift;
    my $verb      = shift;
    my $who       = shift || '';
    my $adverb    = shift || '';
    my $bodypart  = shift || '';
    my $this      = driver();
    my $pl        = current_user();
    my @except    = ($pl);
    my $ob        = 0 ;
    my $str;
    
    my ($yourselfm,$yourselff,$himself,$herself,$itself);

    # verb must be listed in emotes. Return silently if there is not such a verb
    return -1 if ( ! exists getsetup('Emote')->{$verb} );
    
    $who = lc($who);

    if ( $pl->ghost() ) {
        notify_fail( parse_std_msg('NotifyGhost') ) ;
        return -1;
    }

    # Search target user    
    if ( $who ) { 
        $ob = find_living( $who ) ;
        #print "0:who $who, ob $ob\n";
        $ob = 0 if ref($ob) && $pl->environment() != $ob->environment();
        if ( exists getsetup('Adverb')->{$who} ) {
            #print "1: who $who, adverb $adverb, bodypart $bodypart\n";
            $bodypart  = $adverb;
            $adverb = $who;
        }
        else {
            notify_fail( parse_std_msg('Actions_Emote_ko', ucfirst($who) ) );
            return -1 unless $ob; # wrong target
        }
    }

    # as a ghost you cannot interact with emote...
    #if ( $pl->ghost() ) {
    #    notify_fail( std_msg('NotifyGhost') ) ;
    #    return -1;
    #}

    if ( $ob ) {
        ($yourselfm,$yourselff,$himself,$herself,$itself) = (
            std_msg('yourselfm'),
            std_msg('yourselff'),
            std_msg('himself'),
            std_msg('herself'),
            std_msg('itself'),
        );
    }

    notify_fail( parse_std_msg('Actions_Emote_wrong', ucfirst($who) ) ) ;

    # adverb must be validated among a dataset.    
    if ( $adverb && exists getsetup('Adverb')->{$adverb} ) {
        $adverb = getsetup('Adverb')->{$adverb} || '';
    }
    else {
        $bodypart = $adverb;
        my $tmp = getsetup('Emote')->{$verb}->[ADVERB] ; 
        $adverb = getsetup('Adverb')->{$tmp} if $tmp && getsetup('Adverb')->{$tmp} ; 
    }

    # bodypart must be validated among a dataset.
    if ( $bodypart && exists getsetup('BodyPart')->{$bodypart} ) { #$this->bodyparts()->{$bodypart} ) {
        $bodypart = getsetup('BodyPart')->{$bodypart} #$this->bodyparts()->{$bodypart}
    }
    else {
        my $tmp = getsetup('Emote')->{$verb}->[BODYPART] ;
        $bodypart = getsetup('BodyPart')->{$tmp} #$this->bodyparts()->{$tmp} 
            if $tmp && exists getsetup('BodyPart')->{$tmp} #$this->bodyparts()->{$tmp}
    }
    
    # Auto
    if ( $who eq $pl->name ) {
        # UserAuto
        if ( getsetup('Emote')->{$verb}->[USERAUTO] ) {
            #print "4: who $who, adverb $adverb, bodypart $bodypart\n";
            $str = getsetup('Emote')->{$verb}->[USERAUTO] ;
            $pl->emote_adverb( $adverb );
            $pl->emote_where( $bodypart );
            $str = parse_string( $str );
            tell_object( $pl, "$str\n") ;
        }
        else { 
            return 0 
        }
        # RoomAuto
        if ( getsetup('Emote')->{$verb}->[ROOMAUTO] ) {
            #print "5: who $who, adverb $adverb, bodypart $bodypart\n";
            $str = getsetup('Emote')->{$verb}->[ROOMAUTO] ;
            $pl->emote_adverb( $adverb );
            $pl->emote_where( $bodypart );
            $str = parse_string( $str );
            say( ($pl->wizardhood?'::':'') ."$str\n", @except ) ;
        }
    }
    elsif ( $ob ) {
        push @except, $ob;
        # UserFound
        if ( getsetup('Emote')->{$verb}->[USERFOUND] ) {
            #print "6: who $who, adverb $adverb, bodypart $bodypart\n";
            $str = getsetup('Emote')->{$verb}->[USERFOUND] ;
            $pl->emote_target( $ob );
            $pl->emote_adverb( $adverb );
            $pl->emote_where( $bodypart );
            $str = parse_string( $str );
            tell_object( $pl, "$str\n") ;
        }
        else { 
            return 0 
        }
        # RoomFound
        if ( getsetup('Emote')->{$verb}->[ROOMFOUND] ) {
            #print "7: who $who, adverb $adverb, bodypart $bodypart\n";
            $str = getsetup('Emote')->{$verb}->[ROOMFOUND] ; 
            $pl->emote_target( $ob );
            $pl->emote_adverb( $adverb );
            $pl->emote_where( $bodypart );
            $str = parse_string( $str );
            say( ($pl->wizardhood?'::':'') ."$str\n", @except ) ;
        }
        # TargFound
        if ( getsetup('Emote')->{$verb}->[TARGFOUND] ) {
            #print "8: who $who, adverb $adverb, bodypart $bodypart\n";
            $str = getsetup('Emote')->{$verb}->[TARGFOUND] ;
            $pl->emote_target( $ob );
            $pl->emote_adverb( $adverb );
            $pl->emote_where( $bodypart );
            $str = parse_string( $str );
            tell_object( $ob, ($pl->wizardhood?'::':'') ."$str\n") ;
        }
    }
    else {
        # UserNoarg
        if ( getsetup('Emote')->{$verb}->[USERNOARG] ) {
            #print "9: who $who, adverb $adverb, bodypart $bodypart\n";
            $str = getsetup('Emote')->{$verb}->[USERNOARG] ;
            $pl->emote_adverb( $adverb );
            $pl->emote_where( $bodypart );
            $str = parse_string( $str );
            tell_object( $pl, "$str\n") ;
        }
        else { 
            return 0 
        }
        # RoomNoarg
        if ( getsetup('Emote')->{$verb}->[ROOMNOARG] ) {
            #print "A: who $who, adverb $adverb, bodypart $bodypart\n";
            $str = getsetup('Emote')->{$verb}->[ROOMNOARG] ;
            $pl->emote_adverb( $adverb );
            $pl->emote_where( $bodypart );
            $str = parse_string( $str );
            say( ($pl->wizardhood?'::':'') ."$str\n", @except ) ;
        }
    }
    
    $pl->emote_target( 0 );
    $pl->emote_adverb( 0 );
    $pl->emote_where ( 0 ); 

    return 1;    
}

