=pod

Mostra da quanto tempo è in esecuzione il driver.

es: "In esecuzione da 0 giorni, 0 ore, 13 minuti, 30 secondi."

=cut

# ---------------------------------------------------------------------
sub cmd_uptime { 
    my $me      = shift;
    my $verb    = shift;
    my $pl      = current_user();
    my $this    = driver();

    my $uptime = time() - $this->time_boot();
    my $ss = $uptime % 60; $uptime = int($uptime/60);
    my $mi = $uptime % 60; $uptime = int($uptime/60);
    my $hh = $uptime % 24; $uptime = int($uptime/24);
    my $dd = $uptime;
    write_client( parse_std_msg('PromptUptime', $dd, $hh, $mi, $ss )); 
    return 1;   

}
