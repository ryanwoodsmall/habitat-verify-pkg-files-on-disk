#!/bin/bash

# we'll use this in a few places
scriptname="$(basename ${BASH_SOURCE[0]})"

# hab-specific path
scriptpath="$(realpath ${BASH_SOURCE[0]})"
runtimepathfile="$(dirname ${scriptpath})/../RUNTIME_PATH"
if [ -e "${runtimepathfile}" ] ; then
	PATH="$(cat ${runtimepathfile}):${PATH}"
fi
export PATH

# and these
: ${hab:="/hab"}
: ${habpkgs:="${hab}/pkgs"}

# these too
function scriptecho() {
	echo -e "${scriptname}: ${1}"
}
function failexit() {
	scriptecho "failed: ${1}" 1>&2
	exit 1
}

# we needs some programs
for req in b2sum hab seq ; do
	which ${req} >/dev/null 2>&1 || failexit "required program '${req}' not found"
done

# warning to stderr on non-root
if [ ${UID} -ne 0 ] ; then
	scriptecho "consider running this as root to mitigate issues with permissions\n" 1>&2
fi

# usage function
function usage() {
	cat<<-EOF
	usage: ${scriptname} [--help] [<origin/package/version/release> <origin/package/version/release> <...>]

	arguments:
	  --help : this usage
	  origin/package/version/release : optional list of packages to verify

	if run with no arguments, all packages installed under ${habpkgs} will be verified

	successful verification will ouput "origin/package/version/release: verified"
	unsuccessful checks will output "origin/package/version/release: failed" followed by the list of problem files
	EOF
}

if [ ${#} -ge 1 ] ; then
	for a in ${@} ; do
		if [[ ${a} =~ --help ]] ; then
			usage
			exit 0
		fi
	done
	pkglist=( "${@}" )
else
	pkglist=( $(hab pkg list --all) )
fi

# used to track exit value
vsum=0

for pkg in ${pkglist[@]} ; do
	pkgcheck=()
	pkgdir="${habpkgs}/${pkg}"
	pkgfiles="${pkgdir}/FILES"
	echo -n "${pkg}: "
	test -e "${pkgfiles}" -a -r "${pkgfiles}"
	if [ ${?} -ne 0 ] ; then
		((vsum++))
		echo "failed"
		scriptecho "'${pkgfiles}' does not seem to exist or is unreadable" 1>&2
		echo
		continue
	fi
	# suppress "b2sum: WARNING: 5 lines are improperly formatted" on stderr
	readarray -t pkgcheck < <(b2sum --check "${pkgfiles}" 2>/dev/null)
	if [[ ${pkgcheck[@]} =~ ': FAILED' ]] ; then
		((vsum++))
		echo "failed"
	else
		echo "verified"
	fi
	for i in $(seq 0 ${#pkgcheck[@]}) ; do
		l="${pkgcheck[${i}]}"
		if [[ ${l} =~ ': OK' ]] ; then
			continue
		fi
		echo "${l}"
	done
done

if [[ ${vsum} == 0 ]] ; then
  exit 0
elif [[ $((${vsum}%256)) == 0 ]] ; then
  exit 1
else
  exit $((${vsum}%256))
fi
