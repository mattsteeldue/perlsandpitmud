=pod

Uso: pwd 
Mostra la directory di lavoro.

=cut

# ---------------------------------------------------------------------
sub cmd_pwd {
    my $me     = shift;
    my $verb   = shift;
    my $file   = shift;
    my $pl     = current_user();
    my $dir    = $pl->custom('CurrentWorkDirectory') || '/home/'.$pl->name;

    tell_object($pl,parse_std_msg('Actions_Pwd_ok',$dir)); 

    $pl->custom('CurrentWorkDirectory',$dir);

    return 1;
}

