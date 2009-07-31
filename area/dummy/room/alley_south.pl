use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Alley South') 
         ->desc( "You are on the alley near the palace." ) 
         
         ->add_exit('north', './building') 
   #     ->add_exit('sud', './south_door') 
         ;

    return $self;
}
               
1;
