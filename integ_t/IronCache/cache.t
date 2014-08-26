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
require 'iron_io_integ_tests_common.pl';

plan tests => 3;

require IO::Iron::IronCache::Client;
require IO::Iron::IronCache::Item;

#use Log::Any::Adapter ('Stderr'); # Activate to get all log messages.
use Data::Dumper; $Data::Dumper::Maxdepth = 2;

diag("Testing IO::Iron::IronCache::Client, Perl $], $^X");

## Test case
## Create cache, get cache, query all caches, get info about cache, delete cache.
## Test with multiple queues.
diag('Testing IO::Iron::IronCache::Client');

my $project_id;
my $iron_cache_client;
my $unique_cache_name_01;
my $created_iron_cache_01;
subtest 'Setup for testing' => sub {
	plan tests => 3;
	# Create an IronCache client.
	$iron_cache_client = IO::Iron::IronCache::Client->new(
		'config' => 'iron_cache.json'
	);
	$project_id = $iron_cache_client->{'connection'}->{'project_id'};
	# Use $project_id for log message comparisons.
	
	# Create a new cache name.
	$unique_cache_name_01 = create_unique_cache_name();
	$unique_cache_name_01 =~ tr/-/_/;
	
	# Create a new cache.
	$created_iron_cache_01 = $iron_cache_client->create_cache(
		'name' => $unique_cache_name_01
	);
	isa_ok($created_iron_cache_01, "IO::Iron::IronCache::Cache", "create_cache returns a IO::Iron::IronCache::Cache.");
	#diag(Dumper($iron_cache_client->{'caches'}));
	is(scalar @{$iron_cache_client->{'caches'}}, 1, "iron_cache_client->{caches} contains the one created cache.");
	is($created_iron_cache_01->name(), $unique_cache_name_01, "Created cache has the given name.");
	diag("Created cache '" . $unique_cache_name_01 . "'.");
};

subtest 'Put and query items' => sub {
	plan tests => 20;

	# The cache does not exist yet on the server!
	# It will be created once we put one item in it.
	my $iron_cache_o1_item_01_key = "item_01_key";
	my $iron_cache_o1_item_01 = IO::Iron::IronCache::Item->new(
		'value' => 'Item 01 value.'
	);
	$log->clear();
	my $iron_cache_o1_item_01_put = $created_iron_cache_01->put(
		'key' => $iron_cache_o1_item_01_key,
		'item' => $iron_cache_o1_item_01,
	);
	my $log_test = 0;
	my $log_message = "(project=$project_id, cache=$unique_cache_name_01, item=$iron_cache_o1_item_01_key). Put item into cache. Value: 'Item 01 value.', Expires in: '', Replace: '', Put: '', Cas: ''.";
	#diag(Dumper($log->msgs));
	map { $log_test = 1 if ($_->{'level'} eq 'info' 
			&& $_->{'category'} eq 'IO::Iron::Connection' 
			&& $_->{'message'} eq $log_message
		) } @{$log->msgs};
	is($log_test, 1, 'Put() logged correctly.');
	is($iron_cache_o1_item_01_put, 1, "Put one item into cache.");
	diag("Put item into cache '" . $unique_cache_name_01 . "', item key '" . $iron_cache_o1_item_01_key . "'.");
	
	# Query the created cache.
	my $queried_iron_cache_01 = $iron_cache_client->get_cache(
		'name' => $unique_cache_name_01
	);
	isa_ok($queried_iron_cache_01 , "IO::Iron::IronCache::Cache", "get_cache returns an object of class IO::Iron::IronCache::Cache.");
	$log->clear();
	my $queried_iron_cache_info_01 = $iron_cache_client->get_info_about_cache(
		'name' => $unique_cache_name_01
	);
	$log_message = "(project=$project_id, cache=$unique_cache_name_01, item=$iron_cache_o1_item_01_key). Got info about a cache.";
	map { $log_test = 1 if ($_->{'level'} eq 'info' 
			&& $_->{'category'} eq 'IO::Iron::Connection' 
			&& $_->{'message'} eq $log_message
		) } @{$log->msgs};
	is($log_test, 1, 'get_cache() logged correctly.');
	is($queried_iron_cache_info_01->{'size'}, 1, "Queried cache size is 1.");
	diag("Queried cache '" . $unique_cache_name_01 . "'.");
	
	# Query all caches.
	$log->clear();
	my @all_caches = $iron_cache_client->get_caches();
	$log_message = "(project=$project_id, cache=$unique_cache_name_01, item=$iron_cache_o1_item_01_key). Listed caches.";
	map { $log_test = 1 if ($_->{'level'} eq 'info' 
			&& $_->{'category'} eq 'IO::Iron::Connection' 
			&& $_->{'message'} eq $log_message
		) } @{$log->msgs};
	is($log_test, 1, 'get_caches() logged correctly.');
	my @found_caches;
	foreach my $cache (@all_caches) {
		if($cache->name() eq $unique_cache_name_01) {
			push @found_caches, $cache;
		}
	}
	is(scalar @found_caches, 1, "get_caches returned the one created cache.");
	
	# Put an integer item.
	my $iron_cache_o1_item_02_key = "item_02_key";
	my $iron_cache_o1_item_02 = IO::Iron::IronCache::Item->new(
		'value' => 10
	);
	my $iron_cache_o1_item_02_put = $created_iron_cache_01->put(
		'key' => $iron_cache_o1_item_02_key,
		'item' => $iron_cache_o1_item_02
	);
	is($iron_cache_o1_item_02_put, 1, "Put one item into cache.");
	diag("Put item into cache '" . $unique_cache_name_01 . "', item key '" . $iron_cache_o1_item_02_key . "'.");
	
	# Increment item.
	$log->clear();
	my $iron_cache_o1_item_02_value = $created_iron_cache_01->increment(
		'key' => $iron_cache_o1_item_02_key,
		'increment' => 5
	);
	$log_message = "(project=$project_id, cache=$unique_cache_name_01, item=$iron_cache_o1_item_01_key). Incremented items value by '5'.";
	map { $log_test = 1 if ($_->{'level'} eq 'info' 
			&& $_->{'category'} eq 'IO::Iron::Connection' 
			&& $_->{'message'} eq $log_message
		) } @{$log->msgs};
	is($log_test, 1, 'increment() logged correctly.');
	is($iron_cache_o1_item_02_value, 15, "Item value increased.");
	diag("Item in cache '" . $unique_cache_name_01 . "', item key '" . $iron_cache_o1_item_02_key . "', value " . $iron_cache_o1_item_02_value . " .");
	$iron_cache_o1_item_02_value = $created_iron_cache_01->increment(
		'key' => $iron_cache_o1_item_02_key,
		'increment' => -10,
	);
	is($iron_cache_o1_item_02_value, 5, "Item value increased.");
	diag("Item in cache '" . $unique_cache_name_01 . "', item key '" . $iron_cache_o1_item_02_key . "', value " . $iron_cache_o1_item_02_value . " .");
	
	# Get item.
	$log->clear();
	my $iron_cache_o1_item_02_get = $created_iron_cache_01->get(
		'key' => $iron_cache_o1_item_02_key
	);
	$log_message = "(project=$project_id, cache=$unique_cache_name_01, item=$iron_cache_o1_item_01_key). Got item from cache.";
	map { $log_test = 1 if ($_->{'level'} eq 'info' 
			&& $_->{'category'} eq 'IO::Iron::Connection' 
			&& $_->{'message'} eq $log_message
		) } @{$log->msgs};
	is($log_test, 1, 'get() logged correctly.');
	isa_ok($iron_cache_o1_item_02_get , "IO::Iron::IronCache::Item", "get returns an object of class IO::Iron::IronCache::Item.");
	is($iron_cache_o1_item_02_get->value, 5, "Item value is 5.");
	diag("Item in cache '" . $unique_cache_name_01 . "', item key '" . $iron_cache_o1_item_02_key . "', value " . $iron_cache_o1_item_02_value . " .");
	
	# Delete item.
	$log->clear();
	my $iron_cache_o1_item_02_deleted = $created_iron_cache_01->delete(
		'key' => $iron_cache_o1_item_02_key
	);
	$log_message = "(project=$project_id, cache=$unique_cache_name_01, item=$iron_cache_o1_item_01_key). Deleted item from cache.";
	map { $log_test = 1 if ($_->{'level'} eq 'info' 
			&& $_->{'category'} eq 'IO::Iron::Connection' 
			&& $_->{'message'} eq $log_message
		) } @{$log->msgs};
	is($log_test, 1, 'delete() logged correctly.');
	is($iron_cache_o1_item_02_deleted, 1, "Item is deleted.");
	#Confirm deletion.
	throws_ok {
		my $failed_get = $created_iron_cache_01->get(
			'key' => $iron_cache_o1_item_02_key
		);
	} 'IronHTTPCallException', 
			'Throws IronHTTPCallException when cache not found with given name.';
	like($@, '/IronHTTPCallException: status_code=404 response_message=Key not found/');
	diag("Tried to get item with key " . $iron_cache_o1_item_02_key . " which does not exist. Threw ok.");

    # Let's test with different serializers, just for fun (and for certainty).
    # Shouldn't matter, though, since cache values are just plain strings 
    # from IronCache's point of view.
    diag("Test with JSON in JSON.");
    require JSON::MaybeXS;
    $Data::Dumper::Maxdepth = 6;
    my $json = JSON::MaybeXS->new(utf8 => 1, pretty => 1);
    my $iron_cache_o1_item_03_key = "item_01_key";
    my %iron_cache_o1_item_03_value_hash = 
        ( 'main' => { 'level_1_item_1' => 'S', 
                'level_1_sub_1' => {'level_2_item_1' => 'T'}, 
                'level_1_item_2' => 'SS'
            },
        );
    my $iron_cache_o1_item_03_value = $json->encode(\%iron_cache_o1_item_03_value_hash);
    my $iron_cache_o1_item_03 = IO::Iron::IronCache::Item->new(
        'value' => $iron_cache_o1_item_03_value
    );
    my $iron_cache_o1_item_03_put = $created_iron_cache_01->put(
        'key' => $iron_cache_o1_item_03_key,
        'item' => $iron_cache_o1_item_03,
    );
    my $got_item_03 = $created_iron_cache_01->get(
        'key' => $iron_cache_o1_item_03_key
    );
    #diag("returned item_03:" . Dumper($got_item_03));
    my $got_item_03_value_hash = $json->decode($got_item_03->value());
    #is(Dumper($got_item_03_value_hash), Dumper(\%iron_cache_o1_item_03_value_hash), "Returned dumped hash equals to original dumper hash.");
    is_deeply($got_item_03_value_hash, \%iron_cache_o1_item_03_value_hash, "Returned dumped hash equals to original dumper hash.");
    $Data::Dumper::Maxdepth = 2;

    diag("Test with perl Storable serializer module.");
    require Storable;
    $Data::Dumper::Maxdepth = 6;
    my $iron_cache_o1_item_04_key = "item_01_key";
    my %iron_cache_o1_item_04_value_hash = 
        ( 'main' => { 'level_1_item_1' => 'S', 
                'level_1_sub_1' => {'level_2_item_1' => 'T'}, 
                'level_1_item_2' => 'SS'
            },
        );
    my $iron_cache_o1_item_04_value = Storable::freeze(\%iron_cache_o1_item_04_value_hash);
    my $iron_cache_o1_item_04 = IO::Iron::IronCache::Item->new(
        'value' => $iron_cache_o1_item_04_value
    );
    my $iron_cache_o1_item_04_put = $created_iron_cache_01->put(
        'key' => $iron_cache_o1_item_04_key,
        'item' => $iron_cache_o1_item_04,
    );
    my $got_item_04 = $created_iron_cache_01->get(
        'key' => $iron_cache_o1_item_04_key
    );
    #diag("returned item_04:" . Dumper($got_item_04));
    my $got_item_04_value_hash = Storable::thaw($got_item_04->value());
    is_deeply($got_item_04_value_hash, \%iron_cache_o1_item_04_value_hash, "Returned dumped hash equals to original dumper hash.");
    $Data::Dumper::Maxdepth = 2;

};

subtest 'Clean up.' => sub {
	plan tests => 9;

	# Clear the cache. Confirm it is empty
    my $queried_iron_cache_info_02 = $iron_cache_client->get_info_about_cache(
        'name' => $unique_cache_name_01
    );
    is($queried_iron_cache_info_02->{'size'}, 1, "Queried cache size is still 1. Item 1 is there.");
	$log->clear();
	my $iron_cache_o1_cleared = $created_iron_cache_01->clear();
	my $log_message = "(project=$project_id, cache=$unique_cache_name_01). Cleared cache.";
	my $log_test = 0;
	map { $log_test = 1 if ($_->{'level'} eq 'info' 
			&& $_->{'category'} eq 'IO::Iron::Connection' 
			&& $_->{'message'} eq $log_message
		) } @{$log->msgs};
	is($log_test, 1, 'clear() logged correctly.');
	is($iron_cache_o1_cleared, 1, "Cache is cleared.");
	$queried_iron_cache_info_02 = $iron_cache_client->get_info_about_cache(
		'name' => $unique_cache_name_01
	);
	is($queried_iron_cache_info_02->{'size'}, 0, "Queried cache size is 0.");
	diag("got info on cache '" . $unique_cache_name_01 . "', size is " . $queried_iron_cache_info_02->{'size'} . ".");
	
	# Delete cache. Confirm deletion.
	$log->clear();
	my $delete_cache_ret_01 = $iron_cache_client->delete_cache(
		'name' => $unique_cache_name_01
	);
	$log_message = "(project=$project_id, cache=$unique_cache_name_01). Deleted cache.";
	map { $log_test = 1 if ($_->{'level'} eq 'info' 
			&& $_->{'category'} eq 'IO::Iron::Connection' 
			&& $_->{'message'} eq $log_message
		) } @{$log->msgs};
	is($log_test, 1, 'delete() logged correctly.');
	is($delete_cache_ret_01, 1, "Cache is deleted.");
	my @found_caches;
	#diag(Dumper($iron_cache_client->{'caches'}));
	foreach my $cache (@{$iron_cache_client->{'caches'}}) {
		if($cache->name() eq $unique_cache_name_01) {
			push @found_caches, $cache;
		}
	}
	is(scalar @found_caches, 0, "iron_cache_client->{caches} does not contain the one deleted cache.");
	diag("Deleted message cache '" . $created_iron_cache_01->name() . "'.");
	
	throws_ok {
		my $is_deleted = $iron_cache_client->get_cache(
			'name' => $unique_cache_name_01
		);
	} 'IronHTTPCallException', 
			'Throws IronHTTPCallException when cache not found with given name.';
	like($@, '/IronHTTPCallException: status_code=404 response_message=Cache not found/');
	diag("Tried to get cache '" . $unique_cache_name_01 . "' which does not exist. Threw ok.");
};
