use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('La porta Nord') 
         ->desc( "Ti trovi sotto un arco chiamato 'Porta Nord'.\n" .
                 "Si tratta dell'ingresso settentrionale al castello.") 
         
   #     ->add_exit('nord', './out_north') 
         ->add_exit('nord', '../matt_6_5') 
         ->add_exit('sud', './north_tower') 
         
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
