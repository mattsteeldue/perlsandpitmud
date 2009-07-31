# death_book.pl
# Created Jan 2008
# Author  flogisto

use Book;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( 'death_course' ); 
    bless $self, $class;

    $self->name('death');
    $self->short('death course');
    #$self->shorts('libri');
    $self->desc( "Libro del passaggio attraverso il mondo dei morti." );
    return $self;
}

