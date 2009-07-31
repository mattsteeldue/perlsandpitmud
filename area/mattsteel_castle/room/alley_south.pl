use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Viale meridionale') 
         ->desc( "Ti trovi su un viale che corre dinanzi al palazzo." ) 
         
         ->add_exit('nord', './building') 
   #     ->add_exit('sud', './south_door') 
         ;

    return $self;
}
               
1;
