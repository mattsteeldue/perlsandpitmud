# the_void.pm
# Created Aug 2006
# Author  flogisto

use Room;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class; 

    $self->short('Il vuoto');
    $self->desc( "Ti ritrovi a galleggiare nel vuoto! ");
    
    return $self;
}

sub restart {    
    my $this  = shift;
    my $class = ref($this) || $this;
       
    $this->SUPER::restart();
    
    my @invent  = @{$this->inventory} ;
    foreach my $object ( @invent ) {
        next unless ref( $object );
        next if $object->isa('User');
        if ( -1 == pos_array( @{getsetup('PreloadedObjects')}, $object->module ) ){
            $object->destroy;
        }
    }
    return 0; 
}
