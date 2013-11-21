all: yaml ltsv
yaml: clean
	ruby stations2yaml > stations.yaml
ltsv: clean
	ruby stations2ltsv > stations.ltsv
clean:
	/bin/rm -f stations.yaml stations.ltsv
