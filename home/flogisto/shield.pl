# shield.pl
# Created Jan 2008
# Author  flogisto

use Shield;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( ); 
    bless $self, $class;

    $self->name('scudo');
    $self->short('scudo');
    $self->shorts('scudi');
    $self->desc( "scudo in lega leggera." );
    return $self;
}

