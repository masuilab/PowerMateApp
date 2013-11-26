PROJECT = PowerMateApp.xcodeproj
BUILD_SCHEME = PowerMateDial

default: clean setup json app

clean:
	xcodebuild clean \
		-project ${PROJECT} \
		-alltargets

setup:
	git submodule sync --quiet
	git submodule update --init
	git submodule foreach --recursive --quiet "git submodule sync --quiet && git submodule update --init"

json:
	cd Data && make && cd ../
app:
	xcodebuild \
		-target ${BUILD_SCHEME} \
		-configuration Release

run:
	open build/Release/${BUILD_SCHEME}.app

dmg:
	/bin/rm -f /tmp/PowerMateDial.dmg
	hdiutil create -srcfolder build/Release/PowerMateDial.app -volname PowerMateDial /tmp/PowerMateDial.dmg

publish: dmg
	scp /tmp/PowerMateDial.dmg pitecan.com:/www/www.pitecan.com/tmp
