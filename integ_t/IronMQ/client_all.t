#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Exception;
use Encode;

use lib 't';
use common;

plan tests => 4; # Setup, Do, Verify, Cleanup

require IO::Iron::IronMQ::Client;

#use Log::Any::Adapter ('Stderr'); # Activate to get all log messages.
#use Data::Dumper; $Data::Dumper::Maxdepth = 1;

diag("Testing IO::Iron::IronMQ::Client $IO::Iron::IronMQ::Client::VERSION, Perl $], $^X");

## Test case
## Create queue, query queue, delete queue.
## Test with multiple queues.
diag('Testing IO::Iron::IronMQ::Client');

my $iron_mq_client;
my ($unique_queue_name_01, $unique_queue_name_02, $unique_queue_name_03);
subtest 'Setup for testing' => sub {
	plan tests => 1;
	# Create an IronMQ client.
	$iron_mq_client = IO::Iron::IronMQ::Client->new( { 'config' => 'iron_mq.json' } );
	
	# Create a new queue names.
	{ use utf8;
		$unique_queue_name_01 = common::create_unique_queue_name() . '_latin1';
		$unique_queue_name_02 = common::create_unique_queue_name() . '_räksmörgås';
		$unique_queue_name_03 = common::create_unique_queue_name() . '_三明治';
	}
	is(1,1, 'ok');
};

my ($created_iron_mq_queue_01, my $created_iron_mq_queue_02, my $created_iron_mq_queue_03);
subtest 'Create the queues' => sub {
	plan tests => 6;
	# Create a new queue.
	$created_iron_mq_queue_01 = $iron_mq_client->create_queue($unique_queue_name_01);
	$created_iron_mq_queue_02 = $iron_mq_client->create_queue($unique_queue_name_02);
	$created_iron_mq_queue_03 = $iron_mq_client->create_queue($unique_queue_name_03);
	isa_ok($created_iron_mq_queue_01, "IO::Iron::IronMQ::Queue", "create_queue returns a IO::Iron::IronMQ::Queue.");
	is($created_iron_mq_queue_01->name(), $unique_queue_name_01, "Created queue has the given name.");
	diag("Created message queue " . encode_utf8($unique_queue_name_01) . ".");
	isa_ok($created_iron_mq_queue_02, "IO::Iron::IronMQ::Queue", "create_queue returns a IO::Iron::IronMQ::Queue.");
	is($created_iron_mq_queue_02->name(), $unique_queue_name_02, "Created queue has the given name.");
	diag("Created message queue " . encode_utf8($unique_queue_name_02) . ".");
	isa_ok($created_iron_mq_queue_03, "IO::Iron::IronMQ::Queue", "create_queue returns a IO::Iron::IronMQ::Queue.");
	is($created_iron_mq_queue_03->name(), $unique_queue_name_03, "Created queue has the given name.");
	diag("Created message queue " . encode_utf8($unique_queue_name_03) . ".");
};

subtest 'Query the queues' => sub {
	plan tests => 4;
	# Query the created queue.
	my $queried_iron_mq_queue_01 = $iron_mq_client->get_queue($unique_queue_name_01);
	isa_ok($queried_iron_mq_queue_01 , "IO::Iron::IronMQ::Queue", "create_queue returns a IO::Iron::IronMQ::Queue.");
	#is($queried_iron_mq_queue_01->size(), 0, "Queried queue size is 0.");
	my $queried_iron_mq_queue_info_01 = $iron_mq_client->get_info_about_queue($unique_queue_name_01);
	#is($queried_iron_mq_queue_01->size(), $queried_iron_mq_queue_info_01->{'size'}, "Queried queue size matches with queried info.");
	
	diag("Queried message queue " . encode_utf8($unique_queue_name_01) . ".");
	my $queried_iron_mq_queue_02 = $iron_mq_client->get_queue($unique_queue_name_02);
	isa_ok($queried_iron_mq_queue_02 , "IO::Iron::IronMQ::Queue", "create_queue returns a IO::Iron::IronMQ::Queue.");
	#is($queried_iron_mq_queue_02->size(), 0, "Queried queue size is 0.");
	my $queried_iron_mq_queue_info_02 = $iron_mq_client->get_info_about_queue($unique_queue_name_02);
	#is($queried_iron_mq_queue_02->size(), $queried_iron_mq_queue_info_02->{'size'}, "Queried queue size matches with queried info.");
	
	diag("Queried message queue " . encode_utf8($unique_queue_name_02) . ".");
	my $queried_iron_mq_queue_03 = $iron_mq_client->get_queue($unique_queue_name_03);
	isa_ok($queried_iron_mq_queue_03 , "IO::Iron::IronMQ::Queue", "create_queue returns a IO::Iron::IronMQ::Queue.");
	#is($queried_iron_mq_queue_03->size(), 0, "Queried queue size is 0.");
	diag("Queried message queue " . encode_utf8($unique_queue_name_03) . ".");
	my $queried_iron_mq_queue_info_03 = $iron_mq_client->get_info_about_queue($unique_queue_name_03);
	#is($queried_iron_mq_queue_03->size(), $queried_iron_mq_queue_info_03->{'size'}, "Queried queue size matches with queried info.");
	
	# Query all queues.
	my @all_queues = $iron_mq_client->get_queues();
	my @found_queues;
	foreach my $queue (@all_queues) {
		if($queue->name eq $unique_queue_name_01 
			|| $queue->name eq $unique_queue_name_02 
			|| $queue->name eq $unique_queue_name_03
			) {
			push @found_queues, $queue;
		}
	}
	is(scalar @found_queues, 3, "get_queues returned the three created queues.");
};

subtest 'Clean up.' => sub {
	plan tests => 6;
	# Delete queue. Confirm deletion.
	my $delete_queue_ret_01 = $iron_mq_client->delete_queue($unique_queue_name_01);
	is($delete_queue_ret_01, 1, "Queue is deleted.");
	throws_ok {
		my $dummy = $iron_mq_client->get_queue($unique_queue_name_01);
	} '/IronHTTPCallException: status_code=404 response_message=Queue not found/', 
			'Throw IO::Iron::IronMQ::Exceptions::HTTPException when no message queue of given name.';
	diag("Deleted message queue " . encode_utf8($created_iron_mq_queue_01->name()) . ".");
	my $delete_queue_ret_02 = $iron_mq_client->delete_queue($unique_queue_name_02);
	is($delete_queue_ret_02, 1, "Queue is deleted.");
	throws_ok {
		my $dummy = $iron_mq_client->get_queue($unique_queue_name_02);
	} '/IronHTTPCallException: status_code=404 response_message=Queue not found/', 
			'Throw IO::Iron::IronMQ::Exceptions::HTTPException when no message queue of given name.';
	diag("Deleted message queue " . encode_utf8($created_iron_mq_queue_02->name()) . ".");
	my $delete_queue_ret_03 = $iron_mq_client->delete_queue($unique_queue_name_03);
	is($delete_queue_ret_03, 1, "Queue is deleted.");
	throws_ok {
		my $dummy = $iron_mq_client->get_queue($unique_queue_name_03);
	} '/IronHTTPCallException: status_code=404 response_message=Queue not found/', 
			'Throw IO::Iron::IronMQ::Exceptions::HTTPException when no message queue of given name.';
	diag("Deleted message queue " . encode_utf8($created_iron_mq_queue_03->name()) . ".");
};
