# encoding:utf-8
import json
import os
import sys

fp = open('allrecipe.json','rb')
data = json.load(fp)

ft = open('allrecipe.ltsv','wb')
ft.write('title:料理\n') # カレント

for key in data:
    ft.write(' title:'+key.encode('utf-8')+'\n') # カテゴリ
    for key2 in data[key]:
        ft.write('  title:'+key2['title'].encode('utf-8')+'\turl:'+key2['link'].encode('utf-8')+'\text:html\timage_path:'+key2['iamge_path'].encode('utf-8')+'\n') # タイトル
