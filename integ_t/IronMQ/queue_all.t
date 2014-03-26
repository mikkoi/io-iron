#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Exception;

use lib 't';
use lib 'integ_t';
use common;

plan tests => 6;

require IO::Iron::IronMQ::Client;
require IO::Iron::IronMQ::Message;

#use Log::Any::Adapter ('Stderr'); # Activate to get all log messages.
use Data::Dumper; $Data::Dumper::Maxdepth = 2;

diag("Testing IO::Iron::IronMQ::Client, Perl $], $^X");

## Test case
diag('Testing IO::Iron::IronMQ::Client');

my $iron_mq_client;
my $unique_queue_name_01;
my @send_messages;
my $created_iron_mq_queue_01;
my %msg_body_hash_02;
subtest 'Setup for testing' => sub {
	plan tests => 2;
	# Create an IronMQ client.
	$iron_mq_client = IO::Iron::IronMQ::Client->new( 'config' => 'iron_mq.json' );
	
	# Create a new queue name.
	$unique_queue_name_01 = common::create_unique_queue_name();
	
	# Create a new queue.
	$created_iron_mq_queue_01 = $iron_mq_client->create_queue( 'name' => $unique_queue_name_01 );
	isa_ok($created_iron_mq_queue_01, "IO::Iron::IronMQ::Queue", "create_queue returns a IO::Iron::IronMQ::Queue.");
	is($created_iron_mq_queue_01->name(), $unique_queue_name_01, "Created queue has the given name.");
	diag("Created message queue " . $unique_queue_name_01 . ".");
	
	# Let's create some messages
	my $iron_mq_msg_send_01 = IO::Iron::IronMQ::Message->new(
			'body' => 'My message #01',
			);
	use YAML::Tiny; # For serializing/deserializing a hash.
	%msg_body_hash_02 = (msg_body_text => 'My message #02', msg_body_item => {sub_item => 'Sub text'});
	my $yaml = YAML::Tiny->new(); $yaml->[0] = \%msg_body_hash_02;
	my $msg_body = $yaml->write_string();
	my $iron_mq_msg_send_02 = IO::Iron::IronMQ::Message->new(
			'body' => $msg_body,
			'timeout' => 60, # When reading from queue, after timeout (in seconds), item will be placed back onto queue.
			'delay' => 0,	 # The item will not be available on the queue until this many seconds have passed.
			'expires_in' => 60, # How long in seconds to keep the item on the queue before it is deleted.
			);
	my ($iron_mq_msg_send_03, $iron_mq_msg_send_04, $iron_mq_msg_send_05, $iron_mq_msg_send_06);
	{ use utf8;
		$iron_mq_msg_send_03 = IO::Iron::IronMQ::Message->new( 'body' => 'My message #03'  . '_latin1' );
		$iron_mq_msg_send_04 = IO::Iron::IronMQ::Message->new( 'body' => 'My message #04'  . '_räksmörgås' );
		$iron_mq_msg_send_05 = IO::Iron::IronMQ::Message->new( 'body' => 'My message #05'  . '_三明治' );
		$iron_mq_msg_send_06 = IO::Iron::IronMQ::Message->new( 'body' => 'My message #06' );
	}
	push @send_messages, $iron_mq_msg_send_01, $iron_mq_msg_send_02, $iron_mq_msg_send_03, $iron_mq_msg_send_04, $iron_mq_msg_send_05, $iron_mq_msg_send_06;
	diag("Created 6 messages for sending.");
};

my @send_message_ids;
subtest 'Push the messages' => sub {
	plan tests => 7;
	#Queue is empty
	my @msg_pulls_00 = $created_iron_mq_queue_01->pull( 'n' => 2, timeout => 120 );
	is(scalar @msg_pulls_00, 0, 'No messages pulled from queue, size 0.');
	is($created_iron_mq_queue_01->size(), 0, 'Queue size is 0.');
	diag("Empty queue at the start.");
	
	# Let's send the messages.
	my $msg_send_id_01 = $created_iron_mq_queue_01->push( 'messages' => [ $send_messages[0] ] );
	is($created_iron_mq_queue_01->size(), 1, 'One message pushed, queue size is 1.');
	
	my @msg_send_ids_02 = $created_iron_mq_queue_01->push( 'messages' => [ @send_messages[1,2] ] );
	is(scalar @msg_send_ids_02, 2, 'Two messages pushed');
	is($created_iron_mq_queue_01->size(), 3, 'Two messages pushed, queue size is 3.');
	
	my $number_of_msgs_sent = $created_iron_mq_queue_01->push( 'messages' => [ @send_messages[3,4,5] ] );
	is($number_of_msgs_sent, 3, 'Three more messages pushed.');
	is($created_iron_mq_queue_01->size(), 6, 'Three more messages pushed, queue size is 6.');
	diag("6 messages pushed to queue.");
	push @send_message_ids, $msg_send_id_01, @msg_send_ids_02;
};

my @msg_pulls_01;
my @msg_pulls_02;
subtest 'Pull and peek' => sub {
	plan tests => 10;
	# Let's pull some messages.
	@msg_pulls_01 = $created_iron_mq_queue_01->pull();
	is($msg_pulls_01[0]->id(), $send_message_ids[0], 'Pulled the 1st message.');
	is($msg_pulls_01[0]->body(), $send_messages[0]->body(), '1st message body equals to sent message body.');
	
	@msg_pulls_02 = $created_iron_mq_queue_01->pull( 'n' => 2, timeout => 120 );
	my $yaml_de = YAML::Tiny->new(); $yaml_de = $yaml_de->read_string($msg_pulls_02[0]->body());
	is_deeply($yaml_de->[0], \%msg_body_hash_02, '#2 message body after serialization matches with the sent message body.');
	
	is( $msg_pulls_02[0]->id(), $send_message_ids[1], 'Pulled two, ids match with the sent ids.');
	is( $msg_pulls_02[1]->id(), $send_message_ids[2], 'Pulled two, ids match with the sent ids.');
	is($created_iron_mq_queue_01->size(), 6, 'Three messages pulled in total; put queue size is still 6. (pull does not delete messages.)');
	diag("Pulled 3 messages from queue.");
	
	# Let's peek some messages.
	my @msg_peeks_04 = $created_iron_mq_queue_01->peek();
	is($msg_peeks_04[0]->body(), $send_messages[3]->body(), 'Peeked the 4th message. Body equals to sent message body.');
	
	my @msg_peeked_05 = $created_iron_mq_queue_01->peek( 'n' => 3 );
	is( $msg_peeked_05[0]->body(), $send_messages[3]->body(), 'Peeked 3 messages, the first message was already peeked last time (peek does not reserve messages).');
	is( $msg_peeked_05[1]->body(), $send_messages[4]->body(), 'Peeked 3, second message body equals to sent message body.');
	is( $msg_peeked_05[2]->body(), $send_messages[5]->body(), 'Peeked 3, third message body equals to sent message body.');
	diag("Peeked 3 messages from queue.");
};

my @msg_pulls_04;
my @msg_pulls_11;
subtest 'Pull and release' => sub {
	plan tests => 8;
	# Let's touch some messages.
	
	#Pull the rest first
	@msg_pulls_04 = $created_iron_mq_queue_01->pull( 'n' => 3, timeout => 120 );
	is($created_iron_mq_queue_01->size(), 6, 'All 6 messages in queue, all reserved');
	
	my $touched_msg_id1 = $created_iron_mq_queue_01->touch('id' => $msg_pulls_01[0]->id());
	is($touched_msg_id1, 1, "Touch succeeded. Would cause exception otherwise.");
	my $touched_msg_id2 = $created_iron_mq_queue_01->touch('id' => $msg_pulls_02[0]->id());
	my $touched_msg_id3 = $created_iron_mq_queue_01->touch('id' => $msg_pulls_02[1]->id());
	is($touched_msg_id2, 1, 'Touch succeeded.');
	my $more_msgs_touched1 = $created_iron_mq_queue_01->touch('id' => $msg_pulls_04[0]->id());
	my $more_msgs_touched2 = $created_iron_mq_queue_01->touch('id' => $msg_pulls_04[1]->id());
	my $more_msgs_touched3 = $created_iron_mq_queue_01->touch('id' => $msg_pulls_04[2]->id());
	is($more_msgs_touched1, 1, 'Touched succeeded.');
	
	# Let's release some messages.
	
	#Queue is not empty but we can not read any messages.
	my @msg_pulls_10 = $created_iron_mq_queue_01->pull( 'n' => 2, timeout => 120 );
	is(scalar @msg_pulls_10, 0, 'No messages pulled from queue, size 6.');
	is($created_iron_mq_queue_01->size(), 6, 'Queue size is 6.');
	
	my $released_msg_id1 = $created_iron_mq_queue_01->release('id' => $msg_pulls_01[0]->id());
	my $released_msg_id2 = $created_iron_mq_queue_01->release('id' => $msg_pulls_02[0]->id(), 'delay' => 0);
	my $released_msg_id3 = $created_iron_mq_queue_01->release('id' => $msg_pulls_02[1]->id());
	
	# Now we can read back the released messages.
	@msg_pulls_11 = $created_iron_mq_queue_01->pull( 'n' => 3, timeout => 120 );
	is(scalar @msg_pulls_11, 3, 'No messages pulled from queue, size 6.');
	is($created_iron_mq_queue_01->size(), 6, 'Queue size is 6.');
};

subtest 'Delete' => sub {
	plan tests => 3;
	# Let's delete some messages
	my $deleted_msg_id = $created_iron_mq_queue_01->delete( 'ids' => [ $msg_pulls_11[0]->id() ] );
	is($created_iron_mq_queue_01->size(), 5, 'Deleted 1 message, queue size is 5.');
	
	my @deleted_msg_ids = $created_iron_mq_queue_01->delete( 'ids' => [ $msg_pulls_11[1]->id(), $msg_pulls_11[2]->id() ] );
	is($created_iron_mq_queue_01->size(), 3, 'Deleted 2 message, queue size is 3.');
	my $number_of_msgs_deleted = $created_iron_mq_queue_01->delete( 'ids' => [ $msg_pulls_04[0]->id() ] );
	is($created_iron_mq_queue_01->size(), 2, 'Deleted 1 message, queue size is 2.');
	diag("Deleted in total 4 messages from the queue.");
};

subtest 'Clean up.' => sub {
	plan tests => 3;
	# Let's clear the queue
	my $queue_cleared = $created_iron_mq_queue_01->clear();
	is($created_iron_mq_queue_01->size(), 0, 'Cleared the queue, queue size is 0.');
	diag("Cleared the queue, queue size is 0.");
	
	# Delete queue. Confirm deletion.
	my $delete_queue_ret_01 = $iron_mq_client->delete_queue( 'name' => $unique_queue_name_01 );
	is($delete_queue_ret_01, 1, "Queue is deleted.");
	throws_ok {
		my $dummy = $iron_mq_client->get_queue( 'name' => $unique_queue_name_01 );
	} '/IronHTTPCallException: status_code=404 response_message=Queue not found/', 
			'Throw IronHTTPCallException when no message queue of given name.';
	diag("Deleted message queue " . $created_iron_mq_queue_01->name() . ".");
};
