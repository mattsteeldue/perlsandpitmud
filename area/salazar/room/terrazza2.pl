use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;
    
    $self->short('Terrazza Occidentale') 
         ->desc( "Questa è la terrazza occidentale posta sulla sommità della torre della città " .
                 "di Salazar. " .
                 "Altre due terrazze sono situate " .
                 "lungo l'arco delle mura a nord e a sud. " .
                 "Intarsiata sul pavimento vedi la mappa dell'intera torre: " .
                 "la puoi esaminare con '{B}exa mappa{/B}'.\n" .
                 "Una porta consente di scendere al piano di sotto. " .
                 "Da qui la vista è mozzafiato.\n" .
                 "Prova: '{B}panorama <direzione>{/B}'.\n" ) 

         ->add_detail('porta',
        "Conduce attraverso una scala ai piani inferiori." ) 
         ->add_detail('scala',
        "Oltre la porta, conduce ai piani inferiori." ) 
         ->add_detail(['terrazza','altana'],
        "Questa è una terrazza altana in cima alla torre  " .
        "non è l'unica e ne vedi altre non molto distanti sulla sommità " .
        "di altre guglie della torre adiacenti a quella ove ti trovi. " .
        "La vista è mozzafiato. " .
        "Prova: 'panorama <direzione>" ) 
         ->add_detail(['torre','citta','città','salazar','cima'],
        "La città di Salazar è costruita all'interno di questa torre: " .
        "1200 braccia per cinquanta piani di case, botteghe, stalle." ) 
         ->add_detail('arco',
        "La torre è suddivisa in tre " .
        "gruppi di piani collegati da rampe che corrono lungo l'arco." ) 
         ->add_detail(['vista','panorama'],
        "La vista è mozzafiato. Prova: 'panorama <direzione>" ) 
         ->add_detail(['pavimento','selce'],
        "è una pavimento in selce." ) 

         ->add_detail(['mappa','pianta','map'], \&do_mappa ) 
    
         ->add_action( 'panorama','do_look' ) 
    
         ->add_exit('est', './attico_w2') 
    
         ->set_property('outdoor')  
    
         ->add_wandering_area( 'bird' )
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

# chiamato in modalita' command
sub do_look { 
    my $this   = shift;
    my $verb   = shift; # panorama
    my $what   = shift;
    my $pl     = current_user();
    
    #my $dh = getsetup('HourPerGameDay'    ); 
    #my $h = daemon('time')->globalhour();  
    #my $b = 1;
    #$b = 0 if $h > $dh * 3/4;
    #$b = 0 if $h < $dh * 1/4;
    $b = daemon('time')->query_daylight();  

    my %panorama = (
      
        est => 
        "Verso Est riesci a vedere in un colpo d'occhio l'intera " .
        "forma cilindrica della torre di Salazar. " .
        "Spicca la cupola del templo qui sotto. " .
        ( $b ? "In lontananza vedi la sagoma nera della Rocca del Tiranno." : 
               "Anche se non si vede, la sagoma nera della Rocca del Tiranno incombe in lontananza") 
        ,
        sud =>
        "Salazar è l'ultima città-torre prima della foresta che " . 
        "segna il confine con la Terra delle Rocce. " .
        "Verso sud, il bosco si estende a perdita d'occhio. " 
        ,
        ovest =>
        "Verso Ovest un corso d'acqua si allontana sinuoso dalla città costeggiando la " .
        "Foresta della Terra del Vento perdendosi oltre l'orizzonte. " 
        ,
        nord =>
        "Verso nord c'è una sterminata prateria che si estende fin oltre l'orizzonte."
        ,
        basso =>
        "Da dove ti trovi, vedi i lussureggianti giardini centrali della torre. " .
        "Alberi d'alto fusto ma anche zone erbose e colture. " .
        "Li puoi visitare scendendo di qualche livello." 
        ,
        alto =>
        "Guardi il cielo. è " . ( $b ? 'giorno' : 'notte') . '.'
        );
    
    if ( exists $panorama{$what} ) {
        say( $pl->short . " guarda il panorama verso $what\n", $pl );  
        tell_object( $pl, wrap_string( $panorama{$what} ) . "\n" );
        return 1;
    }
    else {
        notify_fail('Devi dare "panorama <direzione>". Es. panorama nord');
        return 0;
    }
}


