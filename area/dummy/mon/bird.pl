# bird.pl
# Created Aug 2006
# Author  flogisto

use Mobile;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->name('bird') 
         ->short('a bird') 
         ->shorts('birds') 
         ->desc( 'A bird.') 
         ->descs( 'Some birds.') 
         ->add_id( 'birdy', 'birds' ) 
         
         ->message_out( '$n fly away to $0.\n' ) 
         ->message_in( '$n arrives flying.\n' ) 
         
         ->set_property('unique') 
         
         ->hit_points(10) 
         
         ->add_reply( 'hello',"Passerotto twitters: 'hello'" ) 
         
         ->chat_prob( 5 ) 
         ->add_chat( "Bird twitters happily." ) 
         ->add_chat( "Bird straightene its feathers." ) 
         ->add_chat( "Bird pecks here and there." ) 
         ->add_chat( "Bird become scared and flies away from you." ) 
         ->add_chat( "Bird get close curious." ) 
         ->add_chat( "Bird get close curious." ) 
         
         ->wandering_prob( 5 )  # %-probability
         ->add_wandering_area( 'bird' )  # areas
         
   #     ->trail_path( [ 'basso','alto','basso','alto' ] ) 
   #     ->trail_delay( 60 ) 
         ;
    
    return $self;
}

sub armed_with      { 'beating with its beak' }
sub barehanded      { 'beating with its beak' }
sub combat_miss        { [0,'You shoot close $0'    ] } # Message to you
sub combat_miss_target { [0,'$0 shoot very close to you'  ] } # Message to target
sub combat_miss_others { [0,'$0 shoot very close to $1'] } # Message to others
sub combat_miss_rea    { [0,'$0 flutters against you'] } # Message to you, immediate effect
sub combat_miss_reatar { [0,'You flutter against $0'      ] } # Message to target, mmediate effect
sub combat_miss_reaoth { [0,'$0 flutters against $1'   ] } # Message to others, mmediate effect
sub combat_hit         { ['You hit $0'  ] } # Message to you
sub combat_hit_target  { ['$0 hits you'  ] } # Message to target
sub combat_hit_others  { ['$0 hits $1'] } # Message to others
sub combat_hit_rea     { ['$0 flutters against you'] } # Message to you, immediate effect
sub combat_hit_reatar  { ['You flutter against $0'      ] } # Message to target, mmediate effect
sub combat_hit_reaoth  { ['$0 flutters against $1'   ] } # Message to others, mmediate effect
