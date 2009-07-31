=pod

Uso: help <voce>    per avere una pagina di help su una certa <voce>
     help voci      per avere la lista di tutte le voci di questo help

=cut

# ---------------------------------------------------------------------
# Admin version.
# This file is under cmd/adm.
sub cmd_help { 
    my $me     = shift;
    my $verb   = shift;
    my $voce   = shift || 'help';
    my $this   = driver();
    my $pl     = current_user();
    my $fil    = getdir('dirdochelpwiz') . "${voce}.txt" ;

    unless( -f $fil ) { 
        notify_fail( parse_std_msg('Actions_Help_ko', $voce ) );
        return 0;
    };
    
    tell_object( $pl, "$fil\n" ) if $voce && $pl->wizardhood();
    tell_object( $pl, parse_color("{BOLD}  -- $voce --\n" ) ) if $voce;

    cat_wrap( $fil );    

    tell_object( $pl, parse_color("{BOLD}  -- --\n" ) ) if $voce;
    return 1;
}

