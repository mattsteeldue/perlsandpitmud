# book.pl
# Created Nov 2007
# Author  flogisto

use Book;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( 'prova' ); 
    bless $self, $class;

    $self->name('death_course');
    $self->short('libro');
    $self->shorts('libri');
    $self->desc( "Un libro di testo." );
    return $self;
}

