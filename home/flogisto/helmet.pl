# helmet.pl
# Created Jan 2008
# Author  flogisto

use Helmet;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( ); 
    bless $self, $class;

    $self->name('elmetto');
    $self->short('elmetto');
    $self->shorts('elmetti');
    $self->desc( "Elmetto di pelle." );
    return $self;
}

