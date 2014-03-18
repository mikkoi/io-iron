# Subversion properties:
# $Id: 00_local_checkchanges.t 70 2013-10-13 09:53:54Z mikkoi $
# $Date: 2013-10-13 12:53:54 +0300 (Sun, 13 Oct 2013) $
# $Revision: 70 $
# $Author: mikkoi $
# $HeadURL: svn+ssh://mikkoi@kapsi.fi/home/users/mikkoi/subversion_repositories/cpan/io-iron/trunk/t/00_local_checkchanges.t $

use strict;
use warnings;
use File::Spec;
use Test::More;
use English qw(-no_match_vars);

if ( not $ENV{RELEASE_TESTING} ) {
	my $msg = 'Author test. Set $ENV{RELEASE_TESTING} to a true value to run.';
	plan( skip_all => $msg );
}

eval { require Test::CheckChanges };
if ( $EVAL_ERROR ) {
	my $msg = 'Test::CheckChanges required for testing the Changes file!';
	plan( skip_all => $msg );
}
Test::CheckChanges::ok_changes();

