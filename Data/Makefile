#
# */*.ltsv からjson生成
#
#

default: clean json jq

clean:
	echo "### Removing data.json... ###"
	rm data.json

json:
	echo "### Merge all ltsv file into data.json..."
	ruby ltsv2json */*.ltsv > data.json
#	ruby yaml2json */*.yaml

jq:
	echo "### Validate data.json"
	cat data.json | jq '.'
	echo ### Sweet! Make is successfully finished!"