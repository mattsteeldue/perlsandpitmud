=pod

Uso: trace [n]
Imposta o visualizza il valore di "trace" per il debugger. I valori impostano i singoli bit del debugger

   debugging: > trace n
   1 *incremental details*
   2 include_file
   4 load_module
   8 process_normal process_startup
  16 force do_command
  32 call_other socket_process
  64 effective_file_name
 128 find_object
 256 Actions._look 
 
 
=cut

# ---------------------------------------------------------------------
sub cmd_trace { 
    my $me     = shift;
    my $verb   = shift;
    my $pl     = current_user();
    
    if (@_) { 
        $pl->debugging( $_[0] ); 
    } 
    else    { 
        tell_object( $pl, parse_std_msg('Actions_Trace_flip', $pl->debugging ) );
    };
    return 1;
}

# ---------------------------------------------------------------------
    #   debugging: > trace n
    #   1 *incremental details*
    #   2 include_file
    #   4 load_module
    #   8 process_normal process_startup
    #  16 force do_command
    #  32 call_other socket_process
    #  64 effective_file_name
    # 128 Actions._look 
# ---------------------------------------------------------------------
