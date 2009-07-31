# corpse.pl
# Created Nov 2006
# Author  flogisto

use Object;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $ob    = shift;
    my $self  = $this->SUPER::new; 
    my $name  = 'Cadavere non identificabile.';
    bless $self, $class;

    $self->add_id('cadavere','corpo');

    $self->previous_object( ref($ob) ? $ob->short : 0 );
    $name = $self->previous_object . ' morto' if $self->previous_object ;
    $self->short( $name );
    $self->desc( $name );
    
    call_out( getsetup('CopseDecayDelay'), $self, 'do_destroy_1' );
    
    return $self;
}

# ---------------------------------------------------------------------
sub do_destroy_1 {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $name  = 'di cadavere';
    say( $this->desc . " si decompone." );
    $name = $this->previous_object if $this->previous_object ;
    $this->short( "Resti di $name" );
    $this->desc( "Alcuni resti di $name" );
    $this->remove_id('cadavere','corpo');
    $this->add_id('resti');
    call_out( getsetup('CopseDecayDelay'), $this, 'do_destroy_2' );
}

# ---------------------------------------------------------------------
sub do_destroy_2 {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $name  = 'di cadavere';
    say( $this->desc . " si decompongono. " );
    $name = $this->previous_object if $this->previous_object ;
    $this->short( "Tracce di resti di $name" );
    $this->desc( "Delle tracce di resti di $name" );
    $this->remove_id('cadavere','corpo');
    $this->add_id('resti');
    call_out( getsetup('CopseDecayDelay'), $this, 'do_destroy_final' );
}

# ---------------------------------------------------------------------
sub do_destroy_final {
    my $this  = shift;
    my $class = ref($this) || $this;
    say( $this->desc . " si dissolvono. " );
    $this->destroy;
}

# ---------------------------------------------------------------------
sub cannot_get { 
    notify_fail("Non sei costretto a farlo..." );
    return 1; 
}

# ---------------------------------------------------------------------
sub examine_object {
    my $this     = shift;
    my $class    = ref($this) || $this;
    my ($me,$ro,$ta) = $this->SUPER::examine_object( @_ );
    my @invent = @{$this->inventory} ;
    foreach my $object ( @invent ) {
        $me .= $object->short . "\n";
    }
    return ($me,$ro,$ta);
}

