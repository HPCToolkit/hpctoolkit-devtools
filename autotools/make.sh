#!/bin/sh
#
#  Copyright (c) 2013-2016, Rice University.
#  See the file LICENSE for details.
#
#  This script builds and installs the autotools packages (autoconf,
#  automake, libtool and optionally m4) into a directory suitable for
#  hpctoolkit /projects/pkgs.  Run this script from this directory
#  with the install prefix as argument.  For example:
#
#    ./make.sh /projects/pkgs/autotools
#
#  See the usage message (./make.sh -h) and the README file for
#  details.
#
#  $Id$
#
version='ac-2.69-am-1.15.1-lt-2.4.6'

autoconf_srcdir=autoconf-2.69
automake_srcdir=automake-1.15.1
libtool_srcdir=libtool-2.4.6
m4_srcdir=m4-1.4.17

autoconf_tarfile="${autoconf_srcdir}.tar.gz"
automake_tarfile="${automake_srcdir}.tar.gz"
libtool_tarfile="${libtool_srcdir}.tar.gz"
m4_tarfile="${m4_srcdir}.tar.gz"

distdir=files

topdir=`/bin/pwd`

die()
{
    echo "$0: error: $*"
    exit 1
}

#----------------------------------------
#  usage
#----------------------------------------

usage()
{
    cat <<EOF
usage: $0 [option]... install-prefix

    -c, -clean
        delete the source directories

    -m4, -no-m4
        install m4 (or not), default no

    -v, --version
        display versions of the packages

version: autotools-$version

EOF
}

#----------------------------------------
#  make clean
#----------------------------------------

make_clean()
{
    echo "deleting source directories ..."
    for dir in \
	"$autoconf_srcdir"  \
	"$automake_srcdir"  \
	"$libtool_srcdir"   \
	"$m4_srcdir"
    do
        rm -rf "$dir" "${dir}.bak"
    done
}

#----------------------------------------
#  build and install one package
#----------------------------------------

build_pkg()
{
    pkg_name="$1"
    tarfile="$2"
    srcdir="$3"
    config_dir="$4"

    echo ; echo "===> ($pkg_name)"

    cd "$topdir" || die "unable to cd: $topdir"
    test -f "$distdir/$tarfile" || die "missing tar file: $tarfile"

    if test -d "$srcdir" ; then
	bak="${srcdir}.bak"
	rm -rf "$bak"
	mv -f "$srcdir" "$bak"
    fi

    echo "unpacking tar file: $tarfile"
    case "$tarfile" in
	*.tar.gz | *.tgz )
	    tar xzf "$distdir/$tarfile" || die "unable to untar: $tarfile"
	    ;;
	*.tar.bz | *.tar.bz2 | *.tbz )
	    tar xjf "$distdir/$tarfile" || die "unable to untar: $tarfile"
	    ;;
	* )
	    die "unknown type of tar file: $tarfile"
	    ;;
    esac

    cd "$srcdir" || die "unable to cd: $srcdir"

    if test -d "$config_dir" ; then
	echo "installing new config.guess, config.sub"
	cd "$config_dir" || die "unable to cd: $config_dir"

	for f in config.guess config.sub ; do
	    rm -f "$f.orig"
	    mv -f "$f" "$f.orig"
	    cp -f "$topdir/$distdir/$f" "$f" || die "unable to copy: $f"
	done
    fi

    cd "$topdir" || die "unable to cd: $topdir"
    cd "$srcdir" || die "unable to cd: $srcdir"

    echo "configure --prefix=$prefix"
    ./configure --prefix="$prefix" || die "configure failed"

    echo ; echo "===> ($pkg_name) make"
    make || die "make failed"

    echo ; echo "===> ($pkg_name) make install"
    make install || die "make install failed"
}

#----------------------------------------
#  options
#----------------------------------------

opt_install_m4=no
prefix=

while test "x$1" != x
do
    arg="$1" ; shift
    case "$arg" in
	-c | -clean | --clean )
	    make_clean
	    exit 0
	    ;;
	-h | -help | --help )
	    usage
	    exit 0
	    ;;
	-m4 | --m4 )
	    opt_install_m4=yes
	    ;;
	-no-m4 | --no-m4 )
	    opt_install_m4=no
	    ;;
	-v | -V | --version )
	    echo $version
	    exit 0
	    ;;
	-- )
	    break
	    ;;
	-* )
	    echo "error: unknown option: $arg"
	    usage
	    exit 1
	    ;;
	* )
	    set -- "$arg" "$@"
	    break
	    ;;
    esac
done

prefix="$1"

#----------------------------------------
#  main program
#----------------------------------------

if test "x$prefix" = x ; then
    echo "error: missing install prefix"
    usage
    exit 1
fi

PATH="${prefix}/bin/:$PATH"

if test "$opt_install_m4" = yes ; then
    build_pkg m4 "$m4_tarfile" "$m4_srcdir" build-aux
fi
build_pkg autoconf "$autoconf_tarfile" "$autoconf_srcdir" build-aux
build_pkg automake "$automake_tarfile" "$automake_srcdir" no
build_pkg libtool  "$libtool_tarfile"  "$libtool_srcdir"  no

echo ; echo "resetting permissions ..."
find "$prefix" -type d -exec chmod a+rx {} \;
chmod -R a+r "$prefix"

echo "done"
