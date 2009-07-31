# Book.pm
# Created Aug 2006
# Author  flogisto

package Book;
use strict;
##use diagnostics;

use Commons;
use Object;

our @ISA = qw(Object);

sub book_file       { (@_)>1 ? ($_[0]->{BookFile}      = $_[1],$_[0]) : $_[0]->{BookFile}       } 
sub title           { (@_)>1 ? ($_[0]->{Title}         = $_[1],$_[0]) : $_[0]->{Title}          } 
sub page_index      { (@_)>1 ? ($_[0]->{PageIndex}     = $_[1],$_[0]) : $_[0]->{PageIndex}      } 
sub delay           { (@_)>1 ? ($_[0]->{Delay}         = $_[1],$_[0]) : $_[0]->{Delay}          }
sub reader_name     { (@_)>1 ? ($_[0]->{ReaderName}    = $_[1],$_[0]) : $_[0]->{ReaderName}     } 
sub reader_page     { (@_)>1 ? ($_[0]->{ReaderPage}    = $_[1],$_[0]) : $_[0]->{ReaderPage}     } 
sub reader_time     { (@_)>1 ? ($_[0]->{ReaderTime}    = $_[1],$_[0]) : $_[0]->{ReaderTime}     } 


# ---------------------------------------------------------------------
sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $file  = shift || 'dummy';
    my $self  = $this->SUPER::new; 

    $self->book_file( getdir('dirdocbook') . 'book_' . $file . '.txt' ) if $file ;

    $self->set_property('unique') 

         ->title( 'Untitled' ) 
         ->page_index ( [ ] ) 
         ->delay( 4 ) 
         ->reader_name ( [ ] ) 
         ->reader_page ( [ ] ) 
         ->reader_time ( [ ] ) 
         
         ->add_action( 'page','do_show_page' ) 
         ->add_action( 'pagina','do_show_page' ) 
         
         ->add_action( 'read','do_start_read' ) 
         ->add_action( 'leggi','do_start_read' ) 
         
         ->add_action( 'reindex','do_reindex' ) 
         
         ->create_page_index( ) 
         ;

    
    bless $self, $class;

    return $self;
}

# ---------------------------------------------------------------------
sub examine_object {
    my $this     = shift;
    my $class    = ref($this) || $this;
    my ($me,$ro,$ta) = $this->SUPER::examine_object( @_ );
    
    return (wrap_string($me),$ro,$ta);
}

# ---------------------------------------------------------------------
sub destroy {
    my $this  = shift;
    my $class = ref($this) || $this;
    $this->SUPER::destroy; 
    return $this;
}

# ---------------------------------------------------------------------
sub do_show_page  { 
    my $this  = shift;
    my $class = ref($this) || $this;
    my $verb  = shift; 
    my $num   = shift || 0;
    tell_object( current_user(), $this->page($num) . "\n" );
    return $this;
}

# ---------------------------------------------------------------------
sub page  { 
    my $this  = shift;
    my $class = ref($this) || $this;
    my $num   = shift || 0;
    my $start = $this->page_index->[$num] + ($num<1?0:1) ;
    my $end   = $this->page_index->[$num+1] ;     
    return '' if $num >= $#{$this->page_index()} ;
    return cat_str( $this->book_file, $start, $end-$start );;
}

# ---------------------------------------------------------------------
sub create_page_index {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $file  = shift || $this->book_file || getdir('dirdocbook') . 'book_dummy.txt' ;

    my @the_book = cat_array( $file );

    if ( scalar @the_book ) {
        my $j = 1;
        $this->title( $the_book[0] );
        $this->page_index->[ 0 ] = 0;
        foreach my $i ( 0 .. $#the_book ) {
            if ( $the_book[$i] =~ m/^\#(\d*)/ ) {
                $this->page_index()->[ $j ] = $i ;
                $j++;
            }
        }
        $this->page_index()->[ $j ] = scalar (@the_book);
    }
    return $this;
}

# ---------------------------------------------------------------------
# rebuilds index of pages.
sub do_reindex  { 
    my $this  = shift;
    my $class = ref($this) || $this;
    my $verb  = shift; 
    my $id    = shift || return;
    return 0 unless current_user()->wizardhood();
    return 0 unless $this->id( $id );
    $this->create_page_index();
    return $this;
}

# ---------------------------------------------------------------------
sub do_start_read  { 
    my $this  = shift;
    my $class = ref($this) || $this;
    my $verb  = shift; 
    my $id    = shift || $this->name;
    my $num   = shift || 0;
    my $pl    = current_user();
    
    return $this unless $this->id( $id );
    
    if ( -1 == pos_array( $this->reader_name, $pl->keyname ) ) {
        push @{$this->reader_name}, $pl->keyname ;
        push @{$this->reader_page}, $num;
        push @{$this->reader_time}, time();
    }
    
    my $i = pos_array( $this->reader_name, $pl->keyname );
    $this->reader_page->[ $i ] = $num;    
    $this->reader_time->[ $i ] = time() - $this->delay;    
    
    return $this;
}

# ---------------------------------------------------------------------
sub heart_beat  { 
    my $this    = shift;
    my $class   = ref($this) || $this;
    my $tt      = shift || time();
    $this->SUPER::heart_beat($tt);
    my @ary = @{$this->reader_name};
    
    foreach my $i ( 0 .. $#ary ) {
        my $num = $this->reader_page->[$i];
        my $tm  = $this->reader_time->[$i];
        if ( $num < $#{$this->page_index()} && $tt > $tm + $this->delay ) {
            my $pl = find_object( $this->reader_name->[$i] );
            next unless ref($pl) && $pl->isa('Living');
            if ( $pl->environment != $this->environment ) {
                remove_from_array( $this->reader_name, $this->reader_name->[$i] );
                next;
            }
            my $cu = current_user();
            current_user( $pl );
            tell_object( $pl, parse_string( $this->page($num) ) . "\n" );
            current_user( $cu );
            $this->reader_page->[$i] = ++$num ;
            $this->reader_time->[$i] = $tt 
        }
    }

    for ( my $i = $#ary; $i >= 0; $i-- ) {
        my $num = $this->reader_page->[$i];
        my $tm  = $this->reader_time->[$i];
        if ( $this->reader_page->[$i] >= $#{$this->page_index()} ) {
            remove_from_array( $this->reader_name, $this->reader_name->[$i] );
        }
    }
    return $this;
}

1;
