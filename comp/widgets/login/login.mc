%#--- Documentation ---#

<%doc>

=head1 NAME

login - A login widget

=head1 VERSION

$Revision: 1.2 $

=head1 DATE

$Date: 2001-10-09 20:54:38 $

=head1 SYNOPSIS

<& '/widgets/login/login.mc' &>

=head1 DESCRIPTION



=cut

</%doc>

%#--- Arguments ---#

<%args>
</%args>

%#--- Initialization ---#

<%once>
my $widget = 'login';
</%once>

<%init>
$m->comp("loggedout.html", widget => $widget);
</%init>

%#--- Log History ---#


