use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('North Alley')
         ->desc( "This is the alley in front the palace " .
                 "which door is some step more south. " .
                 "To the east there is the Post Office.")
         
         ->add_exit('north', './cross_north')
         ->add_exit('south', './building')
         ->add_exit('east', './postoffice')
         ;
         
    return $self;
}
               
1;
