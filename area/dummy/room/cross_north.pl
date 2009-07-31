use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Crossing') 
         ->desc( "To the sout there is an alley." ) 
         
         ->add_exit('west',  './aviary') 
         ->add_exit('south', './alley_north')
         ;

    return $self;
}
               
1;
