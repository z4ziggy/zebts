#!/bin/bash

##
## get sources
##

get_src() {
	CWD=`pwd`
	mkdir src
	cd src

	git clone --recursive https://github.com/RangeNetworks/openbts.git
	git clone --recursive https://github.com/RangeNetworks/smqueue.git
	git clone https://github.com/RangeNetworks/liba53.git

	svn checkout http://voip.null.ro/svn/yatebts/trunk yatebts
	svn checkout http://voip.null.ro/svn/yate/trunk yate

	git clone git://git.osmocom.org/osmo-trx
	git clone https://github.com/mossmann/hackrf.git
	git clone https://github.com/Nuand/bladeRF.git
	git clone https://github.com/airspy/host airspy

	(cd $CWD/patches && for d in `echo *.debian`; do cp -a $d $CWD/src/${d/./\/}; done)
	(cp bladeRF/host/utilities/bladeRF-cli/src/cmd/doc/cmd_help.h{.in,})
	(cd yate && patch -p1 -i $CWD/patches/yate-typedef-armhf.patch)
	(cd smqueue && patch -p2 -i $CWD/patches/smqueue-libosip2.patch)
	(cd smqueue/SR/CommonLibs && patch -p1 -i $CWD/patches/CommonLibs-no-coredump.patch)
	(cd smqueue/CommonLibs && patch -p1 -i $CWD/patches/CommonLibs-no-coredump.patch)
	(cd openbts/CommonLibs && patch -p1 -i $CWD/patches/CommonLibs-no-coredump.patch)
	(cd openbts && patch -p1 -i $CWD/patches/openbts-no-coredump.patch)
	(cd openbts && patch -p1 -i $CWD/patches/openbts-bladerf.patch)

	# uhd - not needed anymore

	#git clone https://github.com/balint256/gr-baz.git
	#git clone https://github.com/guruofquality/grextras.git

	#git clone --recursive http://git.gnuradio.org/git/gnuradio.git
	#git clone https://github.com/EttusResearch/uhd
	#git clone git://git.osmocom.org/rtl-sdr
	#git clone git://git.osmocom.org/gr-osmosdr
	#git clone git://git.osmocom.org/gr-iqbal.git

	#(cd gnuradio && git checkout maint)
	#(cd gr-iqbal ; git submodule init ; git submodule update)

	cd ..
}

##
## build
##

export MFLG=-j32

build_uhd() {
	cd uhd/host
	mkdir build
	cd build
	make $MFLG clean
	cmake -DPythonLibs_FIND_VERSION:STRING=2.7 -DPythonInterp_FIND_VERSION:STRING=2.7 ../
	make
	[ $? -ne 0 ] && exit $?
	make $MFLG install
	/usr/local/lib/uhd/utils/uhd_images_downloader.py
	cd ..
}

build_gnuradio() {
	cd gnuradio
	mkdir build
	cd build
	make $MFLG clean
	cmake -DCMAKE_C_FLAGS=-march=armv7-a -mthumb-interwork -mfloat-abi=hard -mfpu=neon -mtune=cortex-a9 -DCMAKE_ASM_FLAGS=-march=armv7-a -mthumb-interwork -mfloat-abi=hard -mfpu=neon -DENABLE_BAD_BOOST=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -DPythonLibs_FIND_VERSION:STRING=2.7 -DPythonInterp_FIND_VERSION:STRING=2.7 ../
	make $MFLG 
	[ $? -ne 0 ] && exit $?
	make $MFLG install
	ldconfig
	chmod +x /usr/local/libexec/gnuradio/grc_setup_freedesktop
	/usr/local/libexec/gnuradio/grc_setup_freedesktop install
	cd ..
	cd ..
}

build_rtl-sdr() {
	cd rtl-sdr
	cmake -DPythonLibs_FIND_VERSION:STRING=2.7 -DPythonInterp_FIND_VERSION:STRING=2.7 .
	make $MFLG clean
	make $MFLG 
	[ $? -ne 0 ] && exit $?
	make $MFLG install
	cd ..
}

build_hackrf() {
	cd hackrf
	cmake -DINSTALL_UDEV_RULES=ON host/
	make $MFLG clean
	make $MFLG 
	[ $? -ne 0 ] && exit $?
	make $MFLG install
	cd ..
}

build_gr-iqbal() {
	cd gr-iqbal
	mkdir build
	cd build
	cmake -DPythonLibs_FIND_VERSION:STRING=2.7 -DPythonInterp_FIND_VERSION:STRING=2.7 ..
	make $MFLG clean
	make $MFLG 
	[ $? -ne 0 ] && exit $?
	make $MFLG install
	cd ..
	cd ..
}

build_bladeRF() {
	cd bladeRF/host
	cmake .
	make $MFLG clean
	make
	[ $? -ne 0 ] && exit $?
	make $MFLG install
	cd ../..
}

build_airspy() {
	cd airspy
	mkdir build
	cd build
	cmake -DPythonLibs_FIND_VERSION:STRING=2.7 -DPythonInterp_FIND_VERSION:STRING=2.7 ..
	make $MFLG clean
	make $MFLG 
	[ $? -ne 0 ] && exit $?
	make $MFLG install
	cd ..
	cd ..
}

build_gr-osmosdr() {
	cd gr-osmosdr
	cmake -DPythonLibs_FIND_VERSION:STRING=2.7 -DPythonInterp_FIND_VERSION:STRING=2.7 .
	make $MFLG clean
	make $MFLG 
	[ $? -ne 0 ] && exit $?
	make $MFLG install
	cd ..
}

build_gr-baz() {
	cd gr-baz
	mkdir build
	cd build
	cmake -DPythonLibs_FIND_VERSION:STRING=2.7 -DPythonInterp_FIND_VERSION:STRING=2.7 ..
	make $MFLG clean
	make $MFLG 
	[ $? -ne 0 ] && exit $?
	make $MFLG install
	cd ..
	cd ..
}

build_grextras() {
	cd grextras
	mkdir build
	cd build
	cmake -DPythonLibs_FIND_VERSION:STRING=2.7 -DPythonInterp_FIND_VERSION:STRING=2.7 ..
	make $MFLG clean
	make $MFLG 
	[ $? -ne 0 ] && exit $?
	make $MFLG install
	cd ..
	cd ..
}

build_liba53() {
	cd liba53
	make $MFLG 
	[ $? -ne 0 ] && exit $?
	make $MFLG install
	cd ..
}

build_yatebts() {
	cd yatebts
	./autogen.sh
	./configure --without-yate LDFLAGS="-lpthread"

	cd mbts/Peering
	make $MFLG 
	[ $? -ne 0 ] && exit $?
	make $MFLG install
	cd ../..

	cd mbts/TransceiverRAD1
	make $MFLG 
	[ $? -ne 0 ] && exit $?
	make install
	cd ../..
	cd ..
}

build_openbts() {
	cd openbts
	#autoreconf -i
	./autogen.sh
	./configure --with-uhd --target=armv7
	make $MFLG 
	[ $? -ne 0 ] && exit $?
	make $MFLG install
	mkdir /etc/OpenBTS
	sqlite3 -init apps/OpenBTS.example.sql /etc/OpenBTS/OpenBTS.db ".quit"
	cd ..
}

build_subscriberRegistry() {
	cd subscriberRegistry
	./autogen.sh
	./configure
	make $MFLG
	[ $? -ne 0 ] && exit $?
	make $MFLG install
	mkdir -p /var/lib/asterisk/sqlite3dir
	cd ..
	sqlite3 -init subscriberRegistry.example.sql /etc/OpenBTS/sipauthserve.db ".quit"
}

build_smqueue() {
	cd smqueue
	autoreconf -i
	./configure
	make $MFLG
	[ $? -ne 0 ] && exit $?
	make $MFLG install
	sqlite3 -init smqueue/smqueue.example.sql /etc/OpenBTS/smqueue.db ".quit"
	cd ..
}

# manual
#build_hackrf
#build_bladeRF
#build_liba53
#build_yatebts
#build_openbts
#build_smqueue

# debian way
#find . -name debian -exec bash -c "cd '{}'/.. && dpkg-buildpackage -b -j32" \;
#find . -name *.deb -exec cp '{}' debs/ \;
#(cd debs && dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz)

[ $# -gt 0 ] && $1

