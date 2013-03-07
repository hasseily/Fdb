%module Fdb
%{
#define FDB_API_VERSION 21
#include <foundationdb/fdb_c.h>
%}

%include typemaps.i

%rename("%(regex:/fdb_(.*)/\\1/)s") ""; // fdb_some_func -> some_func

#define FDB_API_VERSION 21
%include </usr/local/include/foundationdb/fdb_c_options.g.h>
%include </usr/local/include/foundationdb/fdb_c.h>

//%apply FDBCluster* *OUTPUT { FDBCluster** out_cluster };
