=pod

Uso: temporary
Abilita o disabilita l'uso di file temporeanei

=cut

# ---------------------------------------------------------------------
sub cmd_temporary { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift || 0;
    my $pl     = current_user();
    
    my $this = driver() ;
    my $mode = $this->temporarymode + 1;
    $mode = 0 if $mode > 2;

    $this->temporarymode( $mode );
    tell_object( $pl, parse_std_msg('Actions_Temporary_flip', $this->temporarymode ) );
    
    return 1
}
