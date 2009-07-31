use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('North Tower') 
         ->desc( "This is the north tower." .
                 "" ) 
         
         ->add_exit('north', './north_door') 
         ->add_exit('east', './aviary') 
         
         ->add_object( '../obj/skull')
         ;

    return $self;
}
               
sub test {
    print "Test called @_\n" ;
}
               
               
1;
