=pod

Uso: ansi
Consente di attivare o disattivare la presentazione dei colori "ANSI".
Non tutti i terminali sono in grado di recepire e visualizzare correttamente tali codici.
Si veda anche il comando 'color'.

=cut
# ---------------------------------------------------------------------
sub cmd_ansi { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift || 0;
    my $pl     = current_user();

    $pl->ansi_color( $pl->ansi_color ? 0 : 1 );
    notify_fail( parse_std_msg( $pl->ansi_color ? 'Actions_Ansi_on' : 'Actions_Ansi_off') );
    tell_object( $pl, parse_string("{GREEN}Ansi color: "
              . ($pl->ansi_color ? "on. ": "off. " ) . "\n" ));
    return -1 unless $pl->wizardhood && $pl->ansi_color ;
    
    tell_object( $pl, wrap_parse(
      "{black}{ON_WHITE}black{RESET} " 
    . "{blue}blue " 
    . "{red}red " 
    . "{magenta}magenta " 
    . "{green}green " 
    . "{cyan}cyan " 
    . "{yellow}yellow " 
    . "{white}white\n" 
    . "{Black}Black " 
    . "{Blue}Blue " 
    . "{Red}Red " 
    . "{Magenta}Magenta " 
    . "{Green}Green " 
    . "{Cyan}Cyan " 
    . "{Yellow}Yellow " 
    . "{White}White " 
    . "\n"
    ) ) ;

    return -1
}
