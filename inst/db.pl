#!/usr/bin/perl -w

=head1 NAME

db.pl - installation script to launch the apropriate database instalation script

=head1 VERSION

$LastChangedRevision$

=head1 DATE

$LastChangedDate$

=head1 DESCRIPTION

This script is called during C<make install> to install the Bricolage
database.

=head1 AUTHOR

Sam Tregar <stregar@about-inc.com>

=head1 SEE ALSO

L<Bric::Admin>

=cut

use strict;
use FindBin;
use lib "$FindBin::Bin/lib";
use Bric::Inst qw(:all);
use File::Spec::Functions qw(:ALL);
use File::Find qw(find);

our ($DB, $DBCONF);

print "\n\n==> Creating Bricolage Database <==\n\n";

$DBCONF = './database.db';
do $DBCONF or die "Failed to read $DBCONF : $!";

my $instdb;
$instdb = "./inst/dbload_$DB->{db}.pl";
do $instdb or die "Failed to launch $DB->{db} database loading script ($instdb)";    

exit 0;


