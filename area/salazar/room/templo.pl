use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Templo') 
         ->desc( "Templo di Salazar. " .
        "Questo è il luogo ove '{B}pregare{/B}' Thenaar " .
        "di ritornare in vita dopo esser stati uccisi." .
        "\n") 
    
         ->add_exit('est', './attico_w3') 
         ->set_property('church')  

         ->add_action( 'prega','do_pray' ) 

         
         ; 
         
    return $self;
}

sub do_pray {
    my $this   = shift;
    my $what   = shift || '';
    my $pl     = current_user();

    if ( $pl->ghost ) {
        say( 'Il fantasma di ' . $pl->short . " sta pregando Thenaar di farlo ritornare in carne ed ossa.\n", $pl );    
    }
    else {
        say( $pl->short . " sta pregando Thenaar.\n", $pl );    
    }
}