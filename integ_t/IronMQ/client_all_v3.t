#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Exception;

use lib 't';
use lib 'integ_t';
use IronTestsCommon;

# Tests: Create queues, get, update, delete, list
#        add subscribers, replace, remove

require IO::Iron::IronMQ::Client;

use Log::Any::Adapter ('Stderr'); # Activate to get all log messages.
use Data::Dumper; $Data::Dumper::Maxdepth = 1;

diag('Testing IO::Iron::IronMQ::Client '
   . ($IO::Iron::IronMQ::Client::VERSION ? "($IO::Iron::IronMQ::Client::VERSION)" : '(no version)')
   . ", Perl $], $^X");

## Test case
## Create queue, query queue, delete queue.
## Test with multiple queues.
diag('Testing IO::Iron::IronMQ::Client');

# Create an IronMQ client.
my $iron_mq_client = IO::Iron::IronMQ::Client->new( 'config' => 'iron_mq_v3.json' );

# Create a new queue names.
my $unique_queue_name_01 = IronTestsCommon::create_unique_queue_name() . '_v3_pull';
my $unique_queue_name_02 = IronTestsCommon::create_unique_queue_name() . '_v3_push';

my ($created_iron_mq_queue_01, $created_iron_mq_queue_02);
subtest 'Create the queues' => sub {
	# Create a new queue.
	$created_iron_mq_queue_01 = $iron_mq_client->create_queue( 'name' => $unique_queue_name_01, 'type' => 'pull' );
	$created_iron_mq_queue_02 = $iron_mq_client->create_queue( 'name' => $unique_queue_name_02 );
	isa_ok($created_iron_mq_queue_01, 'IO::Iron::IronMQ::Queue', 'create_queue returns a IO::Iron::IronMQ::Queue.');
	is($created_iron_mq_queue_01->name(), $unique_queue_name_01, 'Created queue has the given name.');
	# diag("Created message queue " . encode_utf8($unique_queue_name_01) . ".");
	isa_ok($created_iron_mq_queue_02, 'IO::Iron::IronMQ::Queue', 'create_queue returns a IO::Iron::IronMQ::Queue.');
	is($created_iron_mq_queue_02->name(), $unique_queue_name_02, 'Created queue has the given name.');
	# diag("Created message queue " . encode_utf8($unique_queue_name_02) . ".");
   done_testing();
};

# subtest 'Query the queues' => sub {
# 	plan tests => 4;
# 	# Query the created queue.
# 	my $queried_iron_mq_queue_01 = $iron_mq_client->get_queue( 'name' => $unique_queue_name_01 );
# 	isa_ok($queried_iron_mq_queue_01 , "IO::Iron::IronMQ::Queue", "create_queue returns a IO::Iron::IronMQ::Queue.");
# 	#is($queried_iron_mq_queue_01->size(), 0, "Queried queue size is 0.");
# 	my $queried_iron_mq_queue_info_01 = $iron_mq_client->get_info_about_queue( 'name' => $unique_queue_name_01 );
# 	#is($queried_iron_mq_queue_01->size(), $queried_iron_mq_queue_info_01->{'size'}, "Queried queue size matches with queried info.");
# 	
# 	diag("Queried message queue " . encode_utf8($unique_queue_name_01) . ".");
# 	my $queried_iron_mq_queue_02 = $iron_mq_client->get_queue( 'name' => $unique_queue_name_02 );
# 	isa_ok($queried_iron_mq_queue_02 , "IO::Iron::IronMQ::Queue", "create_queue returns a IO::Iron::IronMQ::Queue.");
# 	#is($queried_iron_mq_queue_02->size(), 0, "Queried queue size is 0.");
# 	my $queried_iron_mq_queue_info_02 = $iron_mq_client->get_info_about_queue( 'name' => $unique_queue_name_02 );
# 	#is($queried_iron_mq_queue_02->size(), $queried_iron_mq_queue_info_02->{'size'}, "Queried queue size matches with queried info.");
# 	
# 	diag("Queried message queue " . encode_utf8($unique_queue_name_02) . ".");
# 	my $queried_iron_mq_queue_03 = $iron_mq_client->get_queue( 'name' => $unique_queue_name_03 );
# 	isa_ok($queried_iron_mq_queue_03 , "IO::Iron::IronMQ::Queue", "create_queue returns a IO::Iron::IronMQ::Queue.");
# 	#is($queried_iron_mq_queue_03->size(), 0, "Queried queue size is 0.");
# 	diag("Queried message queue " . encode_utf8($unique_queue_name_03) . ".");
# 	my $queried_iron_mq_queue_info_03 = $iron_mq_client->get_info_about_queue( 'name' => $unique_queue_name_03 );
# 	#is($queried_iron_mq_queue_03->size(), $queried_iron_mq_queue_info_03->{'size'}, "Queried queue size matches with queried info.");
# 	
# 	# Query all queues.
# 	my @all_queues = $iron_mq_client->get_queues();
# 	my @found_queues;
# 	foreach my $queue (@all_queues) {
# 		if($queue->name() eq $unique_queue_name_01 
# 			|| $queue->name() eq $unique_queue_name_02 
# 			|| $queue->name() eq $unique_queue_name_03
# 			) {
# 			push @found_queues, $queue;
# 		}
# 	}
# 	is(scalar @found_queues, 3, "get_queues returned the three created queues.");
# };
#
# subtest 'Clean up.' => sub {
# 	plan tests => 6;
# 	# Delete queue. Confirm deletion.
# 	my $delete_queue_ret_01 = $iron_mq_client->delete_queue( 'name' => $unique_queue_name_01 );
# 	is($delete_queue_ret_01, 1, "Queue is deleted.");
# 	throws_ok {
# 		my $dummy = $iron_mq_client->get_queue( 'name' => $unique_queue_name_01 );
# 	} '/IronHTTPCallException: status_code=404 response_message=Queue not found/', 
# 			'Throw IO::Iron::IronMQ::Exceptions::HTTPException when no message queue of given name.';
# 	diag("Deleted message queue " . encode_utf8($created_iron_mq_queue_01->name()) . ".");
# 	my $delete_queue_ret_02 = $iron_mq_client->delete_queue( 'name' => $unique_queue_name_02 );
# 	is($delete_queue_ret_02, 1, "Queue is deleted.");
# 	throws_ok {
# 		my $dummy = $iron_mq_client->get_queue( 'name' => $unique_queue_name_02 );
# 	} '/IronHTTPCallException: status_code=404 response_message=Queue not found/', 
# 			'Throw IO::Iron::IronMQ::Exceptions::HTTPException when no message queue of given name.';
# 	diag("Deleted message queue " . encode_utf8($created_iron_mq_queue_02->name()) . ".");
# 	my $delete_queue_ret_03 = $iron_mq_client->delete_queue( 'name' => $unique_queue_name_03 );
# 	is($delete_queue_ret_03, 1, "Queue is deleted.");
# 	throws_ok {
# 		my $dummy = $iron_mq_client->get_queue( 'name' => $unique_queue_name_03 );
# 	} '/IronHTTPCallException: status_code=404 response_message=Queue not found/', 
# 			'Throw IO::Iron::IronMQ::Exceptions::HTTPException when no message queue of given name.';
# 	diag("Deleted message queue " . encode_utf8($created_iron_mq_queue_03->name()) . ".");
# };

done_testing();

