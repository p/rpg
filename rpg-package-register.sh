#!/bin/sh
# Register a gem in the package database.
#
#     PGEMDB
#        foo/
#          0.1/
#          0.2/
#        bar/
#          1.2/
#          1.3/
#            name
#            version
#            gemspec
#            deps
#
set -e
. rpg-sh-setup

[ "$*" ] || set -- '--help'; ARGV="$@"
USAGE '${PROGNAME} [-f] <file>...
Register a gem in the package database and write location stdout.'

force=false
test "$1" = '-f' && {
    force=true
    shift
}

for file in "$@"
do
    # Information we can extract from the gem name.
    gemname=$(basename $file .gem)
    package=${gemname%-*}
    version=${gemname##*-}

    # These are directories and file locations into the package database.
    packagedir="$RPGDB/$package/$version"
    gemspec="$packagedir/gemspec"
    deps="$packagedir/deps"

    # Try to exit if the package is already registered and looks okay. The
    # `-f` argument can be used to override and force the package to be
    # registered again.
    if test -f "$packagedir/gemspec" -a -f "$packagedir/name"
    then
        if $force
        then notice "$package $version already registered: proceeding due to -f"
        else notice "$package $version already registered: bypassing"
             echo "$packagedir"
             exit 0
        fi
    else
        notice "$package $version -> $packagedir"
    fi

    # Create the package directory, write `name` and `version` files,
    # extract and write gemspec related files.
    #
    # The `name` and `version` files are redundant since that info can be
    # obtained from `$(basename $(dirname <path>))` and `$(basename <path>)`,
    # but having them there makes some things a bit easier.
    mkdir -p "$packagedir"
    echo "$package" > "$packagedir/name"
    echo "$version" > "$packagedir/version"
    rpg-unpack -cm "$file" > "$gemspec"
    rpg-package-spec -i "$gemspec"
    echo "$packagedir"
done
