=pod

Uso: color <elemento> <colore>
è possibile scegliere il colore da usare per la visualizzazione delle varie parti delle descrizioni degli ambienti e degli oggetti.
<elemento> può essere uno fra i seguenti:
  notify     : messaggio di notifica / errore
  short      : descrizione breve della stanza
  long       : descrizione lunga della stanza
  annotation : annotazioni lasciate dagli utenti
  weather    : avviso meteorologico
<colore> può essere "default" oppure uno fra i seguenti:
  black blue red magenta green cyan yellow white 
  Black Blue Red Magenta Green Cyan Yellow White.
Il colore espresso in lettera Maiuscola indica la tinta "bold".
Si provi 'color help' da solo, per osservare la resa di ciascun colore.

=cut

# ---------------------------------------------------------------------
sub cmd_color { 
    my $me     = shift;
    my $verb   = shift;
    my $what   = shift || 0;
    my $color  = shift || 0;
    my $pl     = current_user();
    my $key    = 0;

    # without parameters gives current status
    unless( $what ) {
      tell_object( $pl, parse_std_msg('Actions_Color_list') 
                      . getcolor('NotifyFail')."notify " 
                      . getcolor('ShortRoom')."short " 
                      . getcolor('LongRoom')."long " 
                      . getcolor('Annotation')."annotation " 
                      . getcolor('Weather')."weather " 
                      . "\n" 
      # ask help: give keywords and examples
      #if ( $what eq 'help' || $what eq 'aiuto' ) {
                      . "<elem> : notify short long annot weather\n" 
                      . "<col> : " 
                      . parse_color("{black}black " ) 
                      . parse_color("{blue}blue " ) 
                      . parse_color("{red}red " ) 
                      . parse_color("{magenta}magenta " ) 
                      . parse_color("{green}green " ) 
                      . parse_color("{cyan}cyan " ) 
                      . parse_color("{yellow}yellow " ) 
                      . parse_color("{white}white " ) 
                      . parse_color("\n        " ) 
                      . parse_color("{Black}Black " ) 
                      . parse_color("{Blue}Blue " ) 
                      . parse_color("{Red}Red " ) 
                      . parse_color("{Magenta}Magenta " ) 
                      . parse_color("{Green}Green " ) 
                      . parse_color("{Cyan}Cyan " ) 
                      . parse_color("{Yellow}Yellow " ) 
                      . parse_color("{White}White " ) 
                      . "\n" );
      notify_fail( parse_std_msg('Actions_Color_help' ) );
      return -1;
    }

    # check element keyword
    unless ( $what =~ m/^notify$|^short$|^long$|^annot$|^weather$/i ) {
      notify_fail( parse_std_msg('Actions_Color_invalid') );
      return -1;
    }

    # check color keyword
    unless ( $color =~ m/^Black$|^Blue$|^Red$|^Magenta$|^Green$|^Cyan$|^Yellow$|^White$|
                         ^black$|^blue$|^red$|^magenta$|^green$|^cyan$|^yellow$|^white$|
                         ^default$/ ) {
      notify_fail("Codice colore '$color' non valido." );
      return -1;
    }
     
    # build key. Warning modifying this could be dangerous
    $key = 'ColorNotifyFail' if $what eq "notify"     ;
    $key = 'ColorShortRoom'  if $what eq "short"      ;
    $key = 'ColorLongRoom'   if $what eq "long"       ;
    $key = 'ColorAnnotation' if $what eq "annotation" ;
    $key = 'ColorWeather'    if $what eq "weather"    ;
    return -1 unless $key;

    # default color will ask driver()->constants->color.
    $color = getsetup($key) if $color eq 'default'; #*1$color = driver()->constants->{$key} if $color eq 'default';
    # set
    $pl->color( $key, $color );
    
    return 1
}
