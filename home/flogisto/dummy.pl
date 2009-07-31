# dummy.pl
# Created Aug 2007
# Author  flogisto

use Mobile;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->name('fantoccio');
    $self->short('fantoccio');
    $self->shorts('fantocci');
    $self->desc( "Un fantoccio da combattimento."
               );
    $self->hit_points(100);
    $self->wounds(100);
    
    return $self;
}
