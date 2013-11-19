# encoding:utf-8
import json
import os
import sys

fp = open('allrecipe.json','rb')
data = json.load(fp)
i = 1

for key in data:
    os.mkdir(key)
    for key2 in data[key]:
        os.mkdir(key+"/"+key2['title'])
        path = key+"/"+key2['title']+"/recipe"+str(i)
        link = "レシピのリンク先はこちら -> "+key2['link']+"\n"+"画像のリンク先はこちら -> "+key2['iamge_path']
        f=open(path,"w")
        f.write(link)
        f.close()
