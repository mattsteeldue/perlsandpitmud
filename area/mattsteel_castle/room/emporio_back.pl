use BackShop;

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new ( @_ ); 
    bless $self, $class;

    $self->short("Magazzino dell'emporio") 
         ->desc( "Questo è il retrobottega dell'emporio " .
                 "\n") 
    
         ->add_object( '../obj/spadalegno') 
         ->add_object( '../obj/pugnale') 
         ->add_object( '../obj/helmet') 
         ->add_object( '../obj/torch') 
         ->add_object( '../obj/sextant') 
         ;

    return $self;
}

1;
