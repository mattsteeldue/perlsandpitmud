# armour.pl
# Created Jan 2008
# Author  flogisto

use Armour;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( ); 
    bless $self, $class;

    $self->name('tunica');
    $self->short('tunica');
    $self->shorts('tuniche');
    $self->desc( "tunica nera." );
    return $self;
}

