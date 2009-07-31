# spider.pl
# Created Jun 2007
# Author  flogisto

use Mobile;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->short('spider') 
         ->desc( "Serve per testare le stanze."
               ) 
         ->hit_points(10) 
         
         ->add_action( 'spider','spider' ) 
         ->add_wandering_area( '*' )
   #     ->wandering_prob( 100 ); # %-probability
         ;
    return $self;
}

sub spider {
    my $this   = shift;
    my $verb   = shift; # panorama
    my $what   = shift || 30;
    my $pl     = current_user();
    call_out( $what, $this, 'stop_spider' ) if $what > 0; 
    $this->wandering_prob( 100 ); # %-probability
    tell_object( $pl, "Spider started\n");
    return 1;
}

sub stop_spider {
    my $this   = shift;
    $this->wandering_prob( 0 ); # %-probability
}

