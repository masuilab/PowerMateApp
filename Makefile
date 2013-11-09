PROJECT = PowerMateApp.xcodeproj	
BUILD_SCHEME_TUMBLR = PMTumblr
BUILD_SCHEME_FACEBOOK = PMFacebook

default: clean setup all

clean: 
	xcodebuild clean \
		-project ${PROJECT} \
		-alltargets
setup:
	git submodule sync --quiet
	git submodule update --init
	git submodule foreach --recursive --quiet "git submodule sync --quiet && git submodule update --init"

all: tumblr facebook

tumblr:
	xcodebuild \
		-target ${BUILD_SCHEME_TUMBLR} \
		-configuration Release

facebook:
	xcodebuild \
		-target ${BUILD_SCHEME_FACEBOOK} \
		-configuration Release
