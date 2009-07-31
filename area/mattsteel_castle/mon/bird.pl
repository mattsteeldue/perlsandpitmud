# bird.pl
# Created Aug 2006
# Author  flogisto

use Mobile;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->name('passerotto') 
         ->short('un passerotto') 
         ->shorts('passerotti') 
         ->desc( 'Un passerotto.') 
         ->descs( 'Dei passerotti.') 
         ->add_id( 'passero', 'uccello' ) 
         
         ->message_out( '$n vola via verso $0.\n' ) 
         ->message_in( '$n arriva svolazzando.\n' ) 
         
         ->set_property('unique') 
         
         ->hit_points(10) 
         
         ->add_reply( 'ciao',"Passerotto risponde: 'ciao'" ) 
         
         ->chat_prob( 5 ) 
         ->add_chat( "Passerotto cinguetta allegramente." ) 
         ->add_chat( "Passerotto si liscia le piume." ) 
         ->add_chat( "Passerotto becchetta qua e là." ) 
         ->add_chat( "Passerotto si spaventa e vola via da te." ) 
         ->add_chat( "Passerotto si avvicina incuriosito." ) 
         ->add_chat( "Passerotto si avvicina incuriosito." ) 
         
         ->wandering_prob( 5 )  # %-probability
         ->add_wandering_area( 'bird' )  # areas
         
   #     ->trail_path( [ 'basso','alto','basso','alto' ] ) 
   #     ->trail_delay( 60 ) 
         ;
    
    return $self;
}

sub armed_with      { 'a colpi di becco' }
sub barehanded      { 'a colpi di becco' }
sub combat_miss        { [0,'Sfrecci accanto a $0'    ] } # Message to you
sub combat_miss_target { [0,'$0 ti sfreccia accanto'  ] } # Message to target
sub combat_miss_others { [0,'$0 sfreccia accanto a $1'] } # Message to others
sub combat_miss_rea    { [0,'$0 frulla le ali contro di te'] } # Message to you, immediate effect
sub combat_miss_reatar { [0,'Frulli le ali contro $0'      ] } # Message to target, mmediate effect
sub combat_miss_reaoth { [0,'$0 frulla le ali contro $1'   ] } # Message to others, mmediate effect
sub combat_hit         { ['dai un colpo di becco a $0'  ] } # Message to you
sub combat_hit_target  { ['$0 ti da un colpo di becco'  ] } # Message to target
sub combat_hit_others  { ['$0 da un colpo di becco a $1'] } # Message to others
sub combat_hit_rea     { ['$0 frulla le ali contro di te'] } # Message to you, immediate effect
sub combat_hit_reatar  { ['Frulli le ali contro $0'      ] } # Message to target, mmediate effect
sub combat_hit_reaoth  { ['$0 frulla le ali contro $1'   ] } # Message to others, mmediate effect
