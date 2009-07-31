use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Il palazzo') 
         ->desc( "Ti trovi su un viale che dinanzi al palazzo." .
                 "La porta è aperta." ) 
         
         ->add_exit('nord', './alley_north') 
         ->add_exit('sud', './alley_south')
         ->add_exit('est', './emporio')
         
         #->add_object('../mon/ronda_follower')
         #->add_object('../mon/ronda_leader')
         ;

    return $self;
}
               
1;
