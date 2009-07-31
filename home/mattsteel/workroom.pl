use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Workroom');
    $self->desc( "Workroom di Mattsteel" );

    $self->add_exit( 'terrazza', 'area/salazar/room/terrazza');
    $self->add_exit( 'orto', 'area/salazar/room/orto_5');
    $self->add_exit( 'daemon', 'std/room/daemon_room');
    $self->add_exit( 'shop', 'area/salazar/room/emporio');
    $self->add_exit( 'wild', 'area/salazar/room/porta_ovest');
    $self->add_exit( 'flo', '../flogisto/workroom');

    return $self;
}

sub do_look { 
    my $this   = shift;
    my $verb   = shift;
    my $what   = shift;
    
    my $pl     = current_user();
    
    tell_object ( $pl, "Passed: $this - $verb \n" );
    tell_object ( $pl,  current_user()->inputline, "\n" );
    
    return 1;
}

sub do_birds {
    my $pl     = current_user();
    tell_object ( $pl, "Birds called (@_).\n");
    #my $div = 1;
    #tell_object ( $pl, 1.0 / $div );
    return "birds examined";
}

