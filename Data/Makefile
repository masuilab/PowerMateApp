#
# */*.ltsv からjson生成
#
#

default: clean json jq

clean:
	echo "### Removing data.json... ###"
	rm data.json

recipejson:
	ruby ltsv2json Recipe/allrecipe.ltsv > Recipe/allrecipe.result.json
	cat Recipe/allrecipe.result.json | jq '.'

json:
	echo "### Merge all ltsv files into data.json..."
	ruby ltsv2json Photos/photos.ltsv Aozora/aozora.ltsv Stations/stations.ltsv > data.json

jsonall:
	ruby ltsv2json */*.ltsv > .data.json
	cat .data.json | jq '.'
	mv .data.json data.json


jq:
	echo "### Validating data.json..."
	cat data.json | jq '.'
	echo "### Sweet! data.json is VALID!"
