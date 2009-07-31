# Room.pm
# Created Aug 2006
# Author  flogisto

package Room;
use strict;
##use diagnostics;

use Commons;
use Object;

our @ISA = qw(Object);

=pod

=head1 DESCRIPTION

This is the standard "room" object. This kind of objects makes up the 
"environment" of any other object.

=head1 MEMBERS

obvious_exits   list of non-hidden exits
obvious_exit_act associated action
cloned_objects  list of object to be clone after each restart.
cloned_params   
cloned_keyname
#cloned_pointer
cloned_unique
cloned_type 
wandering_area  wandering area-tag for wandering mobs. Usually defined in new
new

add_object      during new you can add_object(filename). see cloned_objects
add_unique_object
remove_object   when you want to remove an added object.

add_exit        during new you can add_exit(verb,filename). see obvious_exits
can_reach
do_move_to_exit hook function used in moving-to-dir
remove_exit     when you want to remove an added exit: this can be done in VirtualGrid->new.

add_wandering_area during new you can define many wandering-area-tags
remove_wandering_area opposite.
query_wandering_area you can pass a tag and see if this room has that wandering-area-tag defined

query_neighbour returns a list of neighbour until a given recursion deep
recursive_neighbour_deep used by query_neighbour
query_neighbour_dirs returns an hash-ref, direction => neighbour room.

do_look
cannot_get      always 1. You cannot get a room.
cannot_drop     always 1.
heart_beat      used to reset the objects
examine_object  returns a description of the room. called by "look" command.
restart         at restart the room is re-populated and re-filled
init            propagates init to each living
done            propagates init to each living

examine_object

=cut
               
# ---------------------------------------------------------------------
sub obvious_exits   { (@_)>1 ? ($_[0]->{ObviousExit}   = $_[1],$_[0]) : $_[0]->{ObviousExit}    } 
sub obvious_exit_msg{ (@_)>1 ? ($_[0]->{ObviousExitMsg}= $_[1],$_[0]) : $_[0]->{ObviousExitMsg} }

# ---------------------------------------------------------------------
sub cloned_objects  { (@_)>1 ? ($_[0]->{ClonedObject}  = $_[1],$_[0]) : $_[0]->{ClonedObject}   } 
sub cloned_params   { (@_)>1 ? ($_[0]->{ClonedParams}  = $_[1],$_[0]) : $_[0]->{ClonedParams}   } 
sub cloned_keyname  { (@_)>1 ? ($_[0]->{ClonedKeyName} = $_[1],$_[0]) : $_[0]->{ClonedKeyName}  } 
#sub cloned_pointer  { (@_)>1 ? ($_[0]->{ClonedPointer} = $_[1],$_[0]) : $_[0]->{ClonedPointer}  } 
sub cloned_unique   { (@_)>1 ? ($_[0]->{ClonedUnique}  = $_[1],$_[0]) : $_[0]->{ClonedUnique}   } 
sub cloned_type     { (@_)>1 ? ($_[0]->{ClonedType}    = $_[1],$_[0]) : $_[0]->{ClonedType}     } 

# ---------------------------------------------------------------------
sub wandering_area  { (@_)>1 ? ($_[0]->{WanderingArea} = $_[1],$_[0]) : $_[0]->{WanderingArea}  } 

# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new;
    bless $self, $class;

    my @path = split( /\//, $self->module() );
    my $area = [];
    #push( @$area, $path[1] ) if ( $path[0] eq 'area' );
    push( @$area, $path[1] ) if ( $path[0] eq substr(getdir('dirarea'),0,-1) );

    $self->obvious_exits( { } )
         ->obvious_exit_msg( { } )
         
         ->cloned_objects( [ ] )        
         ->cloned_params ( [ ] )        
         ->cloned_keyname( [ ] )        
         #->cloned_pointer( [ ] )        
         ->cloned_unique ( [ ] )        
         ->cloned_type   ( [ ] )        
         
         ->wandering_area( $area ) 
         
         ->short('An anonymous room') 
         ->desc('This is a normal room') 
         ->shorts( 0 ) 
         ->descs( 0 ) 
         
         ->capacity( 1_000_000_000 )   # lt 
         ->payload( 1_000_000_000 )    # kg
         ->light( 1 ) 
         ;


    return $self;
}
    
# ---------------------------------------------------------------------
sub add_note { 
}

# ---------------------------------------------------------------------
# add a clone object to this room
# first argument is the filename,
# next arguments will be passed at runtime
sub add_object { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $file    = shift  || return 0;

    my $ob = 0;
    my $objects   = $this->cloned_objects;
    my @p         = (@_) ;
    my $params    = $this->cloned_params;
    my $keyname   = $this->cloned_keyname; 
    my $unique    = $this->cloned_unique;
    my $type      = $this->cloned_type;

    $file = effective_file_name($file, $this);
    $ob = clone_object( $file, @_ );
    $ob->trans_object_in( $this ) if ref($ob);

    # stores the new object even if it is not perfectly created.
    push @$objects, $file;
    push @$params,  \@p;
    push @$keyname, (ref($ob) ? $ob->keyname : 0) ;
    push @$unique,  (ref($ob) ? ($ob->query_property('unique') || $ob->query_property('cloned_unique')) : 0) ;
    push @$type,    (ref($ob) && $ob->isa('Living') ? 1 : 0) ;

    return $this;
}

# ---------------------------------------------------------------------
# add a clone object to this room
# first argument is the filename,
# next arguments will be passed at runtime
sub add_unique_object { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $file    = shift  || return 0;
    
    my $ob = $this->add_object($file, @_ );
    $ob->set_property('cloned_unique');

    my $objects   = $this->cloned_objects;
    for( my $i = 0; $i < scalar ( @{ $objects } ); $i++ ) {
        my $elm = $objects->[$i];
        if ( $file eq $elm ) {
            $this->cloned_unique->[$i] = 1;
            last;
        }
    }

    return $ob;
}

# ---------------------------------------------------------------------
# remove a clone object
sub remove_object { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $file    = shift  || return 0;
    my $objects   = $this->cloned_objects;
    my $pl = current_user();

    for( my $i = 0; $i < scalar ( @{ $objects } ); $i++ ) {
        my $elm = $objects->[$i];
        if ( $file eq $elm ) {
            #$this->cloned_pointer->[$i]->destroy if find_object( $this->cloned_keyname->[$i] );
            my $ob = find_object( $this->cloned_keyname->[$i] ) ;
            $ob->destroy if ref($ob) && $ob->isa('Object');
            splice @{$this->cloned_objects}, $i, 1;
            splice @{$this->cloned_params},  $i, 1;
            splice @{$this->cloned_keyname}, $i, 1;
            #splice @{$this->cloned_pointer}, $i, 1;
            splice @{$this->cloned_unique},  $i, 1;
            splice @{$this->cloned_type},    $i, 1;
            last;
        }
    }
    return $this;
}

# ---------------------------------------------------------------------
# add an exit
sub add_exit { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $verb    = shift  || return 0;
    my $where   = shift  || return 0;
    my $act     = shift  || '';

    # translates to standard direction verb if can.
    $verb = getsetup("Direction_$verb") || $verb ;
    $this->add_action( "$verb", "do_move_to_exit" );

    $this->obvious_exits->{ "$verb" } = effective_file_name("$where",$this);
    $this->obvious_exit_msg->{ "$verb" } = $act if $act;
    return $this;
}

# ---------------------------------------------------------------------
# say if you can reach via obvious_exits a certain room passed by module-name.
# for example using the "back" command uses it.
sub can_reach { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $room    = shift  || return 0;
    
    while ( my ($key,$value) = each %{ $this->obvious_exits } ) { 
        if ( $value eq $room ) { return $key }
    }
    return 0;
}

# ---------------------------------------------------------------------
# hook function used when moving-to-dir (see add_exit).
sub do_move_to_exit { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $verb    = shift || return 0;
    my $dest    = $this->obvious_exits->{ "$verb" } ;
    daemon('move_dir','do_move_dir',$verb );
    return 1;
}

# ---------------------------------------------------------------------
# remove an exit
sub remove_exit { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $verb    = shift  || return 0;
    my $where   = shift  || return 0;
    my $exits   = $this->obvious_exits();
    my $actions = $this->actions();
    if( ref($exits) ) {
        delete $exits->{ "$verb" } if exists $exits->{ "$verb" } ;
        delete $actions->{ "$verb" } if exists $actions->{ "$verb" } ;
    }
    return $this;
}

# ---------------------------------------------------------------------
# add a named wandering area.
# mob uses this sub to see if an adjacent room can be moved to.
sub add_wandering_area { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $area    = shift  || return 0;
    my $where   = $this->wandering_area;
 
    if ( ref($area) eq 'ARRAY' ) {
        foreach my $el ( @{$area} ) { 
            push @$where, $el if -1 == pos_array( @$where, $el );
        }
    }
    else {
        push @$where, $area if -1 == pos_array( @$where, $area );
    }
    return $this;
}

# ---------------------------------------------------------------------
# remove a named wandering area
sub remove_wandering_area { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $area    = shift  || return 0;
    my $where   = $this->wandering_area;
    remove_from_array( $where, $area ) unless -1 == pos_array( $where, $area ) ;
    return $this;
}

# ---------------------------------------------------------------------
# reply 1 if an area matches with those of this room.
sub query_wandering_area { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my @areas   = @_ ;
    return 1 if $areas[0] eq '*';
    my $where   = $this->wandering_area;
    foreach my $area ( @areas ) {
        return 1 unless -1 == pos_array( $where, $area ) ;
    }
    return 0;
}

# ---------------------------------------------------------------------
# returns the list of neighbour room (recursively) of this room.
# a second parameter specifies the number of steps
sub query_neighbour { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $deep    = shift || 0;
    my @array  = recursive_neighbour_deep( $this, $deep );
    my %hash   = map { $_, $_ } @array;
    my @unique = values %hash;
    return @unique;
}

# ---------------------------------------------------------------------
sub recursive_neighbour_deep {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $level   = shift;
    my @neigh   = values %{ $this->query_neighbour_dirs() } ;
    return @neigh if $level < 1;
    my @accu = @neigh ;
    foreach my $room ( @neigh ) { 
        push @accu, recursive_neighbour_deep( $room, $level - 1 ) if ref($room) && $room->isa('Room');
    }
    return @accu;
}

# ---------------------------------------------------------------------
# returns an hash-ref, each element is a direction mapping a neighbour room.
sub query_neighbour_dirs { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $exits   = {};
    while ( my ($key,$val) = each %{$this->obvious_exits} ) {
        # this call to existance the neighbour room
        my $keyname = call_other( "$val", 'keyname' );
        $exits->{$key}= find_object( "$val" ) if $keyname;
    }
    return $exits;
}

# ---------------------------------------------------------------------
# this is a test.
sub do_look { 
    my $this   = shift;
    my $verb   = shift;
    my $what   = shift;

    tell_object ( current_user(), "Passed: $this - $verb \n" );
    tell_object ( current_user(),  current_user()->inputline, "\n" );
    
    #current_user()->force_to('look'); 
    return 1;
}

# ---------------------------------------------------------------------
sub cannot_get { return 1; } # one, you cannot get it

# ---------------------------------------------------------------------
sub cannot_drop { return 1; } # one, you cannot get it

# ---------------------------------------------------------------------
# a "restart" happens every few minutes (configuration) to reset the objects
sub heart_beat  { 
    my $this  = shift;
    my $class = ref($this) || $this;
    my $tt    = shift || time();
    my $dont  = 0;
    $this->SUPER::heart_beat($tt);

    if ( $tt > $this->last_restart + driver()->time_restart and driver()->resetroommode() ) {
        $this->restart( $tt ) ;
    }

    # don't destroy me if registered in PreloadedObjects.
    $dont++ if -1 == pos_array( @{getsetup('PreloadedObjects')}, $this->module ) ; 
    
    # don't destroy me if inventory is not empty
    $dont++ if scalar @{ $this->inventory } ;
    
    # don't destroy me if there exists a clone object of mine somewehere in the world.
    for( my $i = 0; $i < scalar ( @{ $this->cloned_objects } ); $i++ ) {
        $dont++ if find_object( $this->cloned_keyname->[$i], $this) ;
    }

    if ( $dont ) {
        $this->last_garbage( $tt );
    }
    else {
        if ( $tt > $this->last_garbage + driver()->time_garbage ) {
            ###print "Destroy ", $this->module;
            $this->destroy;
        }
    }
    return $this;
}

# ---------------------------------------------------------------------
# at "restart" cloned-objects are restored
# a "restart" happens every so often (configuration)
sub restart {    
    my $this  = shift;
    my $class = ref($this) || $this;
    my $objects = $this->cloned_objects;
    my $pl = current_user();
       
    $this->SUPER::restart();
    
    for( my $i = 0; $i < scalar ( @{ $this->cloned_objects } ); $i++ ) {
        # skip present objects.
        next if find_object( $this->cloned_keyname->[$i], $this) ;
        # skip unique objects.
        next if $this->cloned_unique->[$i] && ! find_object( $this->cloned_keyname->[$i] );
        # skip non-dead mob.
        next if find_object( $this->cloned_keyname->[$i] ) && $this->cloned_type->[$i] ;
        # clone object here and updates references.
        my $file = $this->cloned_objects->[$i] ;
        my $pars = $this->cloned_params->[$i] ;
        my $ob = clone_object( $file, @{ $pars } );
        #$this->cloned_pointer->[$i] = $ob ;
        $this->cloned_keyname->[$i] = (ref($ob) ? $ob->keyname : 0) ;
        $ob->trans_object_in( $this ) if ref($ob) ;
    }    

    ## inventory non vuoto.    
    ##if ( scalar @{ $this->inventory } ) {
    ##    $this->last_garbage( time() );
    ##}
    ##else {
    ##    if ( -1 == pos_array( @{getsetup('PreloadedObjects')}, $this->module ) ){
    ##        ###print "Could destroy ", $this->module;
    ##        ###if ( time() > $this->last_garbage + driver()->time_garbage ) {
    ##            ###print "Destroy ", $this->module;
    ##            $this->destroy;
    ##        ###}
    ##        ###print "\n";
    ##    }
    ##}
    return $this;
}

# ---------------------------------------------------------------------
sub init { 
    my $room    = shift;
    my $class   = ref($room) || $room;
    my $param   = shift;
    $room->SUPER::init($param);
    my @invent  = @{$room->inventory} ;
    ###print "Room.init called ob=" . $room->name . " param=" . $param->name . "\n";
    foreach my $object ( @invent ) {
        next unless ref($object) && $object->isa('Living');
        next if $object == $param;
        ###print "Sub-";
        $object->init( $param );
    }
    return $room;
}

# ---------------------------------------------------------------------
sub done { 
    my $room    = shift;
    my $class   = ref($room) || $room;
    my $param   = shift;
    $room->SUPER::done($param);
    my @invent  = @{$room->inventory} ;
    ###print "Room.done called ob=" . $room->name . " param=" . $param->name . "\n";
    foreach my $object ( @invent ) {
        next unless ref($object) && $object->isa('Living');
        next if $object == $param;
        ###print "Sub-";
        $object->done( $param );
    }
    return $room;
}

# ---------------------------------------------------------------------
sub examine_object {
    my $room    = shift;
    my $class   = ref($room) || $room;
    ###print "Room: $class";
    ###print " Virtual" if $room->isa('VirtualRoom');
    ###print "\n";
    #?#my ($room_desc,$dummya,$dummyb) = $room->SUPER::examine_object; 
    my $room_desc = daemon('room_desc','do_look_room', $room );
    return ($room_desc,0,0);
}

1;
