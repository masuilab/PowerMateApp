# -*- coding: utf-8 -*-
#
# news.ltsv, aozora.ltsvなどからjson生成
#

CONTENTS = \
	News/news.ltsv \
	Photos/photos.ltsv \
	Aozora/aozora.ltsv \
	Stations/stations.ltsv \
	YouTube/youtube.ltsv \
	GIF/gif.ltsv \
	Comics/comics.ltsv

json: getnews
	ruby ltsv2json ${CONTENTS} | jq . > data.json

getnews:
	cd News; make

