use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('La voliera')  
         ->desc( "Sei un sentiero vicino alla voliera" ) 
         
         ->add_exit('ovest', './north_tower') 
         ->add_exit('est', './cross_north') 
         ->add_object('../mon/bird');
         ;

    return $self;
}
               
1;
