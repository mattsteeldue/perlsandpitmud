use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Workroom')
         ->desc( "Workroom di Flogisto" )
         
         ->add_detail( 'terrazza','è una bella terrazza.' ) 
         ->add_detail( 'birds', \&do_birds ) 
         ->add_action( 'panorama','do_look' ) 
         
         ->add_exit( 'terrazza', 'area/salazar/room/terrazza','$n va sulla terrazza') 
         ->add_exit( 'orto', 'area/salazar/room/orto_5') 
         ->add_exit( 'daemon', 'std/room/daemon_room') 
         ->add_exit( 'shop', 'area/salazar/room/emporio') 
         ->add_exit( 'wild', 'area/salazar/room/porta_ovest') 
         
   #     ->add_object( 'area/salazar/mon/bird') 
   #     ->add_object( 'area/salazar/obj/helmet') 
         ->add_object( 'clonable/dinar', 13 ) 
         ->add_object( './dummy' ) 
         
         ->add_object( './book' ) 
         
         ->add_object( './helmet' ) 
         ->add_object( './shield' )  
         ->add_object( './gloves' ) 
         ->add_object( './boots' ) 
         ->add_object( './cloak' ) 
         ->add_object( './armour' ) 
         
         ->add_object( './sword' ) 
         
         ->add_wandering_area( 'bird' ) 
         ;

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

