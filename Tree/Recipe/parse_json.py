# encoding:utf-8
import json
import os
import sys

reload(sys)
sys.setdefaultencoding('utf-8')

fp = open('allrecipe.json','rb')
data = json.load(fp)

for key in data:
    os.makedirs(key.encode('utf-8'))
    for key2 in data[key]:
        print key2['title'].encode('utf-8')
        path1 = key+"/"+key2['title']
        print path1
        try:
            os.makedirs(path1)
        except:
            print "I'm sorry."
        path2 = key+"/"+key2['title']+"/recipe.txt"
        link = u"レシピのリンク先はこちら -> "+key2['link']+"\n"+u"画像のリンク先はこちら -> "+key2['iamge_path']
        f=open(path2,"w")
        f.write(link.encode('utf-8'))
        f.close()
