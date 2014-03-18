#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

require IO::Iron;

plan tests => 4;

BEGIN {
	use_ok('IO::Iron') || print "Bail out!\n";
	can_ok('IO::Iron', 'ironcache');
	can_ok('IO::Iron', 'ironmq');
	can_ok('IO::Iron', 'ironworker');
}

#use Log::Any::Adapter ('Stderr'); # Activate to get all log messages.

diag("Testing IO::Iron $IO::Iron::VERSION, Perl $], $^X");

#if(! -e File::Spec->catfile(File::HomeDir->my_home, '.iron.json') 
#		&& ! defined $ENV{'IRON_PROJECT_ID'}
#		&& ! -e File::Spec->catfile(File::Spec->curdir(), 'iron.json')) {
#	BAIL_OUT("NO IRONMQ CONFIGURATION FILE OR ENV VARIABLE IN PLACE! CANNOT CONTINUE!");
#}
