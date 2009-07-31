use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Torre Nord') 
         ->desc( "Stai percorrendo un sentiero vicino al torrente.\n" .
                 "Riesci a sentire lo scorrere impetuoso delle acque qui vicino." ) 
         
         ->add_exit('nord', './north_door') 
         ->add_exit('est', './aviary') 
         
         ->add_object( '../obj/skull')
         ;

    return $self;
}
               
sub test {
    print "Test called @_\n" ;
}
               
               
1;
