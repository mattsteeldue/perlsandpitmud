# cloak.pl
# Created Jan 2008
# Author  flogisto

use Cloak;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( ); 
    bless $self, $class;

    $self->name('mantello');
    $self->short('mantello');
    $self->shorts('mantelli');
    $self->desc( "mantello rosso-oro." );
    return $self;
}

