<%once>;
my $type = 'contrib';
my $disp_name = get_disp_name($type);
</%once>
<%args>
$widget
$param
$field
$obj
</%args>

<%init>;
# make sure we have some business being here...
return unless $field eq "$widget|save_cb" || $field eq "$widget|add_cb";

# Instantiate the grp or person object.
my $contrib = $obj;

if ($param->{delete}) {
    # Deactivate it.
    $contrib->deactivate;
    $contrib->save;
    log_event("${type}_deact", $contrib);
    my $name = "&quot;" . $contrib->get_name . "&quot;";
    add_msg("$disp_name profile $name deleted.");
    set_redirect('/admin/manager/contrib');
    return;
} else {# Roll in the changes.

    # update name elements
    my $meths = $contrib->my_meths;
    $meths->{fname}{set_meth}->($contrib, $param->{fname});
    $meths->{lname}{set_meth}->($contrib, $param->{lname});
    $meths->{mname}{set_meth}->($contrib, $param->{mname});
    $meths->{prefix}{set_meth}->($contrib, $param->{prefix});
    $meths->{suffix}{set_meth}->($contrib, $param->{suffix});
    my $name = "&quot;" . $contrib->get_name . "&quot;";

    if ($param->{mode} eq 'new') {

	# add person object to the selected group
	my $group = Bric::Util::Grp::Person->lookup( { id => $param->{group} } );
	$contrib->save;
	my $member = $group->add_member( { obj => $contrib } );
	$group->save;
	@{$param}{qw(mode contrib_id)} = ('edit', $member->get_id);
	$member = Bric::Util::Grp::Parts::Member::Contrib->lookup({ id => $param->{contrib_id} } );
	# Log that we've created a new contributor.
	log_event("${type}_new", $member);
	set_redirect('/admin/profile/contrib/edit/' . $param->{contrib_id} . '/' . '_MEMBER_SUBSYS' );
	return $member;

    } elsif ($param->{mode} eq "edit") { # we must be dealing with an existing contributor object

	# get handle to underlying person object
 	my $obj = $contrib->get_obj;

	# update contacts on this person object
 	$m->comp("/widgets/profile/updateContacts.mc",
 		 param => $param,
 		 obj   => $obj);
 	$obj->save;

	# Update attributes.
	foreach my $aname (@{ mk_aref($param->{attr_name}) } ) {

	    $contrib->set_attr( {
				 subsys   => $param->{subsys},
				 name     => $aname,
				 value    => $param->{"attr|$aname"},
				 sql_type => 'short'
				}
			      );
	}

	# Save the contributor
 	$contrib->save;
	$param->{contrib_id} = $contrib->get_id;
	if ($field eq "$widget|save_cb") {
	    # Record a message and redirect if we're saving
	    add_msg("$disp_name profile $name saved.");
	    log_event("${type}_save", $contrib);
	    clear_state("contrib_profile");
	    set_redirect('/admin/manager/contrib');
	}

    } elsif ($param->{mode} eq "extend") {

	$param->{mode} = 'edit';
	set_state_data("contrib_profile", { extending => 1 } );	
	set_redirect('/admin/profile/contrib/edit/' . $obj->get_id . '/'
		     . escape_uri($param->{subsys}) );
	log_event("${type}_ext", $contrib);
	return $contrib;

    } elsif ($param->{mode} eq 'preEdit') {

	$param->{mode} = 'edit';
	set_state_data("contrib_profile", { extending => 0 } );
	set_redirect('/admin/profile/contrib/edit/' . $obj->get_id . '/'
		     . escape_uri($param->{subsys}) );
	return $contrib;
    }

}

</%init>
<%doc>
###############################################################################

=head1 NAME

/widgets/profile/contrib.mc - Processes submits from Contributor Profile

=head1 VERSION

$Revision: 1.2 $

=head1 DATE

$Date: 2001-10-09 20:54:38 $

=head1 SYNOPSIS

  $m->comp('/widgets/profile/contrib.mc', %ARGS);

=head1 DESCRIPTION

This element is called by /widgets/profile/callback.mc when the data to be
processed was submitted from the contributor Profile page.

</%doc>
