#
# */*.ltsv からjson生成
#
#

default: clean json jq

clean:
	echo "### Removing data.json... ###"
	rm data.json

json:
	echo "### Merge all ltsv files into data.json..."
	ruby ltsv2json Photos/photos.ltsv Aozora/aozora.ltsv Stations/stations.ltsv > data.json
#	ruby ltsv2json */*.ltsv > data.json

jq:
	echo "### Validating data.json..."
	cat data.json | jq '.'
	echo "### Sweet! data.json is VALID!"
