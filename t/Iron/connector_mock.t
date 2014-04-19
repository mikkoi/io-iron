#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Exception;

use lib 't';
#require 'iron_io_integ_tests_common.pl';

plan tests => 19;

require IO::Iron::IronCache::Client;
require IO::Iron::IronCache::Item;
require IO::Iron::ConnectorMock;

use Log::Any::Adapter ('Stderr'); # Activate to get all log messages.
use Data::Dumper; $Data::Dumper::Maxdepth = 2;

diag("Testing IO::Iron::ConnectorMock $IO::Iron::ConnectorMock::VERSION, Perl $], $^X");

## Test case
## Create cache, get cache, query all caches, get info about cache, delete cache.
## Test with multiple queues.
diag('Instantiate Mock Connector and IronCache Client.');

# Create ConnectorMock.
my $connector = IO::Iron::ConnectorMock->new();

# Create an IronMQ client.
my $iron_cache_client = IO::Iron::IronCache::Client->new( {
	'config' => 'iron_cache.json',
	'connector' => $connector,
	} );

# Create a new cache name.
my $unique_cache_name_01 = "Any_Name"; #create_unique_cache_name();

# Create a new queue.
my $created_iron_cache_01 = $iron_cache_client->create_cache($unique_cache_name_01);
isa_ok($created_iron_cache_01, "IO::Iron::IronCache::Cache", "create_cache returns a IO::Iron::IronCache::Cache.");
is($created_iron_cache_01->name(), $unique_cache_name_01, "Created cache has the given name.");
diag("Created cache '" . $unique_cache_name_01 . "'.");

# The cache does not exist yet on the server!
# It will be created once we put one item in it.
my $iron_cache_o1_item_01_key = "item_01_key";
my $iron_cache_o1_item_01 = IO::Iron::IronCache::Item->new({
	'value' => 'Item 01 value.'
	});
my $iron_cache_o1_item_01_put = $created_iron_cache_01->put($iron_cache_o1_item_01_key, $iron_cache_o1_item_01);
is($iron_cache_o1_item_01_put, 1, "Put one item into cache.");
diag("Put item into cache '" . $unique_cache_name_01 . "', item key '" . $iron_cache_o1_item_01_key . "'.");

## Query the created cache.
#my $queried_iron_cache_01 = $iron_cache_client->get_cache($unique_cache_name_01);
#isa_ok($queried_iron_cache_01 , "IO::Iron::IronCache::Cache", "create_cache returns a IO::Iron::IronCache::Cache.");
#my $queried_iron_cache_info_01 = $iron_cache_client->get_info_about_cache($unique_cache_name_01);
#is($queried_iron_cache_info_01->{'size'}, 1, "Queried cache size is 1.");
#diag("Queried cache '" . $unique_cache_name_01 . "'.");
#
## Query all caches.
#my @all_caches = $iron_cache_client->get_caches();
#my @found_caches;
#foreach my $cache (@all_caches) {
#	if($cache->name eq $unique_cache_name_01) {
#		push @found_caches, $cache;
#	}
#}
#is(scalar @found_caches, 1, "get_caches returned the one created cache.");
#
## Put an integer item.
#my $iron_cache_o1_item_02_key = "item_02_key";
#my $iron_cache_o1_item_02 = IO::Iron::IronCache::Item->new({
#	'value' => 10
#	});
#my $iron_cache_o1_item_02_put = $created_iron_cache_01->put($iron_cache_o1_item_02_key, $iron_cache_o1_item_02);
#is($iron_cache_o1_item_02_put, 1, "Put one item into cache.");
#diag("Put item into cache '" . $unique_cache_name_01 . "', item key '" . $iron_cache_o1_item_02_key . "'.");
#
## Increment item.
#my $iron_cache_o1_item_02_value = $created_iron_cache_01->increment($iron_cache_o1_item_02_key, 5);
#is($iron_cache_o1_item_02_value, 15, "Item value increased.");
#diag("Item in cache '" . $unique_cache_name_01 . "', item key '" . $iron_cache_o1_item_02_key . "', value " . $iron_cache_o1_item_02_value . " .");
#$iron_cache_o1_item_02_value = $created_iron_cache_01->increment($iron_cache_o1_item_02_key, -10);
#is($iron_cache_o1_item_02_value, 5, "Item value increased.");
#diag("Item in cache '" . $unique_cache_name_01 . "', item key '" . $iron_cache_o1_item_02_key . "', value " . $iron_cache_o1_item_02_value . " .");
#
## Get item.
#my $iron_cache_o1_item_02_get = $created_iron_cache_01->get($iron_cache_o1_item_02_key);
#isa_ok($iron_cache_o1_item_02_get , "IO::Iron::IronCache::Item", "get returns a IO::Iron::IronCache::Item.");
#is($iron_cache_o1_item_02_get->value, 5, "Item value is 5.");
#diag("Item in cache '" . $unique_cache_name_01 . "', item key '" . $iron_cache_o1_item_02_key . "', value " . $iron_cache_o1_item_02_value . " .");
#
## Delete item.
#my $iron_cache_o1_item_02_deleted = $created_iron_cache_01->delete($iron_cache_o1_item_02_key);
#is($iron_cache_o1_item_02_deleted, 1, "Item is deleted.");
##Confirm deletion.
#throws_ok {
#	my $failed_get = $created_iron_cache_01->get($iron_cache_o1_item_02_key);
#} 'IronHTTPCallException', 
#		'Throws IronHTTPCallException when cache not found with given name.';
#like($@, '/IronHTTPCallException: status_code=404 response_message=Key not found/');
#diag("Tried to get item with key " . $iron_cache_o1_item_02_key . " which does not exist. Threw ok.");
#
## Clear the cache. Confirm it is empty
#my $iron_cache_o1_cleared = $created_iron_cache_01->clear();
#is($iron_cache_o1_cleared, 1, "Cache is cleared.");
#my $queried_iron_cache_info_02 = $iron_cache_client->get_info_about_cache($unique_cache_name_01);
#is($queried_iron_cache_info_02->{'size'}, 0, "Queried cache size is 0.");
#diag("got info on cache '" . $unique_cache_name_01 . "', size is " . $queried_iron_cache_info_02->{'size'} . ".");
#
## Delete cache. Confirm deletion.
#my $delete_cache_ret_01 = $iron_cache_client->delete_cache($unique_cache_name_01);
#is($delete_cache_ret_01, 1, "Cache is deleted.");
#diag("Deleted message cache " . $created_iron_cache_01->name() . ".");
#
#throws_ok {
#	my $is_deleted = $iron_cache_client->get_cache($unique_cache_name_01);
#} 'IronHTTPCallException', 
#		'Throws IronHTTPCallException when cache not found with given name.';
#like($@, '/IronHTTPCallException: status_code=404 response_message=Cache not found/');
#diag("Tried to get cache " . $unique_cache_name_01 . " which does not exist. Threw ok.");
#
