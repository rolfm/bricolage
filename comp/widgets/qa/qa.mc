%#--- Documentation ---#

<%doc>

=head1 NAME

qa - A QA widget

=head1 VERSION

$Revision: 1.2 $

=head1 DATE

$Date: 2001-10-09 20:54:39 $

=head1 SYNOPSIS

<& '/widgets/qa/qa.mc' &>

=head1 DESCRIPTION

Report a bug for a QA process.

=cut

</%doc>

%#--- Arguments ---#

<%args>
$dump => undef
</%args>

%#--- Initialization ---#

<%once>
use Storable;
#use URI::Escape;

my $widget = 'qa';
</%once>

<%init>

#if ($dump) {
#    my $stor = Storable::thaw(uri_unescape($dump));
#   
#    $m->comp('dump.html', stor => $stor);
#} else {
    my %s = %HTML::Mason::Commands::session;

    my $data = {'env' => \%ENV,
        	'ses' => \%s,
    	        'uri' => $r->uri};

    my $stor = Storable::freeze($data);

    $m->comp('button.html', stor => $stor);
#}

</%init>

%#--- Log History ---#


