package Bric::Biz::Asset::Business::Parts::Instance::Story::DevTest;
use strict;
use warnings;
use base qw(Bric::Test::DevBase);
use Test::More;
use Test::Exception;
use Bric::Util::DBI qw(:standard :junction);
use Bric::Util::Time qw(strfdate);
use Bric::Biz::AssetType;
use Bric::Biz::Asset::Business::Parts::Instance::Story;

sub class { 'Bric::Biz::Asset::Business::Parts::Instance::Story' }
sub table { 'story_instance' }
# this will be filled during setup
my $OBJ_IDS = {};
my $OBJ = {};

##############################################################################
# Constructs a new object.
my $z;
sub new_args {
    my $self = shift;
    return (slug => 'slug' . ++$z);
}

sub construct {
    my $self = shift;
    $self->class->new({ $self->new_args, @_ });
}

##############################################################################
# Test the clone() method.
##############################################################################

sub test_clone : Test(13) {
    my $self = shift;
    
    my $elem = Bric::Biz::AssetType->lookup({ id => 1 });
    
    ok( my $instance = $self->class->new({ name    => 'Flubber',
                                           slug    => 'hugo',
                                           element => $elem,
                                           input_channel_id => 1
                                        }), "Construct instance" );
    ok( $instance->save, "Save instance" );

    # Save the ID for cleanup.
    ok( my $iid = $instance->get_id, "Get ID" );
    my $key = $self->class->key_name;
    $self->add_del_ids([$iid], $key);

    # Clone the instance.
    ok( $instance->clone, "Clone instance" );
    ok( $instance->set_slug('jarkko'), "Change the slug" );
    ok( $instance->save, "Save cloned instance" );
    ok( my $cid = $instance->get_id, "Get cloned ID" );
    $self->add_del_ids([$cid], $key);

    # Lookup the original instance.
    ok( my $orig = $self->class->lookup({ id => $iid }),
        "Lookup original instance" );

    # Lookup the cloned story.
    ok( my $clone = $self->class->lookup({ id => $cid }),
        "Lookup cloned instance" );

    # Check that the instance is really cloned!
    isnt( $iid, $cid, "Check for different IDs" );
    is( $clone->get_title, $orig->get_title, "Compare titles" );
    is( $clone->get_slug, 'jarkko', "Compare slugs" );
    
    is( $clone->get_element, $orig->get_element, 'Compare tiles' );
}

##############################################################################
# Test the SELECT methods
##############################################################################

sub test_select_methods: Test(9) {
    my $self = shift;
    my $class = $self->class;

    my $elem = Bric::Biz::AssetType->lookup({ id => 1 });
    my $ic = Bric::Biz::InputChannel::Element->lookup({ id => 1 });

    # create some instances
    my ($instance, $time, $got, $expected);

    $time = time;
    ok $instance = $class->new({ name             => "_test_$time",
                                 description      => 'this is a test',
                                 slug             => 'test',
                                 input_channel_id => $ic->get_id,
                                 element          => $elem
                               }), 'Create instance';
    ok $instance->save(), 'Insert instance into the database';
    my $instance_id = $instance->get_id();
    push @{$OBJ_IDS->{instance}}, $instance_id;
    $self->add_del_ids( $instance->get_id() );

    ok $instance->save(), 'Update instance in the database';
    is $instance->get_id, $instance_id, 'Instance still has same ID';

    # Try doing a lookup by ID
    $expected = $instance;
    ok $got = $class->lookup({ id => $expected->get_id }),
      "Look up by id";
    is $got->get_id, $expected->get_id, "... does it have the right ID";
    is $got->get_name(), $expected->get_name(),
        '... does it have the right name';
    is $got->get_description, $expected->get_description,
        '... does it have the right desc';
        
    ok $instance->get_element, 'Get element/tile';
}


##############################################################################
# Private class methods
##############################################################################

1;
__END__