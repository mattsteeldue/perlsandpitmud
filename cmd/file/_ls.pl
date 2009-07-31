=pod

Uso: ls [-l] [dir]
Mostra il contenuto della directory.

=cut

# ---------------------------------------------------------------------
sub cmd_ls {
    my $pl     = current_user();
    my $pwd    = $pl->custom('CurrentWorkDirectory') || '/home/'.$pl->name;
    my $me     = shift;
    my $verb   = shift;
    my $dir    = shift || $pwd;
    my $option = shift || '';

    ($option,$dir) = ($dir,$option) if substr($dir,0,1) eq '-';
    
    $dir = $pwd . '/' . $dir unless $dir =~ m/^\//;
    $dir = $pl->finddir($dir) ;
    my $dispdir = $dir || '/';

    my $color = '{Green}';
    my $endcolor = parse_string('{RESET}');
    my @dir    = ( parse_string("{Red}** Directory $dispdir **{RESET}\n") );

    my @ary = ();
    opendir( DIR, './'.$dir);
    while( my $elm = readdir DIR) { push @ary, $elm }
    closedir DIR;

    for my $elm ( sort @ary ) { 
        if ( $option =~ /l/ ) {
            $color = '{Green}';
            next if $elm eq '.' or $elm eq '..';
            my $size  =  -s "$dir/$elm" ;
            my $um    = 'b';
            if ($size >= 2024) { $size = int($size/1024); $um = 'k' }
            if ($size >= 2024) { $size = int($size/1024); $um = 'M' }
            if ($size >= 2024) { $size = int($size/1024); $um = 'G' }
            $size .= $um;
            if ( -d basenavdir("$dir/$elm") ) {
                $color = "{yellow}" ;
                $um = '';
                $size = '';
            }
            $color = parse_string($color);
            push @dir, sprintf("%7s %s%-40s%s\n", 
                $size, $color, $elm, $endcolor );
        }
        else {
            $color = '{Green}';
            next if $elm eq '.' or $elm eq '..';
            if ( -d basenavdir("$dir/$elm") ) { $color = "{yellow}" };
            $color = parse_string($color);
            push @dir, sprintf("%s%-10s%s\t", 
                $color, $elm, $endcolor );
            
        }
    }
    push @dir, "\n" unless $option =~ /l/;
    
    tell_object( $pl, @dir );
    return 1;
}

 