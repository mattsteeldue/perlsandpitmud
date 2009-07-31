use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Terrazza - ovest') 
         ->desc( "Questo è l'ultimo livello della torre sull'arco " .
                 "Ovest." .
                 "Verso ovest c'è una scaletta che conduce alla terrazza occidentale della torre, " .
                 "dalla quale si può godere di uno stupendo panorama. " .
                 "Una rampa scende al livello inferiore verso nord. " . 
                 "\n" ) 
    
         ->add_exit('nord', './attico_w3') 
         ->add_exit('sud',  './attico_w1') 

         ->add_exit('ovest', './terrazza2') 
         ->add_exit('basso', './alti_w3') 

         ->add_detail(['vista','panorama'],
        "La vista è mozzafiato. Prova: 'panorama <direzione>" ) 

         ->add_detail('vista',
        "La vista è mozzafiato ma devi salire in cima alla terrazza per vedere meglio." ) 

         ->add_detail(['torre','citta','città','citta\'','cima','salazar'],
        "La città di Salazar è costruita all'interno di questa torre: " .
        "1200 braccia per cinquanta piani di case, botteghe, stalle." ) 

         ->set_property('outdoor')  
    
           
         ;

    return $self;
}
