# children.pl
# Created Feb 2008
# Author  flogisto

use Mobile;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->name('bambini') 
         ->short('bambini') 
         ->shorts('bambini') 
         ->desc( "Un gruppo di bambini che si rincorrono tutto il tempo."
               ) 
         ->add_id('bambini') 
         ->message_in     ( '$n arrivano correndo.\n' ) 
         ->message_out    ( '$n corrono via verso $0.\n' ) 
         
         ->hit_points(10) 
         
         ->add_reply( 'bambino',"Uno dei bambini ti risponde: 'Bambino a chi?'" ) 
         
         ->chat_prob( 5 )  # %-probability
         ->add_chat( 'Uno dei bambini urla: "All\'attacco!"' )  
         ->add_chat( 'Uno dei bambini urla: "Ammazziamo i fammiiin!"' )  
         ->add_chat( 'Uno dei bambini urla: "Scappiamo!"' )  
         ->add_chat( 'Uno dei bambini urla: "Ritirata!"' )  
         ->add_chat( 'Uno dei bambini ti guarda, e scappa sogghignando.' )  
         ->add_chat( 'Uno dei bambini ti fa le boccacce.' )  
         ->add_chat( 'Uno dei bambini ti guarda impaurito.' )  
         ->add_chat( 'Uno dei bambini corre e ti urta per sbaglio.' )  
         
   #     ->wandering_prob( 15 )  # %-probability
   #       # areas
         ->trail_path( [ qw| e se se s s sw sw w w nw nw n n ne ne e 
                           b se se s s sw sw w w nw nw n n ne ne e e 
                           b se s s sw sw w w nw nw n n ne ne e e se 
                           a se se s s sw sw w w nw nw n n ne ne e e 
                           a | ] ) 
         ->trail_delay( 20 ) 
         ;

    return $self;
}

sub combat_miss        { [0,'Sfiorate $0'    ] } # Message to you
sub combat_miss_target { [0,'$0 ti sfiorano'  ] } # Message to target
sub combat_miss_others { [0,'$0 sfiorano $1'] } # Message to others
sub combat_miss_rea    { [0,'$0 ti guardano male'] } # Message to you, immediate effect
sub combat_miss_reatar { [0,'Guardate male $0'      ] } # Message to target, mmediate effect
sub combat_miss_reaoth { [0,'$0 gardano male $1'   ] } # Message to others, mmediate effect
sub combat_hit         { ['Colpite $0'  ] } # Message to you
sub combat_hit_target  { ['$0 ti colpiscono'  ] } # Message to target
sub combat_hit_others  { ['$0 colpiscono $1'] } # Message to others
sub combat_hit_rea     { ['$0 urlano contro di te'] } # Message to you, immediate effect
sub combat_hit_reatar  { ['Urlate $0'      ] } # Message to target, mmediate effect
sub combat_hit_reaoth  { ['$0 urlano contro $1'   ] } # Message to others, mmediate effect

sub death {
    my $this     = shift;
    my $class    = ref($this) || $this;
    my $attacker = shift || 0 ;
    $this->SUPER::death( $attacker ); 
    if ( ref( $this->corpse() ) ) {
        $this->corpse->short( $this->short() . ' morti' );
        $this->corpse->desc(  $this->desc() . ' morti' );
        $this->corpse->add_id( 'bambini' );
    }
}
    