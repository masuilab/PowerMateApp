PROJECT = PowerMateApp.xcodeproj
BUILD_SCHEME = PowerMateDial

default: check clean setup app json

check:
	if [ -z `which jq` ]; then echo 'Require jq (e.g. brew install jq)'; exit 1; fi;

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
