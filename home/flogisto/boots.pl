# boots.pl
# Created Jan 2008
# Author  flogisto

use Boots;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( ); 
    bless $self, $class;

    $self->name('stivaletti');
    $self->short('paio di stivaletti');
    $self->shorts('paia di stivaletti');
    $self->desc( "stivaletti militari." );
    return $self;
}

