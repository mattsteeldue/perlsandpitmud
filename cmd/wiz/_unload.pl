=pod

Uso: unload <modulo>
Scarica dalla memoria il modulo specificato. Il modulo va specificato indicando il path completo ma senza l'estensione .pl; una volta scaricato il modulo verrà ricaricato in memoria immediatamente. 

=cut

# ---------------------------------------------------------------------
sub cmd_unload { 
    my $me     = shift;
    my $verb   = shift;
    my $obj    = shift || 0;
    my $file   = "$obj.pl";

    unless ( $obj ) { 
        notify_fail( parse_std_msg('Actions_Unload_ko'));
        return -1; 
    }

    unless ( exists $INC{$file} ) {
        notify_fail( parse_std_msg('Actions_Unload_notexist',$obj));
        return -1; 
    }

    my $oldwarn = $SIG{__WARN__};
    $SIG{__WARN__} = sub { };
    load_module( $obj, 1 );
    $SIG{__WARN__}  = $oldwarn;

    #
    #if ( exists $INC{$file} ) {
    #    notify_fail( parse_std_msg('Actions_Unload_fail',$obj));
    #    return -1; 
    #}

    return 1;
}

1;
