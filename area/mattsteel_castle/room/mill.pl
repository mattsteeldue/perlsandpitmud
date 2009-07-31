use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Il mulino') 
         ->desc( "Sei dinanzi al mulino. La ruota gira spinta dall'acqua del torrente." ) 
         
         ->add_exit('alto', '../matt_6_5') 
         
         ->set_property('forest') 
         ->set_property('outdoor') 
         ;

    return $self;
}
               
1;
