use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Corpo di guardia') 
         ->desc( "Il corpo di guardia della porta Ovest. " .
                 "\n") 
    
         ->add_exit('nord', './porta_ovest') 
         ->set_property('guard')  

           

         ->add_object( '../mon/ronda_follower' )

         ->add_object( '../mon/ronda_leader' )
         ;
         
    return $self;
}

1;
