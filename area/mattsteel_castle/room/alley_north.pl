use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Viale settentrionale')
         ->desc( "Ti trovi su un viale che dinanzi al palazzo " .
                 "la cui entrata si trova un po' più a sud. " .
                 "Ad est vedi l'insegna dell'Ufficio Postale. ")
         
         ->add_exit('nord', './cross_north')
         ->add_exit('sud', './building')
         ->add_exit('est', './postoffice')
         ;
         
    return $self;
}
               
1;
