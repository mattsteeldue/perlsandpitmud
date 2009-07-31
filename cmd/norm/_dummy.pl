
sub cmd_dummy { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();

    my $x = shift || '';
    write_client( "$x\n" );
}

