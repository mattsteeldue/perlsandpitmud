# general_store_clerk.pl
# Created Aug 2007
# Author  flogisto

use Mobile;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->add_id( ['clerk','commesso']);
    $self->short('Un commesso');
    $self->desc( "Ecco il tipico commesso di negozio. " );
    
    #$self->set_property('unique');

    $self->hit_points(10);
    
    $self->add_reply( 'ciao',"Il commesso risponde: 'ciao a te!'" );
    
    $self->init_phrase( '\nIl commesso ti dice: "Benvenuto $n!"\n' );
    $self->done_phrase( '\nIl commesso ti dice: "A presto $n!"\n\n' );
    $self->init_phrase_room( '\nIl commesso dice a $n: "Benvenuto $n!"\n' );
    $self->done_phrase_room( '\nIl commesso dice a $n: "A presto $n!"\n' );

    return $self;
}

