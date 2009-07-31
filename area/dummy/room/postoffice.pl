use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Post Office') 
         ->desc( "This is the Post office. ".
                 "Here you can use the '{B}mail{/B}' command. " .   
                 "From here you can send and receive messages." .
                 "Try with'{B}help mail{/B}'. " .
                 "\n") 
    
         ->add_exit('west', './alley_north') 
         ->set_property('postoffice')  # this way works cmd/norm.

         ; 
         
    return $self;
}

1;
