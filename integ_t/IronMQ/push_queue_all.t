#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Exception;
use JSON ();

use lib 't';
use lib 'integ_t';
use common;

plan tests => 4;

require IO::Iron::IronMQ::Client;
require IO::Iron::IronMQ::Message;

#use Log::Any::Adapter ('Stderr'); # Activate to get all log messages.
use Data::Dumper; $Data::Dumper::Maxdepth = 2;

diag("Testing IO::Iron::IronMQ::Client, Perl $], $^X");

## Test case
diag('Testing IO::Iron::IronMQ::Client');

my $iron_mq_client;
my $unique_queue_name_01;
my $unique_queue_name_02;
my $unique_queue_name_03;
my @send_messages;
my $push_from_queue;
my $push_to_queue;
my $error_queue;
my %msg_body_hash_02;
subtest 'Setup for testing' => sub {
	plan tests => 6;
	# Create an IronMQ client.
	$iron_mq_client = IO::Iron::IronMQ::Client->new( 'config' => 'iron_mq.json' );
	
	# Create new queue names.
	$unique_queue_name_01 = common::create_unique_queue_name() . '_push_from';
	$unique_queue_name_02 = common::create_unique_queue_name() . '_push_to';
	$unique_queue_name_03 = common::create_unique_queue_name() . '_error';

	# Create new queues.
	$push_from_queue = $iron_mq_client->create_queue(
			'name' => $unique_queue_name_01,
			'subscribers' => [
				{ "url" => "ironmq:///$unique_queue_name_02" },
			],
			'push_type' => 'unicast',
			'retries' => 0,
			'retries_delay' => 3,
			'error_queue' => $unique_queue_name_03,
		);
	isa_ok($push_from_queue, "IO::Iron::IronMQ::Queue", "create_queue returns a IO::Iron::IronMQ::Queue.");
	is($push_from_queue->name(), $unique_queue_name_01, "Created queue has the given name.");
	diag("Created push_from message queue " . $unique_queue_name_01 . ".");
	$push_to_queue = $iron_mq_client->create_queue( 'name' => $unique_queue_name_02 );
	isa_ok($push_to_queue, "IO::Iron::IronMQ::Queue", "create_queue returns a IO::Iron::IronMQ::Queue.");
	is($push_to_queue->name(), $unique_queue_name_02, "Created queue has the given name.");
	diag("Created push_to message queue " . $unique_queue_name_02 . ".");
	$error_queue = $iron_mq_client->create_queue( 'name' => $unique_queue_name_03 );
	isa_ok($error_queue, "IO::Iron::IronMQ::Queue", "create_queue returns a IO::Iron::IronMQ::Queue.");
	is($error_queue->name(), $unique_queue_name_03, "Created queue has the given name.");
	diag("Created error message queue " . $unique_queue_name_03 . ".");
	
	# Let's create some messages
	my $iron_mq_msg_send_01 = IO::Iron::IronMQ::Message->new( 'body' => 'My message #01' );
	my $iron_mq_msg_send_02 = IO::Iron::IronMQ::Message->new( 'body' => 'My message #02' );
	my $iron_mq_msg_send_03 = IO::Iron::IronMQ::Message->new( 'body' => 'My message #03' );
	my $iron_mq_msg_send_04 = IO::Iron::IronMQ::Message->new( 'body' => 'My message #04' );
	my $iron_mq_msg_send_05 = IO::Iron::IronMQ::Message->new( 'body' => 'My message #05' );
	my $iron_mq_msg_send_06 = IO::Iron::IronMQ::Message->new( 'body' => 'My message #06' );
	push @send_messages, $iron_mq_msg_send_01, $iron_mq_msg_send_02, $iron_mq_msg_send_03,
		$iron_mq_msg_send_04, $iron_mq_msg_send_05, $iron_mq_msg_send_06;
	diag("Created 6 messages for sending.");
};

my @send_message_ids;
subtest 'Push the first message' => sub {
	plan tests => 3;
	#Queue is empty
	my @msg_pulls_00 = $push_to_queue->pull( 'n' => 2, timeout => 120 );
	is(scalar @msg_pulls_00, 0, 'No messages pulled from push to queue, size 0.');
	is($push_to_queue->size(), 0, 'Push to Queue size is 0.');
	diag("Empty push to queue at the start.");
	
	# Let's send the messages.
	my $msg_send_id_01 = $push_from_queue->push( 'messages' => [ $send_messages[0] ] );
	diag("Waiting until push to queue has a message...");
	until ($push_to_queue->size() > 0) {
		sleep 1;
		diag("Waiting until push to queue has a message...");
	}
	is($push_to_queue->size(), 1, 'One message pushed, push to queue size is 1.');
	push @send_message_ids, $msg_send_id_01;
};

my @msg_pulls_01;
my @msg_pulls_02;
subtest 'Push and pull' => sub {
	plan tests => 14;
	# Let's pull some messages.
	@msg_pulls_01 = $push_to_queue->pull();
	isnt($msg_pulls_01[0]->id(), $send_message_ids[0], 'Message ids are not same because the queue is not the same.');
	is($msg_pulls_01[0]->body(), $send_messages[0]->body(), '1st message body equals to sent message body.');
	$push_to_queue->delete( 'ids' => [ $msg_pulls_01[0]->id() ]);
	is($push_to_queue->size(), 0, 'One message pulled and deleted, push to queue size is 0.');

	# Delete a subscriber and put a new one (a non existing project)
	my $del_ret_val = $iron_mq_client->delete_subscribers(
			'name' => $unique_queue_name_01,
			'subscribers' => [
				{ 'url' => "ironmq:///$unique_queue_name_02" },
			],
		);
	is($del_ret_val, 1, 'delete_subscribers returns 1.');
	my $add_ret_val = $iron_mq_client->add_subscribers(
			'name' => $unique_queue_name_01,
			'subscribers' => [
				{ 'url' => "ironmq://non_existing_project_id:non_existing_token\@non_existing_host/non_existing_queue_name" },
			],
		);
	is($add_ret_val, 1, 'add_subscribers returns 1.');

	# Push a message (which will go to error)
	my $msg_send_id_01 = $push_from_queue->push( 'messages' => [ $send_messages[1] ] );
	diag("Waiting until error queue has a message...");
	until ($error_queue->size() > 0) {
		sleep 1;
		diag("Waiting until error queue has a message...Might take some time");
	}
	is($error_queue->size(), 1, 'One message pushed to non-existing address, error queue size is 1.');
	push @send_message_ids, $msg_send_id_01;
	@msg_pulls_01 = $error_queue->pull();
	#diag("IO::Iron::IronMQ::Message: " . Dumper($msg_pulls_01[0]));
	my $error_msg_content = JSON::decode_json($msg_pulls_01[0]->body());
	#diag(Dumper($error_msg_content));
	diag("Iron.io returned error: " . $error_msg_content->{'msg'});
	isnt($msg_pulls_01[0]->id(), $send_message_ids[0], 'Message ids are not same because the queue is not the same.');
	is($error_msg_content->{'source_msg_id'}, $send_message_ids[1], 'Message ids are the same.');
	$error_queue->delete( 'ids' => [ $msg_pulls_01[0]->id() ]);
	is($error_queue->size(), 0, 'One message pulled and deleted, error queue size is 0.');

	# Query push status for the failed message.
	my $r_hash = $error_queue->get_push_status( 'id' => $send_message_ids[1]);
	#diag("Iron.io returned: " . Dumper($r_hash));
	my @subscribers = (@{$r_hash->{'subscribers'}});
	#diag("Subscribers: " . Dumper(\@subscribers));
	is(scalar @subscribers, 1, "Only one subscriber for the message.");
	is($subscribers[0]->{'status'}, 'error', "Status is error.");
	is($subscribers[0]->{'status_code'}, 0, "Status code is 0.");

	# Update the first queue to a normal queue (from a push queue).
	$push_from_queue = $iron_mq_client->update_queue(
			'name' => $unique_queue_name_01,
			'push_type' => 'pull',
		);
	isa_ok($push_from_queue, "IO::Iron::IronMQ::Queue", "create_queue returns a IO::Iron::IronMQ::Queue.");
	is($push_from_queue->name(), $unique_queue_name_01, "Created queue has the given name.");
	diag("Updated push_from message queue " . $unique_queue_name_01 . " to a normal queue.");

};

subtest 'Clean up.' => sub {
	plan tests => 6;
	# Let's clear the queues
	$push_from_queue->clear();
	is($push_from_queue->size(), 0, 'Cleared the push from queue, queue size is 0.');
	diag("Cleared the push from queue, queue size is 0.");
	$push_to_queue->clear();
	is($push_to_queue->size(), 0, 'Cleared the push to queue, queue size is 0.');
	diag("Cleared the push to queue, queue size is 0.");
	$error_queue->clear();
	is($error_queue->size(), 0, 'Cleared the error queue, queue size is 0.');
	diag("Cleared the error queue, queue size is 0.");
	
	# Delete queues. Confirm deletion.
	my $delete_queue_ret_01 = $iron_mq_client->delete_queue( 'name' => $unique_queue_name_01 );
	is($delete_queue_ret_01, 1, "Push from Queue is deleted.");
	diag("Deleted message queue " . $push_from_queue->name() . ".");
	my $delete_queue_ret_02 = $iron_mq_client->delete_queue( 'name' => $unique_queue_name_02 );
	is($delete_queue_ret_02, 1, "Push to Queue is deleted.");
	diag("Deleted message queue " . $push_to_queue->name() . ".");
	my $delete_queue_ret_03 = $iron_mq_client->delete_queue( 'name' => $unique_queue_name_03 );
	is($delete_queue_ret_03, 1, "Error Queue is deleted.");
	diag("Deleted message queue " . $error_queue->name() . ".");
};
