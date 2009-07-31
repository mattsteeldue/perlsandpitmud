use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('The northern door') 
         ->desc( "You are beneath a mighty arch called 'The Northern Door'.\n" .
                 "This is the northern entryway to the castle.") 
         
   #     ->add_exit('north', './out_north') 
         ->add_exit('north', '../matt_6_5') 
         ->add_exit('south', './north_tower') 
         
         ->add_action( 'touch','do_touch' ) 
         ;
    
    return $self;
}

# ---------------------------------------------------------------------
# this is a test.
sub do_touch { 
    my $this   = shift;
    my $verb   = shift;
    my $what   = shift;
    my $line   = current_user()->inputline;

    write_debug( -1, $line );
    current_user()->force_to('look'); 
    return 1;
}
              
1;
