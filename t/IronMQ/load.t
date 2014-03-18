#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

require IO::Iron;
require IO::Iron::IronMQ::Client;
require IO::Iron::IronMQ::Queue;
require IO::Iron::IronMQ::Message;

plan tests => 27;

BEGIN {
	use_ok('IO::Iron::IronMQ::Client') || print "Bail out!\n";
	can_ok('IO::Iron::IronMQ::Client', 'new');
	can_ok('IO::Iron::IronMQ::Client', 'get_queue');
	can_ok('IO::Iron::IronMQ::Client', 'create_queue');
	can_ok('IO::Iron::IronMQ::Client', 'delete_queue');
	can_ok('IO::Iron::IronMQ::Client', 'get_queues');
	can_ok('IO::Iron::IronMQ::Client', 'update_queue');
	can_ok('IO::Iron::IronMQ::Client', 'get_info_about_queue');

	use_ok('IO::Iron::IronMQ::Queue') || print "Bail out!\n";
	can_ok('IO::Iron::IronMQ::Queue', 'new');
	can_ok('IO::Iron::IronMQ::Queue', 'clear');
	can_ok('IO::Iron::IronMQ::Queue', 'push');
	can_ok('IO::Iron::IronMQ::Queue', 'pull');
	can_ok('IO::Iron::IronMQ::Queue', 'peek');
	can_ok('IO::Iron::IronMQ::Queue', 'delete');
	can_ok('IO::Iron::IronMQ::Queue', 'touch');
	can_ok('IO::Iron::IronMQ::Queue', 'release');
	can_ok('IO::Iron::IronMQ::Queue', 'size');
	# Attributes
	can_ok('IO::Iron::IronMQ::Queue', 'id');
	can_ok('IO::Iron::IronMQ::Queue', 'name');
	#can_ok('IO::Iron::IronMQ::Queue', 'project_id');

	use_ok('IO::Iron::IronMQ::Message') || print "Bail out!\n";
	can_ok('IO::Iron::IronMQ::Message', 'new');
	can_ok('IO::Iron::IronMQ::Message', 'body');
	can_ok('IO::Iron::IronMQ::Message', 'timeout');
	can_ok('IO::Iron::IronMQ::Message', 'delay');
	can_ok('IO::Iron::IronMQ::Message', 'expires_in');
	can_ok('IO::Iron::IronMQ::Message', 'id');
	#can_ok('IO::Iron::IronMQ::Message', 'reserved_count'); # FIXME Not yet implemented.
	#can_ok('IO::Iron::IronMQ::Message', 'push_status'); # FIXME Not yet implemented.
}

#use Log::Any::Adapter ('Stderr'); # Activate to get all log messages.

diag("Testing IO::Iron $IO::Iron::VERSION, Perl $], $^X");

#if(! -e File::Spec->catfile(File::HomeDir->my_home, '.iron.json') 
#		&& ! defined $ENV{'IRON_PROJECT_ID'}
#		&& ! -e File::Spec->catfile(File::Spec->curdir(), 'iron.json')) {
#	BAIL_OUT("NO IRONMQ CONFIGURATION FILE OR ENV VARIABLE IN PLACE! CANNOT CONTINUE!");
#}

###BAIL_OUT("STOP TESTING HERE!");

