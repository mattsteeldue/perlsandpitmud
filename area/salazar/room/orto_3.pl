use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Orto') 
         ->desc( "Questa zona del giardino centrale è caratterizzata dalla " .
                 "presenza di cespugli e siepi basse. Il vialetto nel quale ti trovi " .
                 "corre lungo la parete e forma in questo punto " .
                 "un incrocio a tre vie. Quella verso nordest si infila sotto " .
                 "un bell'arco seguito da una breve galleria." ) 
    
         ->add_exit('nordest', './bassi_n4') 

         ->add_exit('ovest', './orto_2') 
         ->add_exit('sud', './orto_6') 

         ->add_wandering_area( 'orto' )  
         ->set_property('outdoor')
         ;

    return $self;
}
