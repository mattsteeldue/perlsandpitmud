use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Attico') 
         ->desc( "Questo è l'ultimo livello della torre sull'arco " .
                 "Sud. " .
                 "Verso sud c'è una scaletta che conduce alla terrazza meridionale della torre, " .
                 "dalla quale si può godere di uno stupendo panorama. " .
                 "Una rampa scende al livello inferiore verso ovest. " . 
                 "Intarsiata sul pavimento vedi la mappa dell'intera torre: " .
                 "la puoi esaminare con '{B}exa mappa{/B}'.\n" .
                 "\n" ) 
    
         ->add_detail('vista',
        "La vista è mozzafiato ma devi salire in cima alla terrazza per vedere meglio." ) 

         ->add_detail(['pavimento','selce'],
        "è una pavimento in selce con inscisa la mappa della città." ) 
         ->add_detail(['mappa','pianta','map'], \&do_mappa ) 
    
         ->add_exit('ovest', './attico_s3') 
         ->add_exit('est',   './attico_s1') 

         ->add_exit('sud', './terrazza3') 
         ->add_exit('basso', './alti_s3') 

         ->add_wandering_area( 'bird' ) 

         ->set_property('indoor')  
         ;

    return $self;
}

# chiamato in modalita' examine: deve restituire una stringa.
sub do_mappa {
    my $this   = shift;
    my $what   = shift || '';
    my $pl     = current_user();
  
    if ( $what eq '' ) {
        cat_wrap( basedirname( $this->module ) . "/../mappa.txt" );
        tell_object( $pl, "\n");
        say( $pl->short . " esamina la mappa incisa sul pavimento.\n", $pl );    
        return "\n";
    }

    unless ($what =~ m/^([abmtr])/i ) {
        ###print "... $what\n";
        tell_object( $pl, "Devi usare solo A, B, M, R, T\n" );
        return "\n"; 
    }
    $what = $1;
    my $file = basedirname( $this->module ) . lc("/../mappa$what.txt");
    cat( $file );
    say( $pl->short . " esamina la mappa incisa sul pavimento.\n", $pl );    
    return "\n";
}

