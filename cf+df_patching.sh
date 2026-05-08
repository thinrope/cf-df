#!/bin/bash

#
# cf+df_patching.sh
# Patch copy.fail[1] and dirtyfrag[2] related CVEs
#
# https://github.com/thinrope/cf-df/
#
# Gentoo DEPS:
# 	>=app-shells/bash-5.1:	bash	# for associative arrays
# 	sys-apps/coreutils:	echo mv uname
# 	sys-apps/kmod:		lsmod rmmod
# 	sys-apps/grep:		grep

declare -A CVEs=(
	[algif_aead]=CVE-2026-31431
	[esp4]=CVE-2026-31431
	[esp6]=CVE-2026-31431
	[rxrpc]=CVE-2026-43500)

function unload_kmod () {
	echo rmmod $1
	rmmod $1
}

function patch_kmod () {
	echo mv $1 $2
	mv $1 $2
}

KMOD_TDIR=/lib/modules/$(uname -r)
cd ${KMOD_TDIR} 2>/dev/null || (echo "ERROR: KMOD_TDIR=${KMOD_TDIR} does not exist! No modules supported by kernel?"; exit -1)
KMOD_CDIR=/lib/modules/$(uname -r)/kernel/crypto/
cd ${KMOD_CDIR} 2>/dev/null || (echo "ERROR: KMOD_CDIR=${KMOD_CDIR} does not exist! No cryptomodules installed?"; exit -2)

for MODULE in "${!CVEs[@]}"
do
	$(lsmod |grep -q ^${MODULE}) && unload_kmod ${MODULE}
done

for M in "${!CVEs[@]}"
do
	MODULE=$(ls -1 $M.ko* 2>/dev/null)
	if [ ! -z ${MODULE} ] && [ -e ${MODULE} ]
	then
		if [[ ${MODULE} =~ "CVE" ]]
		then
			echo "${MODULE} <- already patched"
		else
			patch_kmod "$MODULE" "${MODULE}.${CVEs[$M]}"
		fi
	fi
done

# In case (hopefully!) we were testing some of the PoCs before, this is needed to restore the su binary without reboot
echo -n 3 > /proc/sys/vm/drop_caches
