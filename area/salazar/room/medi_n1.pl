use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Livello mediano') 
         ->desc( "Questo è il livello mediano della torre sull'arco " .
                 "Nord.\n" ) 
    
         ->add_exit('sudovest', './medi_w4') 
         ->add_exit('est',      './medi_n2') 
         ->add_exit('nord',  './armoury') 
    
         ->add_object( '../obj/skull') 
         ->add_object( '../obj/torch') 

         
         ; 
         
    return $self;
}

1;
