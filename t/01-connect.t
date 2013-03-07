#!perl -T
use 5.8.0;
use strict;
use warnings FATAL => 'all';
use threads;
use Test::More;
use Data::Dumper;

plan tests => 11;

use Fdb;
is(Fdb::select_api_version(Fdb::FDB_API_VERSION()), 0, 'Set API version');
is(Fdb::network_set_option(Fdb::FDB_NET_OPTION_TRACE_ENABLE, '/tmp/'), 0, 'Set option');
is(Fdb::setup_network(), 0, 'Network setup');
is(Fdb::run_network(), 0, 'Network run');

my $res;
my $cluster_f = Fdb::create_cluster(undef);
ok($cluster_f, 'Create cluster future');
is(Fdb::future_block_until_ready($cluster_f), 0, 'Create cluster ready');
my $cluster_handle;
($res, $cluster_handle) = Fdb::future_get_cluster($cluster_f);
is($res, 0, 'Get cluster handle');
Fdb::future_destroy($cluster_f);
my $db_f = Fdb::cluster_create_database($cluster_handle, "TEST_DB");
ok($db_f, 'Create DB future');
is(Fdb::future_block_until_ready($db_f), 0, 'Create DB ready');
my $db_handle;
($res, $db_handle) = Fdb::future_get_database($db_f);
is($res, 0, 'Get DB handle');
Fdb::future_destroy($db_f);

Fdb::database_destroy($db_handle);
Fdb::cluster_destroy($cluster_handle);

is(Fdb::stop_network(), 0, 'Network stopped');
diag( "Testing basic Fdb connectivity" );
