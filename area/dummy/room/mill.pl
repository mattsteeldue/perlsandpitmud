use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('The mill') 
         ->desc( "You stand in front of the mill . The wheel turns driven by the torrent." ) 
         
         ->add_exit('up', '../dummy_6_5') 
         
         ->set_property('forest') 
         ->set_property('outdoor') 
         ;

    return $self;
}
               
1;
