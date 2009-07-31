use Object;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; # __FILE__ );
    bless $self, $class;

    $self->short('Teschio') 
         ->shorts('Teschi') 
         ->desc( 'Un teschio sporco e viscido.') 
   #     ->add_action( "look", "look_the_void" ) 
         ;
    return $self;
}

sub test() {
    ###print( "test called\n" );
    tell_object( current_user(), "test called\n");
    return 8;
}


#sub look_the_void {
#    return 0 unless 
#    tell_object( current_user(), "You look at the void... \n" );
#}
#

1;
