# torch.pl
# Created Aug 2006
# Author  flogisto

use Object;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->short('torch') 
         ->shorts('torches') 
         ->desc( 'A lit torch') 
         ->light( 1 ) 
         ->value( 10 ) 
         ;
    return $self;
}

1;
