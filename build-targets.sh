#! /usr/bin/env bash
#
# author: Heinz Blaettner       heinz@fabmail.org
#
# use: shellcheck -ax
#
##############################################################################
SCRIPT=$(readlink -f "$0")
SCRIPT_DIR=$(dirname  "$SCRIPT")
PN=$(basename "$0")

readonly SYNTAX_FILE="$SCRIPT_DIR/target-syntax-modules.txt"
readonly CPU_FILE="$SCRIPT_DIR/target-cpus.txt"
readonly TARGETS_FILE="$SCRIPT_DIR/targets.txt"

set -euo pipefail   # at the begin of a script prevent all above errors

##########################################################
do_build()
{
    build_dir="build-${tcpu}-${tsyntax}"
    #build_dir="build"
    mkdir "$build_dir"
    cd  "$build_dir"
    cmake -DVASM_CPU="${tcpu}" -DVASM_SYNTAX="${tsyntax}" ..
    make
    cd -
    #mv "$build_dir" "$Build_dir"
    printf "### build <%s> DONE\n" "$build_dir"
}
##########################################################
### main
###########################################################
echo "### $PN"

# check CPU_FILE exists
if [[ -s "$CPU_FILE" ]] ; then
    printf "# CPU_FILE	=<%s>\n" "$CPU_FILE"
    ### now read CPU_FILE
    #TCPUS=$(grep -v ^# "$CPU_FILE")
else
    printf "# ERR: NOT EXIST CPU_FILE	=<%s>\n" "$CPU_FILE"
    exit 1
fi

# check SYNTAX_FILE exists
if [[ -s "$SYNTAX_FILE" ]] ; then
    printf "# SYNTAX_FILE	=<%s>\n" "$SYNTAX_FILE"
    ### now read SYNTAX_FILE
    # TSYNTAX=$(grep -v ^# "$CPU_FILE")
else
    printf "# ERR: NOT EXIST SYNTAX_FILE	=<%s>\n" "$SYNTAX_FILE"
    exit 1
fi

# check TARGETS_FILE exists
if [[ -s "$TARGETS_FILE" ]] ; then
    printf "# TARGETS_FILE	=<%s>\n" "$TARGETS_FILE"
else
    printf "# ERR: NOT EXIST TARGETS_FILE	=<%s>\n" "$TARGETS_FILE"
    exit 1
fi

set +x
#######################################
grep -v ^# "$TARGETS_FILE" | while read -t5 -r tcpu tsyntax
do
    printf "### BUILD: tcpu=<%s> tsyntax=<%s>\n" "$tcpu" "$tsyntax"
    if ! grep -F -x "$tcpu"  "$CPU_FILE" ; then
	printf "#ERR: cpu=<%s> not available\n" "$tcpu"
	exit 2
    fi
    if ! grep -F -x "$tsyntax"  "$SYNTAX_FILE" ; then
	printf "#ERR: syntax=<%s> not available\n" "$tsyntax"
	exit 2
    fi
    do_build "$tcpu" "$tsyntax"
    echo
done

