# emporio_clerk.pl
# Created Ago 2007
# Author  flogisto

use Mobile;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->add_id( ['terry','commesso']) 
         ->short('Terry il commesso') 
         ->desc( "Ecco Terry, il commesso dell'emporio del castello." ) 
         
         ->set_property('unique') 
         
         ->hit_points(10) 
         
         ->add_reply( 'ciao',"Terry risponde: 'ciao a te!'" ) 
         
         ->init_phrase( '\nTerry ti dice: "Benvenuto $n!"\n' ) 
         ->done_phrase( '\nTerry ti dice: "A presto $n!"\n\n' ) 
         ->init_phrase_room( '\nTerry dice a $n: "Benvenuto $n!"\n' ) 
         ->done_phrase_room( '\nTerry dice a $n: "A presto $n!"\n' ) 
         ;

    return $self;
}

