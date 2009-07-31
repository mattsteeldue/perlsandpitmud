use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Orto') 
         ->desc( "Il vialetto nel quale ti trovi " .
                 "corre intorno all'orto centrale e forma in questo punto " .
                 "un incrocio a tre vie. Quella verso sudovest passa attraverso " .
                 "ad una bella porta ogivale verso la zona residenziale." ) 
    
         ->add_exit('nord', './orto_4') 
         ->add_exit('est', './orto_8') 

         ->add_exit('sudovest', './bassi_s4') 

         ->add_wandering_area( 'orto' )  
         ->set_property('outdoor')
         ;

    return $self;
}
