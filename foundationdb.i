/*
 * Warning: This file is to generate the base C wrapper and Perl module
 * using Swig 2.0.x with the command: `swig -perl -const foundationdb.i`
 *
 * Should you wish to modify it (assuming you know what you're doing),
 * you *MUST* manually merge the changes from the C and Perl output files
 * into their respective Fdb.c and lib/Fdb.pm files.
 * 
 * Much manual work has been or will be done, especially in the lib/Fdb.pm
 * file. It's not expected that anyone will be crazy enough to modify the
 * generated C wrapper file, but better safe than sorry.
 * You've been warned.
 *
 */

%module Fdb
%{
#define FDB_API_VERSION 21
#include <foundationdb/fdb_c.h>
%}

%include typemaps.i

%rename("%(regex:/fdb_(.*)/\\1/)s") ""; // fdb_some_func -> some_func

// Try to get rid of as many inputs of the form (key, key_length)
// Perl doesn't need to known anything about length!
%typemap(in) (uint8_t const* value, int value_length) {
  $1 = (uint8_t *)SvPV_nolen($input);
  $2 = (int)sv_len($input);
}
%typemap(in) (uint8_t const* key_name, int key_name_length) = (uint8_t const* value, int value_length);
%typemap(in) (uint8_t const* begin_key_name, int begin_key_name_length) = (uint8_t const* value, int value_length);
%typemap(in) (uint8_t const* end_key_name, int end_key_name_length) = (uint8_t const* value, int value_length);
%typemap(in) (uint8_t const* db_name, int db_name_length) = (uint8_t const* value, int value_length);

%typemap(out) (uint8_t const** out_value, int* out_value_length) {
  $result = newSVpv(**out_value, *out_value_length);
  sv_2mortal($result);
  argvi++;
  delete $1;
}

// The following typemaps are to handle the output parameters
// of the type FDBxxxx** : We don't bother Perl with passing
// them in as inputs. Instead we push a new variable on the
// output stack with the result of the function

%typemap (in,numinputs=0) FDBCluster** (FDBCluster *temp) {
    $1 = &temp;
}

%typemap(argout) (FDBCluster** out_cluster) {
  if (argvi >= items) {
    EXTEND(sp,1);
  }
  SV *sv = sv_newmortal();
  SWIG_MakePtr(sv, temp$argnum, SWIGTYPE_p_cluster, 0);
  $result = sv;
  argvi++;
}

%typemap (in,numinputs=0) FDBDatabase** (FDBDatabase *temp) {
    $1 = &temp;
}

%typemap(argout) (FDBDatabase** out_database) {
  if (argvi >= items) {
    EXTEND(sp,1);
  }
  SV *sv = sv_newmortal();
  SWIG_MakePtr(sv, temp$argnum, SWIGTYPE_p_database, 0);
  $result = sv;
  argvi++;
}

#define FDB_API_VERSION 21
%include </usr/local/include/foundationdb/fdb_c_options.g.h>
%include </usr/local/include/foundationdb/fdb_c.h>

%perlcode %{
our $VERSION = 0.01;
our $network_thread;

*run_network = undef;

sub run_network {
  if (!$network_thread) {
    $network_thread = threads->create(sub { Fdbc::run_network(); });
    $network_thread->detach();
  }
}

sub select_api_version {
  my $v = shift;
  return select_api_version_impl($v, FDB_API_VERSION());
}
%}

