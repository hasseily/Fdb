use 5.8.0;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Fdb',
    AUTHOR           => q{Henri Asseily <henri@asseily.com>},
    VERSION_FROM     => 'lib/Fdb.pm',
    ABSTRACT_FROM    => 'lib/Fdb.pm',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.8.0,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    DEFINE           => '-DFDB_API_VERSION=510',
    LIBS             => ['-lfdb_c'],
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'threads'    => 0.1,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Fdb-*' },
);
