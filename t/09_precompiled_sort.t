#!/usr/bin/perl

# suppress 'WEXRP00: Found multiple rperl executables' due to blib/ & pre-existing installation(s),
# also 'WARNING WCVCODE00, COMPILER, FIND DEPENDENCIES: Failed to eval-use package' due to RPerl/Test/*/*Bad*.pm & RPerl/Test/*/*bad*.pl
BEGIN { $ENV{RPERL_WARNINGS} = 0; }

use strict;
use warnings;
use RPerl::AfterSubclass;
our $VERSION = 0.005_000;

## no critic qw(ProhibitUselessNoCritic ProhibitMagicNumbers RequireCheckedSyscalls)  # USER DEFAULT 1: allow numeric values & print operator
## no critic qw(RequireInterpolationOfMetachars)  # USER DEFAULT 2: allow single-quoted control characters & sigils
## no critic qw(RequireCheckingReturnValueOfEval)  ## SYSTEM DEFAULT 4: allow eval() test code blocks

use Test::More tests => 254;
use Test::Exception;
use Test::Number::Delta;
use RPerl::Test;
use File::Copy;
use Module::Refresh;

#use File::Path qw(remove_tree);

BEGIN {
    if ( $ENV{RPERL_VERBOSE} ) {
        diag('[[[ Beginning Pre-Compiled Sort Pre-Test Loading, RPerl Type System ]]]');
    }
    lives_and( sub { use_ok('RPerl'); }, q{use_ok('RPerl') lives} );

    # NEED FIX: duplicate code, is it redundant to do this here and also at the top of the main for() loop?
    my string $bubble_cpp_filename = $RPerl::INCLUDE_PATH . '/RPerl/Algorithm/Sort/Bubble.cpp';
    my string $bubble_h_filename   = $RPerl::INCLUDE_PATH . '/RPerl/Algorithm/Sort/Bubble.h';
    my string $bubble_pmc_filename = $RPerl::INCLUDE_PATH . '/RPerl/Algorithm/Sort/Bubble.pmc';

    my string $sort_cpp_filename = $RPerl::INCLUDE_PATH . '/RPerl/Algorithm/Sort.cpp';
    my string $sort_h_filename   = $RPerl::INCLUDE_PATH . '/RPerl/Algorithm/Sort.h';
    my string $sort_pmc_filename = $RPerl::INCLUDE_PATH . '/RPerl/Algorithm/Sort.pmc';

    my string $algorithm_cpp_filename = $RPerl::INCLUDE_PATH . '/RPerl/Algorithm.cpp';
    my string $algorithm_h_filename   = $RPerl::INCLUDE_PATH . '/RPerl/Algorithm.h';
    my string $algorithm_pmc_filename = $RPerl::INCLUDE_PATH . '/RPerl/Algorithm.pmc';

    #    RPerl::diag('in 09_precompiled_sort.t, have $bubble_pmc_filename = ' . $bubble_pmc_filename . "\n");

    # NEED FIX: triplicate code, is it redundant to do this here and also at the top of the main for() loop?
    # delete CPP, H, and PMC files if they exist;
    # for PERLOPS_PERLTYPES we need none of these files; for CPPOPS_xTYPES we need the proper manually-compiled files, not some other files
    foreach my string $filename (
        @{  [   $bubble_cpp_filename, $bubble_h_filename,      $bubble_pmc_filename,  $sort_cpp_filename, $sort_h_filename,
                $sort_pmc_filename,   $algorithm_cpp_filename, $algorithm_h_filename, $algorithm_pmc_filename
            ]
        }
        )
    {
        if ( -e $filename ) {
            my integer $unlink_success = unlink $filename;
            if ($unlink_success) {
                ok( 1, 'Unlink (delete) existing file ' . $filename );
            }
            else {
                ok( 0, 'Unlink (delete) existing file ' . $filename . q{ ... } . $OS_ERROR );

                # skip all tests in this mode if we cannot remove the PMC file (and presumably the other 2 modes, as well)
                next;
            }
        }
        else {
            ok( 1, 'No need to unlink (delete) existing file ' . $filename );
        }
    }

    # DEV NOTE, CORRELATION #rp15: suppress 'Too late to run INIT block' at run-time loading via require or eval
    lives_and( sub { require_ok('RPerl::Algorithm::Sort::Bubble'); }, q{require_ok('RPerl::Algorithm::Sort::Bubble') lives} );
}

my string $module_filenamename = 'RPerl/Algorithm/Sort/Bubble.pm';
my object $refresher           = Module::Refresh->new();

# NEED FIX: duplicate code
my string $bubble_cpp_filename        = $RPerl::INCLUDE_PATH . '/RPerl/Algorithm/Sort/Bubble.cpp';
my string $bubble_cpp_filename_manual = $bubble_cpp_filename . '.CPPOPS_DUALTYPES';
my string $bubble_h_filename          = $RPerl::INCLUDE_PATH . '/RPerl/Algorithm/Sort/Bubble.h';
my string $bubble_h_filename_manual   = $bubble_h_filename . '.CPPOPS_DUALTYPES';
my string $bubble_pmc_filename        = $RPerl::INCLUDE_PATH . '/RPerl/Algorithm/Sort/Bubble.pmc';
my string $bubble_pmc_filename_manual = $bubble_pmc_filename . '.CPPOPS_DUALTYPES';

my string $sort_cpp_filename        = $RPerl::INCLUDE_PATH . '/RPerl/Algorithm/Sort.cpp';
my string $sort_cpp_filename_manual = $sort_cpp_filename . '.CPPOPS_DUALTYPES';
my string $sort_h_filename          = $RPerl::INCLUDE_PATH . '/RPerl/Algorithm/Sort.h';
my string $sort_h_filename_manual   = $sort_h_filename . '.CPPOPS_DUALTYPES';
my string $sort_pmc_filename        = $RPerl::INCLUDE_PATH . '/RPerl/Algorithm/Sort.pmc';
my string $sort_pmc_filename_manual = $sort_pmc_filename . '.CPPOPS_DUALTYPES';

my string $algorithm_cpp_filename        = $RPerl::INCLUDE_PATH . '/RPerl/Algorithm.cpp';
my string $algorithm_cpp_filename_manual = $algorithm_cpp_filename . '.CPPOPS_DUALTYPES';
my string $algorithm_h_filename          = $RPerl::INCLUDE_PATH . '/RPerl/Algorithm.h';
my string $algorithm_h_filename_manual   = $algorithm_h_filename . '.CPPOPS_DUALTYPES';
my string $algorithm_pmc_filename        = $RPerl::INCLUDE_PATH . '/RPerl/Algorithm.pmc';
my string $algorithm_pmc_filename_manual = $algorithm_pmc_filename . '.CPPOPS_DUALTYPES';

#RPerl::diag('in 09_precompiled_sort.t, have $bubble_pmc_filename = ' . $bubble_pmc_filename . "\n");
#RPerl::diag('in 09_precompiled_sort.t, have $bubble_pmc_filename_manual = ' . $bubble_pmc_filename_manual . "\n");

# [[[ PRIMARY RUNLOOP ]]]
# [[[ PRIMARY RUNLOOP ]]]
# [[[ PRIMARY RUNLOOP ]]]

# loop 3 times, once for each mode: PERLOPS_PERLTYPES, PERLOPS_CPPTYPES, CPPOPS_CPPTYPES
foreach my integer $mode_id ( sort keys %{$RPerl::MODES} ) {

    #for my $mode_id ( 1 .. 2 ) {    # TEMPORARY DEBUGGING xOPS_xTYPES ONLY

    # [[[ MODE SETUP ]]]
    #    RPerl::diag("in 09_precompiled_sort.t, top of for() loop, have \$mode_id = $mode_id\n");
    my scalartype_hashref $mode = $RPerl::MODES->{$mode_id};
    my $ops                     = $mode->{ops};
    my $types                   = $mode->{types};
    my string $mode_tagline     = $ops . 'OPS_' . $types . 'TYPES';
    if ( $ENV{RPERL_VERBOSE} ) {
        Test::More::diag( '[[[ Beginning RPerl Pre-Compiled Sort Tests, ' . $ops . ' operations and ' . $types . ' data types' . ' ]]]' );
    }

    lives_ok( sub { rperltypes::types_enable($types) }, q{Mode '} . $ops . ' operations and ' . $types . ' data types' . q{' enabled in CPP header file(s)} );

    # NEED FIX: triplicate code
    # delete CPP, H, and PMC files if they exist;
    # for PERLOPS_PERLTYPES we need none of these files; for CPPOPS_xTYPES we need the proper manually-compiled files, not some other files
    foreach my string $filename (
        @{  [   $bubble_cpp_filename, $bubble_h_filename,      $bubble_pmc_filename,  $sort_cpp_filename, $sort_h_filename,
                $sort_pmc_filename,   $algorithm_cpp_filename, $algorithm_h_filename, $algorithm_pmc_filename
            ]
        }
        )
    {
        if ( -e $filename ) {
            my integer $unlink_success = unlink $filename;
            if ($unlink_success) {
                ok( 1, 'Unlink (delete) existing file ' . $filename );
            }
            else {
                ok( 0, 'Unlink (delete) existing file ' . $filename . q{ ... } . $OS_ERROR );

                # skip all tests in this mode if we cannot remove the PMC file (and presumably the other 2 modes, as well)
                next;
            }
        }
        else {
            ok( 1, 'No need to unlink (delete) existing file ' . $filename );
        }
    }

    if ( $ops eq 'PERL' ) {

#        RPerl::diag('in 09_precompiled_sort.t, have Bubble symtab entries:' . "\n" . RPerl::analyze_class_symtab_entries('RPerl::Algorithm::Sort::Bubble') . "\n\n");
    }
    else {    # $ops eq 'CPP'
        foreach my string_arrayref $filenames (
            @{  [   [ $bubble_cpp_filename, $bubble_cpp_filename_manual ],

                    [ $bubble_h_filename,   $bubble_h_filename_manual ],
                    [ $bubble_pmc_filename, $bubble_pmc_filename_manual ],
                    [ $sort_cpp_filename,   $sort_cpp_filename_manual ],
                    [ $sort_h_filename,     $sort_h_filename_manual ],
                    [ $sort_pmc_filename,   $sort_pmc_filename_manual ],

                    [ $algorithm_cpp_filename, $algorithm_cpp_filename_manual ],
                    [ $algorithm_h_filename,   $algorithm_h_filename_manual ],
                    [ $algorithm_pmc_filename, $algorithm_pmc_filename_manual ]
                ]
            }
            )
        {
            my string $filename        = $filenames->[0];
            my string $filename_manual = $filenames->[1];
            my string $filename_short        = $filename;
            my string $filename_manual_short = $filename_manual;
            if ( ( length $filename_short ) > 55 )        { $filename_short        = '...' . substr $filename_short,        -55; }
            if ( ( length $filename_manual_short ) > 55 ) { $filename_manual_short = '...' . substr $filename_manual_short, -55; }
            if ( -e ($filename_manual) ) {
                my integer $copy_success = copy( $filename_manual, $filename );
                if ($copy_success) {
                    ok( 1, 'Copy manually-compiled file ' . $filename_manual_short . ' to ' . $filename_short );
                }
                else {
                    ok( 0, 'Copy manually-compiled file ' . $filename_manual_short . ' to ' . $filename_short . q{ ... } . $OS_ERROR );
                }
            }
            else {
                ok( 0, 'Copy manually-compiled file ' . $filename_manual_short . ' to ' . $filename_short . q{ ... } . 'File does not exist' );
            }
        }

        # C++ use, load, link
        lives_ok( sub { $refresher->refresh_module($module_filenamename) }, 'Refresh previously-loaded module: ' . $module_filenamename );

        # DEV NOTE, CORRELATION #rp15: suppress 'Too late to run INIT block' at run-time loading via require or eval
        lives_and( sub { require_ok('RPerl::Algorithm::Sort::Bubble'); }, q{require_ok('RPerl::Algorithm::Sort::Bubble') lives} );

        # force reload
        delete $main::{'RPerl__Algorithm__Sort__Bubble__MODE_ID'};

        # DEV NOTE: must call long form of cpp_load() to bypass mysterious 'undefined subroutine' symtab weirdness
        #lives_ok( sub { RPerl::Algorithm::Sort::Bubble::cpp_load(); }, q{RPerl::Algorithm::Sort::Bubble::cpp_load() lives} );
        lives_ok( sub { &{ $RPerl::Algorithm::Sort::Bubble::{'cpp_load'} }(); }, q{RPerl::Algorithm::Sort::Bubble::cpp_load() lives} );    # long form

#RPerl::diag('in 09_precompiled_sort.t, have post-re-use, post-re-cpp_load Bubble symtab entries:' . "\n" . RPerl::analyze_class_symtab_entries('RPerl::Algorithm::Sort::Bubble') . "\n\n");
    }

    foreach my string $type (qw(DataType__Integer DataType__Number DataType__String DataStructure__Array DataStructure__Hash Algorithm__Sort__Bubble)) {
        lives_and(
            sub {
                is( $RPerl::MODES->{ main->can( 'RPerl__' . $type . '__MODE_ID' )->() }->{ops},
                    $ops, 'main::RPerl__' . $type . '__MODE_ID() ops returns ' . $ops );
            },
            'main::RPerl__' . $type . '__MODE_ID() lives'
        );
        lives_and(
            sub {
                is( $RPerl::MODES->{ main->can( 'RPerl__' . $type . '__MODE_ID' )->() }->{types},
                    $types, 'main::RPerl__' . $type . '__MODE_ID() types returns ' . $types );
            },
            'main::RPerl__' . $type . '__MODE_ID() lives'
        );
    }

    # [[[ INTEGER SORT TESTS ]]]
    # [[[ INTEGER SORT TESTS ]]]
    # [[[ INTEGER SORT TESTS ]]]

    throws_ok(    # TIVALSOBU00
        sub { integer_bubblesort() },
        "/(EIVAVRV00.*$mode_tagline)|(Usage.*integer_bubblesort)/",    # DEV NOTE: 2 different error messages, RPerl & C
        q{TIVALSOBU00 integer_bubblesort() throws correct exception}
    );
    throws_ok(                                                         # TIVALSOBU01
        sub { RPerl::Algorithm::Sort::Bubble::integer_bubblesort(undef) },
        "/EIVAVRV00.*$mode_tagline/",
        q{TIVALSOBU01 RPerl::Algorithm::Sort::Bubble::integer_bubblesort(undef) throws correct exception}
    );
    throws_ok(                                                         # TIVALSOBU02
        sub { RPerl::Algorithm::Sort::Bubble::integer_bubblesort(2) },
        "/EIVAVRV01.*$mode_tagline/",
        q{TIVALSOBU02 RPerl::Algorithm::Sort::Bubble::integer_bubblesort(2) throws correct exception}
    );
    throws_ok(                                                         # TIVALSOBU03
        sub { RPerl::Algorithm::Sort::Bubble::integer_bubblesort(2.3) },
        "/EIVAVRV01.*$mode_tagline/",
        q{TIVALSOBU03 RPerl::Algorithm::Sort::Bubble::integer_bubblesort(2.3) throws correct exception}
    );
    throws_ok(                                                         # TIVALSOBU04
        sub { RPerl::Algorithm::Sort::Bubble::integer_bubblesort('2') },
        "/EIVAVRV01.*$mode_tagline/",
        q{TIVALSOBU04 RPerl::Algorithm::Sort::Bubble::integer_bubblesort('2') throws correct exception}
    );
    throws_ok(                                                         # TIVALSOBU05
        sub { RPerl::Algorithm::Sort::Bubble::integer_bubblesort( { a_key => 23 } ) },
        "/EIVAVRV01.*$mode_tagline/",
        q{TIVALSOBU05 RPerl::Algorithm::Sort::Bubble::integer_bubblesort({a_key => 23}) throws correct exception}
    );
    throws_ok(                                                         # TIVALSOBU10
        sub {
            RPerl::Algorithm::Sort::Bubble::integer_bubblesort( [ 2, 2112, undef, 23, -877, -33, 1701 ] );
        },
        "/EIVAVRV02.*$mode_tagline/",
        q{TIVALSOBU10 RPerl::Algorithm::Sort::Bubble::integer_bubblesort([2, 2112, undef, 23, -877, -33, 1701]) throws correct exception}
    );
    throws_ok(                                                         # TIVALSOBU11
        sub {
            RPerl::Algorithm::Sort::Bubble::integer_bubblesort( [ 2, 2112, 42, 23.3, -877, -33, 1701 ] );
        },
        "/EIVAVRV03.*$mode_tagline/",
        q{TIVALSOBU11 RPerl::Algorithm::Sort::Bubble::integer_bubblesort([2, 2112, 42, 23.3, -877, -33, 1701]) throws correct exception}
    );
    throws_ok(                                                         # TIVALSOBU12
        sub {
            RPerl::Algorithm::Sort::Bubble::integer_bubblesort( [ 2, 2112, 42, '23', -877, -33, 1701 ] );
        },
        "/EIVAVRV03.*$mode_tagline/",
        q{TIVALSOBU12 RPerl::Algorithm::Sort::Bubble::integer_bubblesort([2, 2112, 42, '23', -877, -33, 1701]) throws correct exception}
    );
    throws_ok(                                                         # TIVALSOBU13
        sub {
            RPerl::Algorithm::Sort::Bubble::integer_bubblesort( [ 2, 2112, 42, [23], -877, -33, 1701 ] );
        },
        "/EIVAVRV03.*$mode_tagline/",
        q{TIVALSOBU13 RPerl::Algorithm::Sort::Bubble::integer_bubblesort([2, 2112, 42, [23], -877, -33, 1701]) throws correct exception}
    );
    throws_ok(                                                         # TIVALSOBU14
        sub {
            RPerl::Algorithm::Sort::Bubble::integer_bubblesort( [ 2, 2112, 42, { a_subkey => 23 }, -877, -33, 1701 ] );
        },
        "/EIVAVRV03.*$mode_tagline/",
        q{TIVALSOBU14 RPerl::Algorithm::Sort::Bubble::integer_bubblesort([2, 2112, 42, {a_subkey => 23}, -877, -33, 1701]) throws correct exception}
    );
    lives_and(                                                         # TIVALSOBU20
        sub {
            is_deeply( RPerl::Algorithm::Sort::Bubble::integer_bubblesort( [23] ), [23], q{TIVALSOBU20 integer_bubblesort([23]) returns correct value} );
        },
        q{TIVALSOBU20 RPerl::Algorithm::Sort::Bubble::integer_bubblesort([23]) lives}
    );
    lives_and(                                                         # TIVALSOBU21
        sub {
            is_deeply(
                RPerl::Algorithm::Sort::Bubble::integer_bubblesort( [ 2, 2112, 42, 23, -877, -33, 1701 ] ),
                [ -877, -33, 2, 23, 42, 1701, 2112 ],
                q{TIVALSOBU21 RPerl::Algorithm::Sort::Bubble::integer_bubblesort([2, 2112, 42, 23, -877, -33, 1701]) returns correct value}
            );
        },
        q{TIVALSOBU21 RPerl::Algorithm::Sort::Bubble::integer_bubblesort([2, 2112, 42, 23, -877, -33, 1701]) lives}
    );
    lives_and(                                                         # TIVALSOBU22
        sub {
            is_deeply( RPerl::Algorithm::Sort::Bubble::integer_bubblesort( [ reverse 0 .. 7 ] ), [ 0 .. 7 ], q{TIVALSOBU22 RPerl::Algorithm::Sort::Bubble::integer_bubblesort([reverse 0 .. 7]) returns correct value} );
        },
        q{TIVALSOBU22 RPerl::Algorithm::Sort::Bubble::integer_bubblesort([reverse 0 .. 7]) lives}
    );
    lives_and(                                                         # TIVALSOBU22a
        sub {
            is_deeply(
                eval {
                    my $retval = RPerl::Algorithm::Sort::Bubble::integer_bubblesort( [ reverse 0 .. 7 ] );
                    return $retval;
                },                                                     # DEV NOTE: does different things to Perl stack than non-eval
                [ 0 .. 7 ],
                q{TIVALSOBU22a eval { my $retval = RPerl::Algorithm::Sort::Bubble::integer_bubblesort( [ reverse 0 .. 7 ] ); return $retval; } returns correct value}
            );
        },
        q{TIVALSOBU22a eval { my $retval = RPerl::Algorithm::Sort::Bubble::integer_bubblesort( [ reverse 0 .. 7 ] ); return $retval; } lives}
    );
    throws_ok(                                                         # TIVALSOBU30
        sub { RPerl::Algorithm::Sort::Bubble::integer_bubblesort__typetest0() },
        "/(EIVAVRV00.*$mode_tagline)|(Usage.*integer_bubblesort__typetest0)/"
        ,                                                              # DEV NOTE: 2 different error messages, RPerl & C
        q{TIVALSOBU30 RPerl::Algorithm::Sort::Bubble::integer_bubblesort__typetest0() throws correct exception}
    );
    throws_ok(                                                         # TIVALSOBU31
        sub { RPerl::Algorithm::Sort::Bubble::integer_bubblesort__typetest0(2) },
        "/EIVAVRV01.*$mode_tagline/",
        q{TIVALSOBU31 RPerl::Algorithm::Sort::Bubble::integer_bubblesort__typetest0(2) throws correct exception}
    );
    throws_ok(                                                         # TIVALSOBU32
        sub {
            RPerl::Algorithm::Sort::Bubble::integer_bubblesort__typetest0( [ 2, 2112, undef, 23, -877, -33, 1701 ] );
        },
        "/EIVAVRV02.*$mode_tagline/",
        q{TIVALSOBU32 RPerl::Algorithm::Sort::Bubble::integer_bubblesort__typetest0([2, 2112, undef, 23, -877, -33, 1701]) throws correct exception}
    );
    throws_ok(                                                         # TIVALSOBU33
        sub {
            RPerl::Algorithm::Sort::Bubble::integer_bubblesort__typetest0( [ 2, 2112, 42, 23, -877, -33, 1701, [ 23, -42.3 ] ] );
        },
        "/EIVAVRV03.*$mode_tagline/",
        q{TIVALSOBU33 RPerl::Algorithm::Sort::Bubble::integer_bubblesort__typetest0([2, 2112, 42, 23, -877, -33, 1701, [23, -42.3]]) throws correct exception}
    );
    lives_and(                                                         # TIVALSOBU34
        sub {
            is( RPerl::Algorithm::Sort::Bubble::integer_bubblesort__typetest0( [ 2, 2112, 42, 23, -877, -33, 1701 ] ),
                '[-877, -33, 2, 23, 42, 1701, 2112]' . $mode_tagline,
                q{TIVALSOBU34 RPerl::Algorithm::Sort::Bubble::integer_bubblesort__typetest0([2, 2112, 42, 23, -877, -33, 1701]) returns correct value}
            );
        },
        q{TIVALSOBU34 RPerl::Algorithm::Sort::Bubble::integer_bubblesort__typetest0([2, 2112, 42, 23, -877, -33, 1701]) lives}
    );
    lives_and(                                                         # TIVALSOBU34a
        sub {
            is( eval {
                    my $retval = RPerl::Algorithm::Sort::Bubble::integer_bubblesort__typetest0( [ 2, 2112, 42, 23, -877, -33, 1701 ] );
                    return $retval;
                },
                '[-877, -33, 2, 23, 42, 1701, 2112]' . $mode_tagline,
                q{TIVALSOBU34a eval { my $retval = RPerl::Algorithm::Sort::Bubble::integer_bubblesort__typetest0( [2, 2112, 42, 23, -877, -33, 1701] ); return $retval; } returns correct value}
            );
        },
        q{TIVALSOBU34a eval { my $retval = RPerl::Algorithm::Sort::Bubble::integer_bubblesort__typetest0( [2, 2112, 42, 23, -877, -33, 1701] ); return $retval; } lives}
    );

    # [[[ NUMBER SORT TESTS ]]]
    # [[[ NUMBER SORT TESTS ]]]
    # [[[ NUMBER SORT TESTS ]]]

    throws_ok(    # TNVALSOBU00
        sub { RPerl::Algorithm::Sort::Bubble::number_bubblesort() },
        "/(ENVAVRV00.*$mode_tagline)|(Usage.*number_bubblesort)/",    # DEV NOTE: 2 different error messages, RPerl & C
        q{TNVALSOBU00 RPerl::Algorithm::Sort::Bubble::number_bubblesort() throws correct exception}
    );
    throws_ok(                                                        # TNVALSOBU01
        sub { RPerl::Algorithm::Sort::Bubble::number_bubblesort(undef) },
        "/ENVAVRV00.*$mode_tagline/",
        q{TNVALSOBU01 RPerl::Algorithm::Sort::Bubble::number_bubblesort(undef) throws correct exception}
    );
    throws_ok(                                                        # TNVALSOBU02
        sub { RPerl::Algorithm::Sort::Bubble::number_bubblesort(2) },
        "/ENVAVRV01.*$mode_tagline/",
        q{TNVALSOBU02 RPerl::Algorithm::Sort::Bubble::number_bubblesort(2) throws correct exception}
    );
    throws_ok(                                                        # TNVALSOBU03
        sub { RPerl::Algorithm::Sort::Bubble::number_bubblesort(2.3) },
        "/ENVAVRV01.*$mode_tagline/",
        q{TNVALSOBU03 RPerl::Algorithm::Sort::Bubble::number_bubblesort(2.3) throws correct exception}
    );
    throws_ok(                                                        # TNVALSOBU04
        sub { RPerl::Algorithm::Sort::Bubble::number_bubblesort('2') },
        "/ENVAVRV01.*$mode_tagline/",
        q{TNVALSOBU04 RPerl::Algorithm::Sort::Bubble::number_bubblesort('2') throws correct exception}
    );
    throws_ok(                                                        # TNVALSOBU05
        sub { RPerl::Algorithm::Sort::Bubble::number_bubblesort( { a_key => 23 } ) },
        "/ENVAVRV01.*$mode_tagline/",
        q{TNVALSOBU05 RPerl::Algorithm::Sort::Bubble::number_bubblesort({a_key => 23}) throws correct exception}
    );
    throws_ok(                                                        # TNVALSOBU10
        sub {
            RPerl::Algorithm::Sort::Bubble::number_bubblesort( [ 2, 2112, undef, 23, -877, -33, 1701 ] );
        },
        "/ENVAVRV02.*$mode_tagline/",
        q{TNVALSOBU10 RPerl::Algorithm::Sort::Bubble::number_bubblesort([2, 2112, undef, 23, -877, -33, 1701]) throws correct exception}
    );
    throws_ok(                                                        # TNVALSOBU11
        sub {
            RPerl::Algorithm::Sort::Bubble::number_bubblesort( [ 2, 2112, 42, '23', -877, -33, 1701 ] );
        },
        "/ENVAVRV03.*$mode_tagline/",
        q{TNVALSOBU11 RPerl::Algorithm::Sort::Bubble::number_bubblesort([2, 2112, 42, '23', -877, -33, 1701]) throws correct exception}
    );
    throws_ok(                                                        # TNVALSOBU12
        sub {
            RPerl::Algorithm::Sort::Bubble::number_bubblesort( [ 2, 2112, 42, [23], -877, -33, 1701 ] );
        },
        "/ENVAVRV03.*$mode_tagline/",
        q{TNVALSOBU12 RPerl::Algorithm::Sort::Bubble::number_bubblesort([2, 2112, 42, [23], -877, -33, 1701]) throws correct exception}
    );
    throws_ok(                                                        # TNVALSOBU13
        sub {
            RPerl::Algorithm::Sort::Bubble::number_bubblesort( [ 2, 2112, 42, { a_subkey => 23 }, -877, -33, 1701 ] );
        },
        "/ENVAVRV03.*$mode_tagline/",
        q{TNVALSOBU13 RPerl::Algorithm::Sort::Bubble::number_bubblesort([2, 2112, 42, {a_subkey => 23}, -877, -33, 1701]) throws correct exception}
    );
    lives_and(                                                        # TNVALSOBU20
        sub {
            is_deeply( RPerl::Algorithm::Sort::Bubble::number_bubblesort( [23] ), [23], q{TNVALSOBU20 RPerl::Algorithm::Sort::Bubble::number_bubblesort([23]) returns correct value} );
        },
        q{TNVALSOBU20 RPerl::Algorithm::Sort::Bubble::number_bubblesort([23]) lives}
    );
    lives_and(                                                        # TNVALSOBU21
        sub {
            is_deeply(
                RPerl::Algorithm::Sort::Bubble::number_bubblesort( [ 2, 2112, 42, 23, -877, -33, 1701 ] ),
                [ -877, -33, 2, 23, 42, 1701, 2112 ],
                q{TNVALSOBU21 RPerl::Algorithm::Sort::Bubble::number_bubblesort([2, 2112, 42, 23, -877, -33, 1701]) returns correct value}
            );
        },
        q{TNVALSOBU21 RPerl::Algorithm::Sort::Bubble::number_bubblesort([2, 2112, 42, 23, -877, -33, 1701]) lives}
    );
    lives_and(                                                        # TNVALSOBU22
        sub {
            is_deeply( RPerl::Algorithm::Sort::Bubble::number_bubblesort( [ reverse 0 .. 7 ] ), [ 0 .. 7 ], q{TNVALSOBU22 RPerl::Algorithm::Sort::Bubble::number_bubblesort([reverse 0 .. 7]) returns correct value} );
        },
        q{TNVALSOBU22 RPerl::Algorithm::Sort::Bubble::number_bubblesort([reverse 0 .. 7]) lives}
    );
    lives_and(                                                        # TNVALSOBU22a
        sub {
            is_deeply(
                eval {
                    my $retval = RPerl::Algorithm::Sort::Bubble::number_bubblesort( [ reverse 0 .. 7 ] );
                    return $retval;
                },                                                    # DEV NOTE: does different things to Perl stack than non-eval
                [ 0 .. 7 ],
                q{TNVALSOBU22a eval { my $retval = RPerl::Algorithm::Sort::Bubble::number_bubblesort( [ reverse 0 .. 7 ] ); return $retval; } returns correct value}
            );
        },
        q{TNVALSOBU22a eval { my $retval = RPerl::Algorithm::Sort::Bubble::number_bubblesort( [ reverse 0 .. 7 ] ); return $retval; } lives}
    );
    lives_and(                                                        # TNVALSOBU23
        sub {
# NEED DELETE OLD CODE
#            is_deeply( RPerl::Algorithm::Sort::Bubble::number_bubblesort( [23.2] ), [23.2], q{TNVALSOBU23 RPerl::Algorithm::Sort::Bubble::number_bubblesort([23.2]) returns correct value} );
            delta_ok( RPerl::Algorithm::Sort::Bubble::number_bubblesort( [23.2] ), [23.2], q{TNVALSOBU23 RPerl::Algorithm::Sort::Bubble::number_bubblesort([23.2]) returns correct value} );
        },
        q{TNVALSOBU23 RPerl::Algorithm::Sort::Bubble::number_bubblesort([23.2]) lives}
    );
    lives_and(                                                        # TNVALSOBU24
        sub {
# NEED DELETE OLD CODE
#            is_deeply(
            delta_ok(
                RPerl::Algorithm::Sort::Bubble::number_bubblesort( [ 2.1, 2112.2, 42.3, 23, -877, -33, 1701 ] ),
                [ -877, -33, 2.1, 23, 42.3, 1701, 2112.2 ],
                q{TNVALSOBU24 RPerl::Algorithm::Sort::Bubble::number_bubblesort([2.1, 2112.2, 42.3, 23, -877, -33, 1701]) returns correct value}
            );
        },
        q{TNVALSOBU24 RPerl::Algorithm::Sort::Bubble::number_bubblesort([2.1, 2112.2, 42.3, 23, -877, -33, 1701]) lives}
    );
    lives_and(                                                        # TNVALSOBU25
        sub {
            # NEED DELETE OLD CODE
            #            is_deeply(
            delta_ok(
                RPerl::Algorithm::Sort::Bubble::number_bubblesort( [ 2.1234432112344321, 2112.4321, 42.4567, 23.765444444444444444, -877.5678, -33.876587658765875687658765, 1701.6789 ] ),
                [ -877.5678, -33.8765876587659, 2.12344321123443, 23.7654444444444, 42.4567, 1701.6789, 2112.4321 ],
                q{TNVALSOBU25 RPerl::Algorithm::Sort::Bubble::number_bubblesort([2.1234432112344321, ..., -33.876587658765875687658765, 1701.6789]) returns correct value}
            );
        },
        q{TNVALSOBU25 RPerl::Algorithm::Sort::Bubble::number_bubblesort([2.1234432112344321, ..., -33.876587658765875687658765, 1701.6789]) lives}
    );
    throws_ok(    # TNVALSOBU30
        sub { RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0() },
        "/(ENVAVRV00.*$mode_tagline)|(Usage.*number_bubblesort__typetest0)/"
        ,         # DEV NOTE: 2 different error messages, RPerl & C
        q{TNVALSOBU30 RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0() throws correct exception}
    );
    throws_ok(    # TNVALSOBU31
        sub { RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0(2) },
        "/ENVAVRV01.*$mode_tagline/",
        q{TNVALSOBU31 RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0(2) throws correct exception}
    );
    throws_ok(    # TNVALSOBU32
        sub {
            RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0( [ 2.1234432112344321, 2112.4321, undef, 23.765444444444444444, -877.5678, -33.876587658765875687658765, 1701.6789 ] );
        },
        "/ENVAVRV02.*$mode_tagline/",
        q{TNVALSOBU32 RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0([2.1234432112344321, 2112.4321, undef, ..., 1701.6789]) throws correct exception}
    );
    throws_ok(    # TNVALSOBU33
        sub {
            RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0(
                [ 2.1234432112344321, 2112.4321, 42.4567, 23.765444444444444444, -877.5678, 'abcdefg', -33.876587658765875687658765, 1701.6789 ] );
        },
        "/ENVAVRV03.*$mode_tagline/",
        q{TNVALSOBU33 RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0([2.1234432112344321, ..., 'abcdefg', -33.876587658765875687658765, 1701.6789]) throws correct exception}
    );

    lives_and(    # TNVALSOBU34
        sub {
# NEED DELETE OLD CODE
#            is( RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0( [ 2.1234432112344321, 2112.4321, 42.4567, 23.765444444444444444, -877.5678, -33.876587658765875687658765, 1701.6789 ] ),
#                '[-877.567_8, -33.876_587_658_765_9, 2.123_443_211_234_43, 23.765_444_444_444_4, 42.456_7, 1_701.678_9, 2_112.432_1]' . $mode_tagline,
#                q{TNVALSOBU34 RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0([2.1234432112344321, ..., -33.876587658765875687658765, 1701.6789]) returns correct value}
#            );

            my string $tmp_retval = RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0(
                [ 2.1234432112344321, 2112.4321, 42.4567, 23.765444444444444444, -877.5678, -33.876587658765875687658765, 1701.6789 ] );
            like(
                $tmp_retval,
                qr/\[-877\.567_8, -33\.876_587_658_765/,
                q{TNVALSOBU34a RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0([2.1234432112344321, ..., -33.876587658765875687658765, 1701.6789]) returns correct value, array beginning}
            );
            like(
                $tmp_retval,
                qr/42\.456_7, 1_701\.678_9, 2_112\.432_1\]/,
                q{TNVALSOBU34b RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0([2.1234432112344321, ..., -33.876587658765875687658765, 1701.6789]) returns correct value, array end}
            );
            like( $tmp_retval, qr/$mode_tagline/,
                q{TNVALSOBU34c RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0([2.1234432112344321, ..., -33.876587658765875687658765, 1701.6789]) returns correct value, mode tagline}
            );
        },
        q{TNVALSOBU34 RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0([2.1234432112344321, ..., -33.876587658765875687658765, 1701.6789]) lives}
    );

    # same as TNVALSOBU34, but inside an eval block
    lives_and(    # TNVALSOBU35
        sub {
# NEED DELETE OLD CODE
#            is( eval {
#                    my $retval = RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0( [ 2.1234432112344321, 2112.4321, 42.4567, 23.765444444444444444, -877.5678, -33.876587658765875687658765, 1701.6789 ] );
#                    return $retval;
#                },
#                '[-877.567_8, -33.876_587_658_765_9, 2.123_443_211_234_43, 23.765_444_444_444_4, 42.456_7, 1_701.678_9, 2_112.432_1]' . $mode_tagline,
#                q{TNVALSOBU35 eval { my $retval = RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0( [2.1234432112344321, ..., 1701.6789] ); return $retval; } returns correct value}
#            );

            my string $tmp_retval = eval {
                my $inner_retval
                    = RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0(
                    [ 2.1234432112344321, 2112.4321, 42.4567, 23.765444444444444444, -877.5678, -33.876587658765875687658765, 1701.6789 ] );
                return $inner_retval;
            };
            like(
                $tmp_retval,
                qr/\[-877\.567_8, -33\.876_587_658_765/,
                q{TNVALSOBU35 eval { my $inner_retval = RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0( [2.1234432112344321, ..., 1701.6789] ); return $inner_retval; } returns correct value, array beginning}
            );
            like(
                $tmp_retval,
                qr/42\.456_7, 1_701\.678_9, 2_112\.432_1\]/,
                q{TNVALSOBU35 eval { my $inner_retval = RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0( [2.1234432112344321, ..., 1701.6789] ); return $inner_retval; } returns correct value, array end}
            );
            like( $tmp_retval, qr/$mode_tagline/,
                q{TTNVALSOBU35 eval { my $inner_retval = RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0( [2.1234432112344321, ..., 1701.6789] ); return $inner_retval; } returns correct value, mode tagline}
            );
        },
        q{TNVALSOBU35 eval { my $inner_retval = RPerl::Algorithm::Sort::Bubble::number_bubblesort__typetest0( [2.1234432112344321, ..., 1701.6789] ); return $inner_retval; } lives}
    );
}

# NEED FIX: triplicate code
# delete CPP, H, and PMC files if they exist;
# for PERLOPS_PERLTYPES we need none of these files; for CPPOPS_xTYPES we need the proper manually-compiled files, not some other files
foreach my string $filename (
    @{  [   $bubble_cpp_filename, $bubble_h_filename,      $bubble_pmc_filename,  $sort_cpp_filename, $sort_h_filename,
            $sort_pmc_filename,   $algorithm_cpp_filename, $algorithm_h_filename, $algorithm_pmc_filename
        ]
    }
    )
{
    if ( -e $filename ) {
        my integer $unlink_success = unlink $filename;
        if ($unlink_success) {
            ok( 1, 'Unlink (delete) existing file ' . $filename );
        }
        else {
            ok( 0, 'Unlink (delete) existing file ' . $filename . q{ ... } . $OS_ERROR );

            # skip all tests in this mode if we cannot remove the PMC file (and presumably the other 2 modes, as well)
            next;
        }
    }
    else {
        ok( 1, 'No need to unlink (delete) existing file ' . $filename );
    }
}

done_testing();
