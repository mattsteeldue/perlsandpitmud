use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('The Aviary')  
         ->desc( "This is a path near the aviary." ) 
         
         ->add_exit('west', './north_tower') 
         ->add_exit('east', './cross_north') 
         ->add_object('../mon/bird');
         ;

    return $self;
}
               
1;
