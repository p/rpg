#!/bin/sh
# The `rpg-install` program
#
set -e
. rpg-sh-setup

[ "$*" ] || set -- '--help'; ARGV="$@"
USAGE '${PROGNAME} <package> [[-v] <version>] ...
       ${PROGNAME} <package>[/<version>]...
Install packages into rpg environment.'

RPGSESSION="$RPGDB/@session"
sessiondir="$RPGSESSION"
packlist="$sessiondir"/package-list

rm -rf "$sessiondir"
mkdir -p "$sessiondir"

notice "writing argv"
for a in "$@"
do echo "$a"
done > "$sessiondir"/argv

notice "writing user package-list"
rpg-parse-package-list "$@"  |
sed "s/^/@user /"            > "$packlist"

# see if we need to update the index
rpg update -s

# Tell the user we're about to begin.
numpacks=$(wc -l "$packlist" | sed 's/[^0-9]//g')
heed "calculating dependencies for $numpacks package(s) ..."

notice "entering dep solve loop"
changed=true
while $changed
do
    </dev/null >"$packlist+"

    notice "solving deplist"
    cut -d ' ' -f 2- "$packlist"                |
    rpg-solve -u                                |
    tee "$sessiondir/solved"                    |
    while read package op version
    do
        gemfile=$(rpg-fetch "$package" "$version")
        packagedir=$(rpg-package-register "$gemfile")

        notice "adding $package $version deps to packlist"
        grep '^runtime ' < "$packagedir"/dependencies |
        cut -d ' ' -f 2-                              |
        sed "s/^/$package /"                          |
        cat "$packlist" -
    done |
    sort -b -u -k 2,4 >> "$packlist+"

    if cmp -s "$packlist" "$packlist+"
    then
        notice "package list did not change"
        changed=false
    else
        notice "package list changed"
        # diff "$packlist" "$packlist+" 1>&2 || true
        changed=true
    fi
    mv "$packlist+" "$packlist"
done

# Tell the user we're about to begin.
numpacks=$(wc -l $packlist | sed 's/[^0-9]//g')
heed "installing $numpacks total package(s):
$(cat "$sessiondir"/solved)"

# echo "HERES THE PACKAGE LIST:"
# cat "$packlist"
#
# echo "HERES YOUR JANK:"
# cat "$sessiondir"/solved

cat "$sessiondir"/solved |
xargs -n 3 rpg-package-install

heed "installation complete"

true
