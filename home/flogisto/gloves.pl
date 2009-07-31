# gloves.pl
# Created Jan 2008
# Author  flogisto

use Gloves;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( ); 
    bless $self, $class;

    $self->name('guanti');
    $self->short('guanti');
    $self->shorts('guanti');
    $self->desc( "guanti di pelle." );
    return $self;
}

