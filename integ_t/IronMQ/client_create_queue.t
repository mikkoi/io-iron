#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Exception;
use Log::Any::Test;    # should appear before 'use Log::Any'!
use Log::Any qw($log);

use lib 't';
use lib 'integ_t';
use common;

plan tests => 4; # Setup, Do, Verify, Cleanup

require IO::Iron::IronMQ::Client;

#     Attn! Do not use the "use Log::Any" and "use Log::Any::Adapter" at the same time!!
#     Otherwise can't use Log::Any::Test
#use Log::Any::Adapter ('Stderr'); # Activate to get all log messages.
#use Data::Dumper; $Data::Dumper::Maxdepth = 2;

diag("Testing IO::Iron::IronMQ::Client, Perl $], $^X");

## Test case
diag('Testing IO::Iron::IronMQ::Client method create_queue().');

my $iron_mq_client;
my $queue_name;
my $created_queue;
my $queried_queue;

subtest 'Setup for testing' => sub {
	plan tests => 1;
	# Create an IronMQ client.
	$iron_mq_client = IO::Iron::IronMQ::Client->new( 'config' => 'iron_mq.json' );
	# Create a new queue name.
	$queue_name = common::create_unique_queue_name();
	is(1, 1, 'Everything ok.');
	diag("Setup ready. Queue name:'" . $queue_name . "'.");
};

my $queue_id;
subtest 'Create queue' => sub {
	plan tests => 3;
	# Create a new queue.
	$log->clear();
	$created_queue = $iron_mq_client->create_queue( 'name' => $queue_name );
	$queue_id = $created_queue->id();
	#my $log_test = 0;
	#map { $log_test = 1 if ($_->{level} eq 'info' 
	#		&& $_->{category} eq 'IO::Iron::IronMQ::Client' 
	#		&& $_->{message} =~ /^Created a new IO::Iron::IronMQ::Queue object \(queue id=$queue_id; queue name=$queue_name\)\.$/gs
	#	) } @{$log->msgs};
	#is($log_test, 1, 'create_queue() logged correctly.');
	isa_ok($created_queue, "IO::Iron::IronMQ::Queue", "Method create_queue() returns a IO::Iron::IronMQ::Queue.");
	is($created_queue->name(), $queue_name, "Created queue has the given name.");
	# Queue is empty
	is($created_queue->size(), 0, 'Created queue size is 0.');
	diag("Created message queue '" . $queue_name . "'.");
};

subtest 'Confirm result' => sub {
	plan tests => 3;
	$queried_queue = $iron_mq_client->get_queue( 'name' => $queue_name );
	is($queried_queue->name(), $created_queue->name(), "Queried queue has the same name as created queue.");
	is($queried_queue->id(), $created_queue->id(), "Queried queue has the same id as created queue.");
	is($queried_queue->size(), 0, 'Queried queue size is 0.');
	diag("Confirmed result.");
};

subtest 'Clean up' => sub {
	plan tests => 1;
	# Delete queue. Confirm deletion.
	my $delete_queue_ret = $iron_mq_client->delete_queue(  'name' => $queue_name );
	is($delete_queue_ret, 1, "Queue is deleted.");
	diag("All cleaned up.")
};
