use Shop;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $this->SUPER::new; 
    bless $self, $class;

    $self->short('Shop') 
         ->desc( "This is the shop of the castle, " .
                 "Read the sign to see how sell and buy items. " .
                 "Aside, there is a trash-can. " .
                 "\n") 

         ->add_detail('shop',
        "You are in." ) 
         ->add_detail( ['items'] , \&do_sign ) 
         ->trash_can->add_id('trash') 

         ->add_exit('west',     './building') 
         
         ;

    return $self;
}

