#!perl -T
use 5.8.0;
use strict;
use warnings FATAL => 'all';
use threads;
use Test::More;
use Data::Dumper;

#plan tests => 11;
my $tct = 0; # test count

use Fdb;

#diag( "Testing basic Fdb connectivity" );
is(Fdb::select_api_version(Fdb::FDB_API_VERSION()), 0, 'Set API version');
$tct++;
is(Fdb::network_set_option(Fdb::FDB_NET_OPTION_TRACE_ENABLE, '/tmp/'), 0, 'Set option');
$tct++;
is(Fdb::setup_network(), 0, 'Network setup');
$tct++;
is(Fdb::run_network(), 0, 'Network run');
$tct++;

#diag( "Acquiring Cluster & DB handles" );
my $res;
my $cluster_f = Fdb::create_cluster(undef);
ok($cluster_f, 'Create cluster future');
$tct++;
is(Fdb::future_block_until_ready($cluster_f), 0, 'Create cluster ready');
$tct++;
my $cluster_handle;
($res, $cluster_handle) = Fdb::future_get_cluster($cluster_f);
is($res, 0, 'Get cluster handle');
$tct++;
Fdb::future_destroy($cluster_f);
my $db_f = Fdb::cluster_create_database($cluster_handle, "DB"); # Don't ever use anything other than "DB"
ok($db_f, 'Create DB future');
$tct++;
is(Fdb::future_block_until_ready($db_f), 0, 'Create DB ready');
$tct++;
my $db_handle;
($res, $db_handle) = Fdb::future_get_database($db_f);
is($res, 0, 'Get DB handle');
$tct++;
Fdb::future_destroy($db_f);

#diag( "Testing write transaction" );
my $trans;
my $committed = 0;
($res, $trans) = Fdb::database_create_transaction($db_handle);
is($res, 0, 'Create DB transaction');
$tct++;
while ($committed == 0) {
  Fdb::transaction_set($trans, "TestKey", "TestValue");
  my $commit_f = Fdb::transaction_commit($trans);
  is (Fdb::future_block_until_ready($commit_f), 0, 'Transaction commit ready');
  $tct++;
  if (Fdb::future_is_error($commit_f)) {
    my ($err, $err_desc) = Fdb::future_get_error($commit_f);
    my $err_f = Fdb::transaction_on_error($trans, $err);
    if (Fdb::future_block_until_ready($err_f) != 0) {
      fail('Transaction write commit');
    }
    Fdb::future_destroy($err_f);
  } else {
    $committed = 1;
  }
  Fdb::future_destroy($commit_f);
}
Fdb::transaction_reset($trans);

#diag( "Testing read transaction" );
my $tr_f = Fdb::transaction_get($trans, "TestKey", 0);
Fdb::future_block_until_ready($tr_f);
if (Fdb::future_is_error($tr_f)) {
  my ($err, $err_desc) = Fdb::future_get_error($tr_f);
  my $err_f = Fdb::transaction_on_error($trans, $err);
  if (Fdb::future_block_until_ready($err_f) != 0) {
    fail('Transaction read commit');
  }
  Fdb::future_destroy($err_f);
}
my ($out_val, $bool);
($res, $bool, $out_val) = Fdb::future_get_value($tr_f);
is ($res, 0);
$tct++;
is ($out_val, "TestValue");
$tct++;

Fdb::transaction_destroy($trans);
Fdb::future_destroy($tr_f);

# cleanup
Fdb::database_destroy($db_handle);
Fdb::cluster_destroy($cluster_handle);
is(Fdb::stop_network(), 0, 'Network stopped');
$tct++;
done_testing($tct);
