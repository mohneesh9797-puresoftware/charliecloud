load ../../../test/common

# LAMMPS does have a test suite, but we do not use it, because it seems too
# fiddly to get it running properly.
#
#   1. Running the command listed in LAMMPS' Jenkins tests [2] fails with a
#      strange error:
#
#        $ python run_tests.py tests/test_commands.py tests/test_examples.py
#        Loading tests from tests/test_commands.py...
#        Traceback (most recent call last):
#          File "run_tests.py", line 81, in <module>
#            tests += load_tests(f)
#          File "run_tests.py", line 22, in load_tests
#            for testname in list(tc):
#        TypeError: 'Test' object is not iterable
#
#      Looking in run_tests.py, this sure looks like a bug (it's expecting a
#      list of Tests, I think, but getting a single Test). But it works in
#      Jenkins. Who knows.
#
#   2. The files test/test_*.py say that the tests can be run with
#      "nosetests", which they can, after setting several environment
#      variables. But some of the tests fail for me. I didn't diagnose.
#
# Instead, we simply run some of the example problems in a loop and see if
# they exit with return code zero. We don't check output.
#
# Note that a lot of the other examples crash. I haven't diagnosed or figured
# out if we care.
#
# We are open to patches if anyone knows how to fix this situation reliably.
#
# [1]: https://github.com/lammps/lammps-testing
# [2]: https://ci.lammps.org/job/lammps/job/master/job/testing/lastSuccessfulBuild/console

setup () {
    scope full
    prerequisites_ok lammps
    multiprocess_ok
    IMG=$IMGDIR/lammps
}

lammps_try () {
    # These examples cd because some (not all) of the LAMMPS tests expect to
    # find things based on $CWD.
    infiles=$(ch-run --cd /lammps/examples/$1 $IMG -- bash -c "ls in.*")
    for i in $infiles; do
        printf '\n\n%s\n' $i
        $MPIRUN_CORE ch-run --join --cd /lammps/examples/$1 $IMG -- \
                            lmp_mpi -log none -in $i
    done

}

@test "$EXAMPLE_TAG/using all cores" {
    run $MPIRUN_CORE ch-run --join $IMG -- \
                            lmp_mpi -log none -in /lammps/examples/melt/in.melt
    echo "$output"
    [[ $status -eq 0 ]]
    ranks_found=$(  echo "$output" \
                  | fgrep 'MPI tasks' \
                  | sed -r 's/^.+with ([0-9]+) MPI tasks.+$/\1/')
    echo "ranks expected: $CHTEST_CORES_TOTAL"
    echo "ranks found: $ranks_found"
    [[ $ranks_found -eq $CHTEST_CORES_TOTAL ]]
}

@test "$EXAMPLE_TAG/crack"    { lammps_try crack; }
@test "$EXAMPLE_TAG/dipole"   { lammps_try dipole; }
@test "$EXAMPLE_TAG/flow"     { lammps_try flow; }
@test "$EXAMPLE_TAG/friction" { lammps_try friction; }
@test "$EXAMPLE_TAG/melt"     { lammps_try melt; }

# This test busy-hangs after several:
#
#   FOO error: local variable 'foo' referenced before assignment
#   Inside simple function
#
# Perhaps related to --join?
#
@test "$EXAMPLE_TAG/python"   { skip 'incompatible with --join'
                                lammps_try python; }