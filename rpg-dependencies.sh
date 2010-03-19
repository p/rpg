#!/bin/sh
set -e
. rpg-sh-setup

test "$*" || set -- --help; ARGV="$@"
USAGE '${PROGNAME} [-rt] <package> [<version>]
       ${PROGNAME} -a
Show package dependency information.

Options
  -a          Write dependency information for all installed packages
  -r          List dependencies recursively
  -t          List dependencies recursively in a tree'

showall=false
recursive=false;
tree=false
while getopts art opt
do
    case $opt in
    a) showall=true;;
    r) recursive=true;;
    t) tree=true;;
    ?) helpthem
       exit 2;;
    esac
done
shift $(( $OPTIND - 1 ))

# With the `-a` argument, write all dependencies for all packages in the
# following format:
#
#     <source> <package> <verspec> <version>
#
# Where `<source>` is the name of the package that has a dependency
# on `<package>`. The `<verspec>` may be any valid version expression:
# `<`, `<=`, `=`, `>=`, `>`, or `~>`.
$showall && {
    test "$*" && { helpthem; exit 2; }
    for file in "$RPGDB"/*/active/dependencies
    do
        package="${file%/active/dependencies}"
        package="${package##*/}"
        sed -n "s|^runtime |$package |p" <"$file"
    done 2>/dev/null || true
    exit 0
}


# Find the package and write its dependencies in this format:
#
#     <package> <verspec> <version>
#
# Exit with failure if the package or package version is not found in the
# database.
package="$1"
version="${2:-active}"
packagedir="$RPGDB/$package"

test -d "$packagedir" || {
    warn "package not found: $package"
    exit 1
}

test -d "$packagedir/$version" || {
    warn "package version not found: $package $version"
    exit 1
}

# 
sed -n 's|^runtime ||p' <"$packagedir/$version/dependencies" |
if $tree
then
    while read pack spec vers
    do
        echo "$pack $spec $vers"
        "$0" -r -t $pack |sed '
            s/^/|-- /
            s/-- |/   |/
        '
    done
else
    while read pack spec vers
    do
        echo "$pack $spec $vers"
        $recursive && "$0" -r "$pack"
    done |
    sort -u
fi
