use Shop;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->short('Emporio') 
         ->desc( "Questo è l'emporio del castello, " .
                 "con un assortimento di tutto rispetto. " .
                 "C'è un cartello con le indicazioni su come fare per acquistare o vendere oggetti. " .
                 "A lato, c'è un bidone della spazzatura dove buttare tutto quello che non ti serve più. " .
                 "\n") 

         ->add_detail('emporio',
        "Ci sei proprio." ) 
         ->add_detail( ['assortimento','oggetti'] , \&do_sign ) 
         ->trash_can->add_id('cestino') 

         ->add_exit('ovest',     './building') 
         
         ;

    return $self;
}

