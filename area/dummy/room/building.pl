use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('The palace') 
         ->desc( "You're in front to the palace. " .
                 "The door is open." ) 
         
         ->add_exit('north', './alley_north') 
         ->add_exit('south', './alley_south')
         ->add_exit('east', './emporio')
         
         ->add_object('../mon/ronda_follower')
         #->add_object('../mon/ronda_leader')
         ;

    return $self;
}
               
1;
