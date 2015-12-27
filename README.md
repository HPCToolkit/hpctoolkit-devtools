# hpctoolkit-devtools

hpctoolkit-devtools is a collection of packages useful for hpctoolkit
developers.  These packages are only needed by developers wishing to
modify certain files in the hpctoolkit source tree, especially the
configure and make files.

To build an unmodified snapshot of hpctoolkit, you only need
hpctoolkit-externals, not hpctoolkit-devtools.

* autotools -- packages needed to run autoreconf: autoconf, automake,
libtool and optionally m4.  developers should use these versions of
autotools to avoid large, spurious diffs in the generated makefiles.

