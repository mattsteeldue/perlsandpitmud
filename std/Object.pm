# Object.pm
# Created Feb 2004
# Author  flogisto

package Object;
use strict;
##use diagnostics;

use Commons;

=pod

=head1 DESCRIPTION

This is the "Base object"; The objects are defined in 'std' subdirectory
and comply with the following hierarchy.

Object
  |\
  | +-Room
  |     +-BackShop
  |     +-PostOffice
  |     +-Shop
  |     +-VirtualRoom
  |\ 
  | +-Daemon 
  |   (actions channel combat death emote hazards level mail move_dir none patch room_desc stock time)
  |\ 
  | +-Living
  |     +-Mobile 
  |     +-User
  |\ 
  | +-Garment**
  |     +-Helmet, Boots, Gloves, Armour, Shield, Cloak, Ring**, Amulet**, Earring**, Belt**
  |\ 
  | +-Weapon
  |     +-Sword, Axe**, Whip**
  |\ 
  | +-Container **
  |     +-Bag**, Rucksack**, Haversack**
  |\ 
  | +-Book **
  |\ 
  | +-Key **
  |\ 
  | +-Money
   \ 
    +-Exit **
      +-Door **


=head1 MEMBERS

new             constructor
config          retrieve data reading a configuration file (reverse of store)
store           stores the image of this object to a configuration file (retrievable later)
destroy         desctuct this object (i.e. moves away and unregister)

name            filename (without extension)
keyname         original name plus a unique sequence (clonenumber)
altname         array of alternative id. You use add_id(list). id(k) returns true if k is in list.
clonenumber     unique number within object having the same "name".
nextclone       next
prevclone       previous
module          complete filename .pl
visible         will compare in room description.

cap_name        first-capital name

short           short description. can be a func-ref which must return a string
shorts          plural short description. can be a func-ref which must return a string
desc            long description. can be a func-ref which must return a string
descs           plural lon description. can be a func-ref which must return a string

born            time of creation
age             in "heart_beats"
living          true if "living"
container       true if "container"
last_restart    time of last restart
last_garbage    time of last garbage collector trial

inventory       hash of objects contained in this object
environment     reference of object that contains this object
previous_room   keep trace of previous environment when moving object 
previous_object name of previous object
actions         hash of action-command available in this object in the form (verb=>func);
details         hash of details you can "examine". You can add_detail(k,string) or add_detail(k,func)
properties      hash of properties of this object. Use set_property(k,v), query_property(k)

value           in monetary unit.
light           light component. Use add_light (+/-) to modify this value (and "dark" property).
capacity        how many liters can hold (container). See add_capacity
used_capacity   how many liters are occupied (container)
bulk            how many liters occupies.
payload         how many kg can carry. See add_payload
used_payload    how many kg are carried.
weight          how many kg weights.
cannot_zap      item cannot be zapped.

initial_room    module where the object is first 

add_id          used to add a list of alternative names into alt_name
id              returns true if the passed string is found among name, keyname, short or alt_name
remove_id       reverse of add_id.

heart_beat      called every 2 seconds by the muddriver.
restart         called every few minutes to "reset" everything.
init            called when moving during trans_object_in()
done            called when moving during trans_object_out()

cannot_get      cannot get?
cannot_drop     cannot drop?
dummy_function  dummy function (why?)
debugging       dummy
catch_tell      tell_object sends text to this function.

add_action      add a "verb" to trigger a "func" 
remove_action   removes it (use with care)

add_detail      add a detail called "item" to display a string o to trigger "func" when examined.
query_detail    used by "look" commands to show a detail
remove_detail   removes it

recursive_inventory scans recursively the inventory of this object and all objects recursively, returns a long inventory.

set_property    sets a "key" property to the value passed (default is "1"), a timeout can be specified.
query_property  returns the property value of the "key" (or 0 if undefined)
remove_property undefine the property

add_light       add light to this object and all "environment" object. Does not pass through "opaque" objects.
add_capacity    add capacity to this object
add_payload     add payload to this object and all "environment" object. Does not pass through "antigravity" objects.

examine_object  returns a three-element array which describes the object from many point of view.
score_object    ???

custom          lets you define and retrieve custom attributes.
emote_target
emote_adverb
emote_where

move
trans_object_in         part of move_object
trans_object_out        part of move_object

=cut

# key data
# ---------------------------------------------------------------------
sub name            { (@_)>1 ? ($_[0]->{Name}          = $_[1],$_[0]) : $_[0]->{Name}           } 
sub keyname         { (@_)>1 ? ($_[0]->{Keyname}       = $_[1],$_[0]) : $_[0]->{Keyname}        } 
sub altname         { (@_)>1 ? ($_[0]->{AltName}       = $_[1],$_[0]) : $_[0]->{AltName}        } 
sub clonenumber     { (@_)>1 ? ($_[0]->{Clonenumber}   = $_[1],$_[0]) : $_[0]->{Clonenumber}    } 
sub nextclone       { (@_)>1 ? ($_[0]->{NextClone}     = $_[1],$_[0]) : $_[0]->{NextClone}      } 
sub prevclone       { (@_)>1 ? ($_[0]->{PrevClone}     = $_[1],$_[0]) : $_[0]->{PrevClone}      } 
sub module          { (@_)>1 ? ($_[0]->{Module}        = $_[1],$_[0]) : $_[0]->{Module}         } 
sub visible         { (@_)>1 ? ($_[0]->{Visible}       = $_[1],$_[0]) : $_[0]->{Visible}        } 

# utility
# ---------------------------------------------------------------------
sub cap_name        { my $uname = $_[0]->{Short}; return ucfirst($uname); } 


# descriptions
# ---------------------------------------------------------------------
#sub short           { $_[0]->add_id( lc($_[1]) ) if (@_)>1;
#                     (@_)>1 ? $_[0]->{Short}         = $_[1] : $_[0]->{Short}          }
sub short           { 
    if ( scalar @_ > 1 ) {
        $_[0]->{Short} = $_[1] ;
        $_[0]->{Shorts} = $_[1] unless $_[0]->{Shorts};
        return $_[0];
    }
    else {
        my $ob = $_[0]->{Short} ;
        return ( ( ref($ob) eq 'CODE' ) ? &$ob($_[0]) : $ob );
    }
}

# ---------------------------------------------------------------------
#sub shorts          { (@_)>1 ? $_[0]->{Shorts}        = $_[1] : $_[0]->{Shorts}         } 
sub shorts          { 
    if ( scalar @_ > 1 ) {
        $_[0]->{Shorts} = $_[1] ;
        return $_[0];
    }
    else {
        my $ob = $_[0]->{Shorts} ;
        return ( ( ref($ob) eq 'CODE' ) ? &$ob($_[0]) : $ob );
    }
} 

# ---------------------------------------------------------------------
#sub desc            { (@_)>1 ? $_[0]->{Desc}          = $_[1] : $_[0]->{Desc}           } 
sub desc            { 
    if ( scalar @_ > 1 ) {
        $_[0]->{Desc} = $_[1] ;
        $_[0]->{Descs} = $_[1] unless $_[0]->{Descs};
        return $_[0];
    }
    else {
        my $ob = $_[0]->{Desc} ;
        return ( ( ref($ob) eq 'CODE' ) ? &$ob($_[0]) : $ob );
    }
} 
    
# ---------------------------------------------------------------------
#sub descs           { (@_)>1 ? $_[0]->{Descs}         = $_[1] : $_[0]->{Descs}          } 
sub descs           { 
    if ( scalar @_ > 1 ) {
        $_[0]->{Descs} = $_[1] ;
        return $_[0];
    }
    else {
        my $ob = $_[0]->{Descs} ;
        return ( ( ref($ob) eq 'CODE' ) ? &$ob($_[0]) : $ob );
    }
} 

# timing
# ---------------------------------------------------------------------
sub born            { (@_)>1 ? ($_[0]->{Born}          = $_[1],$_[0]) : $_[0]->{Born}           } 
sub age             { (@_)>1 ? ($_[0]->{Age}           = $_[1],$_[0]) : $_[0]->{Age}            } 
sub living          { (@_)>1 ? ($_[0]->{Living}        = $_[1],$_[0]) : $_[0]->{Living}         } 
sub container       { (@_)>1 ? ($_[0]->{Container}     = $_[1],$_[0]) : $_[0]->{Container}      } 
sub last_restart    { (@_)>1 ? ($_[0]->{LastRestart}   = $_[1],$_[0]) : $_[0]->{LastRestart}    } 
sub last_garbage    { (@_)>1 ? ($_[0]->{LastGarbage}   = $_[1],$_[0]) : $_[0]->{LastGarbage}    } 

# interaction
# ---------------------------------------------------------------------
sub inventory       { (@_)>1 ? ($_[0]->{Inventory}     = $_[1],$_[0]) : $_[0]->{Inventory}      } 
sub environment     { (@_)>1 ? ($_[0]->{Environment}   = $_[1],$_[0]) : $_[0]->{Environment}    } 
sub previous_room   { (@_)>1 ? ($_[0]->{PreviousRoom}  = $_[1],$_[0]) : $_[0]->{PreviousRoom}   } 
sub previous_object { (@_)>1 ? ($_[0]->{PreviousObject}= $_[1],$_[0]) : $_[0]->{PreviousObject} } 
sub actions         { (@_)>1 ? ($_[0]->{Actions}       = $_[1],$_[0]) : $_[0]->{Actions}        } 
sub details         { (@_)>1 ? ($_[0]->{Details}       = $_[1],$_[0]) : $_[0]->{Details}        } 
sub properties      { (@_)>1 ? ($_[0]->{Properties}    = $_[1],$_[0]) : $_[0]->{Properties}     } 

# self properties
# ---------------------------------------------------------------------
sub value           { (@_)>1 ? ($_[0]->{MonetaryValue} = ($_[1]>1?$_[1]:1),$_[0]) : $_[0]->{MonetaryValue}}

sub light           { 
    (@_)>1 ? 
        ($_[0]->{Light} = $_[1],$_[0]) : 
        $_[0]->{Light} - $_[0]->query_property('dark') 
} 

sub capacity        {(@_)>1 ? ($_[0]->{Capacity}      = ($_[1]>0?$_[1]:0),$_[0]) : $_[0]->{Capacity}    } 
sub used_capacity   {(@_)>1 ? ($_[0]->{UsedCapacity}  = ($_[1]>0?$_[1]:0),$_[0]) : $_[0]->{UsedCapacity}} 
sub bulk            {(@_)>1 ? ($_[0]->{Bulk}          = ($_[1]>0?$_[1]:0),$_[0]) : $_[0]->{Bulk}        } 
sub payload         {(@_)>1 ? ($_[0]->{Payload}       = ($_[1]>0?$_[1]:0),$_[0]) : $_[0]->{Payload}     } 
sub used_payload    {(@_)>1 ? ($_[0]->{UsedPayload}   = ($_[1]>0?$_[1]:0),$_[0]) : $_[0]->{UsedPayload} } 
sub weight          {(@_)>1 ? ($_[0]->{Weight}        = ($_[1]>0?$_[1]:0),$_[0]) : $_[0]->{Weight}      } 


# ---------------------------------------------------------------------
sub initial_room    {(@_)>1 ? ($_[0]->{InitialRoom}   = $_[1],$_[0]) : $_[0]->{InitialRoom}    } 
sub cannot_zap      {(@_)>1 ? ($_[0]->{CannotZap}     = $_[1],$_[0]) : $_[0]->{CannotZap}      } 

# ---------------------------------------------------------------------
# first function called when a new object is instantiated
# tipically you should do that using the standard Commons "clone_object" function
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $classname = $class; 
    $classname =~ s|::|/|g;  # subst any :: with /
    $classname = basename( $classname );
    my $name  = shift || basefilename($classname) ; 
    my $self = { };
    bless $self, $class;

    $self->name             ( $name ) 
         ->altname          ( [ ] )
         ->keyname          ( $classname )  # complete filename plus number: later.
         ->clonenumber      ( 0 )
         ->nextclone        ( 0 )
         ->prevclone        ( 0 )
         ->module           ( $classname . '.pl' )
         ->visible          ( 1 )
         
         #->short('Object')  # each object must declare
         #->shorts('Objects')
         ->desc             ( std_msg('BaseObject') )
         ->descs            ( std_msg('BaseObjects') )
         
         ->born             ( time() )
         ->last_restart     ( $self->born )
         ->last_garbage     ( $self->born )
         ->age              ( 0 )
         ->living           ( 0 ) # object isn't living
         
         ->container        ( 0 ) # object isn't container
         ->inventory        ( [] )
         ->environment      ( 0 )
         ->previous_room    ( '' )
         ->actions          ( { } )
         ->details          ( { } )
         ->properties       ( { } )
         
         ->capacity         ( 0 )      # lt
         ->used_capacity    ( 0 )      # lt
         ->bulk             ( 1 )      # lt
         
         ->payload          ( 0 )      # kg
         ->used_payload     ( 0 )      # kg
         ->weight           ( 1 )      # kg
         
         ->value            ( 1 )      # monetary value
         
         ->light            ( 0 )
         ->cannot_zap       ( 0 )       # this calls User->cannot_zap...
         
         ->initial_room     ( 0 )  # Commons
         ;
         
    if (  exists driver()->objects->{ "$classname" } 
       && driver()->objects->{ "$classname" }->properties->{ 'unique' }
        ) {
        log_file( 'compile.log',  "$classname should be unique!" ) ;
        call_out( 0, $self, 'destroy' ); # immediate desctruction.
    }

    # registers any object into the muddriver.
    my $keyname = register_object( $classname, $self );
    $self->keyname( $keyname );

    return $self;
}

# ---------------------------------------------------------------------
# this function is called to configure the object, i.e. read a "configuration"
# file created with the corresponding "store" function
# This function uses the restore_config function that calls the restore_string
# in the Commons module
sub config {                
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $file    = shift;

    # save special data (config might overwrite and we don't want)
    my $name    = $this->name; # save name.
    my $keyname = $this->keyname; # save keyname.
    my $altname = $this->altname;

    restore_config( $this, $file );

    $this->name( $name )
         ->keyname( $keyname )
         ->altname( $altname )
         ;
    return $this;
}                

# ---------------------------------------------------------------------
# this function is called to "save" the current status/image of any object
# to a configuration file. The file can be read later to restore it to that
# status.
# This function uses the store_config function that calls the store_string
# in the Commons module
sub store {                
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $file = shift;
    unless ( store_config( $this, $file) ) {
        warn "Can't store object in file $file: $!.\n" ;    
        log_file( 'store.log', "Can't store object in file $file: $!.\n" );
    }
    return $this;
}

# ---------------------------------------------------------------------
# destroy itself, disposes any structure defined during new
sub destroy {    
    my $this  = shift;
    my $class = ref($this) || $this;
    my $keyname     = $this->keyname;
    my $envi  = $this->environment ;
    $envi = find_object($envi) if $envi && !ref($envi);
    $envi = $this->previous_room unless ref($envi) && $envi->isa('Object');
    foreach my $ob ( @{$this->inventory} ) { 
        my $result = $ob->move( $envi );
        $ob->move( the_void() ) if $result < 1;
    }
    $this->trans_object_out( $envi ) if ref($envi);
    unregister_object( $keyname );
    return $this;
}

# ---------------------------------------------------------------------
# enters the object in "room", adjust capacity and payload, 
# and tell to all that an object just entered.
sub trans_object_in { 
    my $this  = shift;
    my $class = ref($this) || $this;
    my $room  = shift;
    my $i = pos_array( @{$room->inventory}, $this );
    return -1 unless -1 == $i;

    push ( @{$room->inventory} ,$this ) if ref($room) ;
    $this->environment( $room ) if ref($this);
    
    if ( ref($room) && ref($this) ) {
        $room->add_capacity( $this->bulk ) ;
        $room->add_payload( $this->weight ) ;
        $room->add_light( $this->light ) ;
    }
    
    $this->init( $room ) if ref($this);
    $room->init( $this ) if ref($room);
    return 0;
}

# ---------------------------------------------------------------------
# removes the object from "prov", adjust capacity and payload
sub trans_object_out { 
    my $this  = shift;
    my $class = ref($this) || $this;
    my $prov  = shift;
    my $i = pos_array( @{$prov->inventory}, $this );
    return -1 if -1 == $i;

    $prov->done( $this ) if ref($prov);
    $this->done( $prov ) if ref($this);
    
    if ( ref($prov) && ref($this) ) {
        $prov->add_capacity( - $this->bulk );
        $prov->add_payload( - $this->weight );
        $prov->add_light( - $this->light );
        $this->previous_room( basename($prov->module()) );
    }

    $this->environment( 0 ) if ref($this);
    remove_from_array( $prov->inventory, $this ) if ref($prov);
    return 0;
}

# ---------------------------------------------------------------------
# transfer this object to the location "where" you want
# this function returns:
# +1 successful.
#  0 failure, wrong room.
# -1 failure, object or location are not inherited from Object.
# -2 failure, capacity check fails
# -3 failure, payload check fails
sub move {    
    my $this  = shift;
    my $class = ref($this) || $this;
    my $where = shift;
    my $prov; 
    my $room;
    
    # search that name among rooms, should give a ref-to-Room
    $room = ref( $where ) ? $where : find_object( $where );
    
    # second chance, referencing through effective_file_name
    unless ( $room ) {
        $where = effective_file_name( $where );
        $room  = find_object( $where );
    }
    
    # third chance, try to load the room in memory
    unless ( $room ) {
        $room = call_other( $where, 'new' ); 
        if ( 0 == $room || -1 == $room ) {
            notify_fail ( parse_std_msg('NotifyNoSuchPlace', $where ) );
            return 0;
        };
    }

    # cannot move when room isn't inherited from Object.
    unless ( ref($room) && $room->isa('Object') ) {
        notify_fail ( parse_std_msg('NotifyCannotMove', $this->name, $where ) );
        return -1;
    }

    $prov = $this->environment();

    # capacity check
    if ( $room->used_capacity + $this->bulk > $room->capacity ) {
        notify_fail ( parse_std_msg('NotifyCannotMove', $this->name, $where ) );
        return -2;
    }

    # payload check
    $room->add_payload( $this->weight ) ;
    if ( $room->used_payload > $room->payload ) {
        $room->add_payload( - $this->weight ) ;
        notify_fail ( parse_std_msg('NotifyCannotMove', $this->name, $where ) );
        return -3;
    }
    $room->add_payload( - $this->weight ) ;

    # effective move.
    $this->trans_object_out( $prov ) if( ref($prov) && $prov->isa('Object') ) ;
    $this->trans_object_in( $room );

    return $this;
}

# ---------------------------------------------------------------------
# do command
sub force_to { return 0 }

# ---------------------------------------------------------------------
# adds an "id" name that can be used later to identify it. See id(string).
# you can pass many "id" at one time, to mass add.
sub add_id {    
    my $this  = shift;
    my $class = ref($this) || $this;
    my @array = @_ ;
    my $array = $_[0] ;
    @array = @$array if ( ref($array) eq 'ARRAY' ) ;
    map { $_=lc($_) } @array;
    push @{$this->{AltName}}, @array ;
    return $this;
}

# ---------------------------------------------------------------------
# returns true if param matches "ids":
# usage is $ob->id( $string ).
# it uses, in order, name, keyname, short and ids added via add_id().
sub id {    
    my $this  = shift;
    my $class = ref($this) || $this;
    my $data  = shift || return 0;
    $data = lc($data);
    return 1 if $data eq $this->keyname();
    return 1 if $data eq $this->name();
    my @ary   = @{$this->{AltName}} ;
    my $i = -1;
    $i = pos_array( @ary, $data ) if -1 == $i; 
    return 1 unless -1 == $i;
    return 1 if $data eq $this->short();
    return 0;
}

# ---------------------------------------------------------------------
# remove an "id" previously added via add_id.
sub remove_id { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    foreach my $par ( @_ ) {    
        remove_from_array( $this->{AltName}, $par );
    }
    return $this;
}

# ---------------------------------------------------------------------
# a "heart_beat" happens every few seconds (configuration)
sub heart_beat  { 
    $_[0]->{Age} += 1 ;
    return $_[0];
} 

# ---------------------------------------------------------------------
# a "restart" happens every few minutes (configuration) to reset the object
sub restart {    
    my $this  = shift;
    my $class = ref($this) || $this;
    $this->last_restart( time() );
    return $this;
}

# ---------------------------------------------------------------------
# called twice during trans_object_in:
# 1. addressed to the object being trans-ed, using the room as param
# 2. addressed to the room entered, using the object as param
sub init { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $param   = shift;
    ###print "init called ob=" . $this->name . " param=" . $param->name . "\n";
    return $this; 
}

# ---------------------------------------------------------------------
# called twice during trans_object_out:
# 1. addressed to the room being left, using the object as param
# 2. addressed to the object being trans-ed, using the room being left as param
sub done { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $param   = shift;
    ###print "done called ob=" . $this->name . " param=" . $param->name . "\n";
    return $this; 
}

# ---------------------------------------------------------------------
sub cannot_get { return 0; } # zero, you can get it

# ---------------------------------------------------------------------
sub cannot_drop { return 0; } # zero, you can drop it

# ---------------------------------------------------------------------
# dummy function
sub dummy_function { return -1 }
sub debugging { return -1 }

# ---------------------------------------------------------------------
# everything said in the environment (or directly to the object) is 
# received by this function to "respond" to anything normal
sub catch_tell { }

# ---------------------------------------------------------------------
# an object can hold the "hook" of a "verb",
# when the user types the verb, the object could respond to that.
sub add_action { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $verb    = shift  || return 0;
    my $func    = shift;
    $this->actions->{ "$verb" } = "$func";
    return $this;
}

# ---------------------------------------------------------------------
sub remove_action { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $verb    = shift  || return 0;
    delete $this->actions->{ "$verb" } if exists $this->actions->{ "$verb" };
    return $this;
}

# ---------------------------------------------------------------------
# add a descriptive item identified by a name.
# usually, the user can "examine item" and see the result.
# usage are: $self->add_detail( 'torr', 'A nice torr' );
#            $self->add_detail( 'foe', \&foe_function );
sub add_detail { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $item    = shift  || return 0;
    my $func    = shift;
    
    if ( ref($item) eq 'ARRAY' ) {
        foreach my $el ( @{$item} ) { 
            $this->details->{ "$el" } = $func;
        }
    }
    else {
        $this->details->{ "$item" } = $func;
    }
    return $this;
}

# ---------------------------------------------------------------------
# returns the description of a detail
sub query_detail {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $item    = shift  || return 0;
    return 0 unless exists $this->details->{ "$item" };
    #return $this->details->{ "$item" } ;
    my $ob = $this->details->{ "$item" } ;
    return ( ( ref($ob) eq 'CODE' ) ? &$ob($this,@_) : $ob );
}

# ---------------------------------------------------------------------
sub remove_detail { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $item    = shift  || return 0;
    delete $this->details->{ "$item" } if exists $this->details->{ "$item" };
    return $this;
}

# ---------------------------------------------------------------------
# recursively scans the inventory on the object and every container object it holds.
# returns an array of Objects.
sub recursive_inventory {
    my $this  = shift;
    my $class = ref($this) || $this;
    my @inv   = @{$this->inventory};
    my @accu = recursive_inventory_deep( 1, @inv );
    return @accu; 
}

# ---------------------------------------------------------------------
sub recursive_inventory_deep {
    my $level   = shift;
    my @inv     = @_;
    my @accu;
    return @inv if $level > 1;
    foreach my $ob ( @inv ) { 
        push @accu, $ob;
        push @accu, recursive_inventory_deep( $level + 1, @{$ob->inventory} ) if ref($ob);
    }
    return @accu;
}

# ---------------------------------------------------------------------
# define a static property.
# It is very similar to add_detail (but cannot use functions)
# Property can be temporary, when a timeout is specified.
sub set_property {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $key     = shift || return $this;
    my $value   = shift || 1;
    my $timeout = shift || 0;
    if ( ref($key) eq 'ARRAY' ) {
        foreach my $pr ( @$key ) { 
            $this->properties->{ "$pr" } = 1;
        }
    }
    else {
        $this->properties->{ "$key" } = "$value";
        if ($timeout > 0) {
            $timeout += time() ;
            $this->properties->{ "$key" } .= "|$timeout";
        }
    }
    return $this;
}

# ---------------------------------------------------------------------
sub query_property {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $key     = shift  || return 0;
    return 0 if ! exists $this->properties->{ "$key" };
    my $value = $this->properties->{ "$key" } ;
    my $timeout = 0 ;
    my $now = time();
    ($value,$timeout) = ( $`, $' ) if $value =~ m/\|/ ;
    return 0 if $timeout && $timeout < $now;
    ###print "dark $value\n" if $key eq 'dark';
    return $value ;
}

# ---------------------------------------------------------------------
sub remove_property {
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $key     = shift  || return 0;
    return $this if ! exists $this->properties->{ "$key" };
    delete $this->properties->{ "$key" } ;
    return $this;
}

# ---------------------------------------------------------------------
# this recursively add any amount of "light" to the environment
sub add_light {
    my $this   = shift;
    my $class  = ref($this) || $this;
    my $amount = shift || 0;
    my $envi   = $this->environment ;
    $this->light( $this->{Light} + $amount ); # don't call ->light !
    if ( ref($envi) && $envi->isa('Object') ) {
        if ($envi->query_property('transparent') ) {
            unless ( $envi->query_property('opaque') ) {
                $envi->add_light( $amount )
            }
        }
    }
    return $this;
}

# ---------------------------------------------------------------------
sub add_capacity {
    my $this   = shift;
    my $class  = ref($this) || $this;
    my $amount = shift || 0;
    $this->used_capacity( $this->used_capacity + $amount );
    return $this;
}

# ---------------------------------------------------------------------
sub add_payload {
    my $this   = shift;
    my $class  = ref($this) || $this;
    my $amount = shift || 0;
    my $envi   = $this->environment ;
    $this->used_payload( $this->used_payload + $amount );
    if ( ref($envi) && $envi->isa('Object') ) {
        $envi->add_payload( $amount ) unless $envi->query_property('antigravity');
    }
    return $this;
}

# ---------------------------------------------------------------------
# this function must return an array of three elements
# - message to me
# - message to the environment, i.e. room object except me and target.
# - message to the target.
sub examine_object {
    my $this   = shift;
    my $class  = ref($this) || $this;
    my $what   = shift || 0 ;
    my $pl     = current_user();
    my $me     = parse_std_msg('Actions_Examine_ok', $this->name ) ;
    my $ro     = parse_std_msg('Actions_Examine_ok2', $this->name );
    my $ta     = parse_std_msg('Actions_Examine_ok1', );
    $me .= "\n" . parse_string( $this->desc() ) ;
    return (wrap_string($me),$ro,$ta);
}        

# ---------------------------------------------------------------------
sub score_object {
    my $this   = shift;
    my $class  = ref($this) || $this;
    return "...";
}

# ---------------------------------------------------------------------
sub custom {
    my $this   = shift;
    my $class  = ref($this) || $this;
    my $attrib = shift || '';
    $attrib = 'Custom' . $attrib;
    return (@_)>0 ? $this->{$attrib} = $_[0] : $this->{$attrib} ;
}

# transient data
# ---------------------------------------------------------------------
sub emote_target    {(@_)>1 ? ($_[0]->{EmoteTarget}    = $_[1],$_[0]) : $_[0]->{EmoteTarget}    } 
sub emote_adverb    {(@_)>1 ? ($_[0]->{EmoteAdverb}    = $_[1],$_[0]) : $_[0]->{EmoteAdverb}    } 
sub emote_where     {(@_)>1 ? ($_[0]->{EmoteWhere}     = $_[1],$_[0]) : $_[0]->{EmoteWhere}     } 

1;
