use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Incrocio') 
         ->desc( "Sei all'incrocio con un viale che passa davanti al palazzo." ) 
         
         ->add_exit('ovest',  './aviary') 
         ->add_exit('sud', './alley_north')
         ;

    return $self;
}
               
1;
