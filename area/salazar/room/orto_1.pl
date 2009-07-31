use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Giardini centrali') 
         ->desc( "Questa zona del giardino centrale è caratterizzata dalla " .
                 "presenza di alberi ad alto fusto. Il vialetto nel quale ti trovi " .
                 "corre intorno all'orto centrale e forma in questo punto " .
                 "un incrocio a tre vie. Quella verso nordovest si infila sotto " .
                 "un bell'arco seguito da una breve galleria." ) 
    
         ->add_exit('nordovest', './bassi_w4') 

         ->add_exit('est', './orto_2') 
         ->add_exit('sud', './orto_4') 

         ->add_wandering_area( 'orto' )  

         ->set_property('outdoor')
         ;

    return $self;
}


