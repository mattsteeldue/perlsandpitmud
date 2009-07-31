use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Daemon Room');
    $self->desc( "Questo posto ospita tutti i demoni. Se wizard puoi usare 'reload' " );
    
    $self->add_action( 'reload','do_bomb' );

    $self->add_object( 'std/daemon/none_daemon' );
    $self->add_object( 'std/daemon/room_desc_daemon' );
    $self->add_object( 'std/daemon/move_dir_daemon' );
    $self->add_object( 'std/daemon/time_daemon' );
    $self->add_object( 'std/daemon/channel_daemon' );
    $self->add_object( 'std/daemon/mail_daemon' );
    $self->add_object( 'std/daemon/emote_daemon' );
    $self->add_object( 'std/daemon/patch_daemon' );
    $self->add_object( 'std/daemon/stock_daemon' );
    $self->add_object( 'std/daemon/actions_daemon' );
    $self->add_object( 'std/daemon/combat_daemon' );
    $self->add_object( 'std/daemon/death_daemon' );
    $self->add_object( 'std/daemon/level_daemon' );
    $self->add_object( 'std/daemon/hazards_daemon' );

    $self->add_object( 'std/obj/death_course' );

    return $self;
}

sub do_bomb {
    my $this   = shift;
    my $verb   = shift; 
    my $what   = shift;
    my $pl     = current_user();
    
    return 0 unless $pl->wizardhood();

    for( my $i = 0; $i < scalar ( @{ $this->cloned_objects } ); $i++ ) {
        my $ob = find_object( $this->cloned_objects->[$i] ) ;  
        #print $this->cloned_objects->[$i], "\n";
        next unless ref($ob);
        #print $ob->name, "\n";    
        #$ob->environment( the_void() );
        $ob->destroy();  
        my $oldwarn = $SIG{__WARN__};
        $SIG{__WARN__} = sub { };
        load_module( $this->cloned_objects->[$i], 1 );
        $SIG{__WARN__}  = $oldwarn;
        $ob = clone_object( $this->cloned_objects->[$i] );
        #$ob->environment( $this );
    }
    
    tell_object( $pl, "Daemons reloaded.\n" );
    return 1;
}
