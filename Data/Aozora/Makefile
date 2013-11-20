# 青空文庫からリストをゲット
get:
	/bin/rm -f list_person_all.zip list_person_all.csv
	wget http://www.aozora.gr.jp/index_pages/list_person_all.zip
	unzip list_person_all.zip
	nkf list_person_all.csv > list_person_all.csv.utf
	/bin/mv list_person_all.csv.utf list_person_all.csv

# yamlに変換する。読みは手作業で追加する...
list:
	ruby aozora2yaml > aozora.list
ltsv:
	ruby yaml2ltsv aozora.yaml > aozora.ltsv

