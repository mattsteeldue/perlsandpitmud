# hazards_daemon.pl
# Created Feb 2008
# Author  flogisto

# ---------------------------------------------------------------------
use Daemon;

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new( 'hazard_daemon' );
    bless $self, $class ;

    $self->add_action( 'hazard','hazard' );

    return $self;
}

# ---------------------------------------------------------------------
sub hazard {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $dice = int(rand(36));
    my $pl  = current_user();
    my @haz = qw (
    Massacre      Fire          Chapel        Quake         Stranger      Pedlar
    Tornado       Uneventful    Plague        Uneventful    Prisoner      Guest
    Witch'sCave   Famine        Uneventful    Bad-map       Pool-of-dream Lightning
    Lost          Flood         Waylaid       Uneventful    Which-road?   Ambush
    Uneventful    Blizzard      Double-back   Rockfall      Wagon-train   Uneventful
    Militia       Brigands   Travelling-minstrel  Fall  Glorious-Weather  Storm
    );
    tell_object($pl, "$haz[$dice]\n" );
}
