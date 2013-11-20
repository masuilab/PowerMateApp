# encoding:utf-8
import json
import os
import sys

fp = open('allrecipe.json','rb')
data = json.load(fp)

ft = open('allrecipe.ltsv','wb')
ft.write('title:料理\n') # カレント

for key in data:
<<<<<<< HEAD
    ft.write('  title:'+key.encode('utf-8')+'\n') # カテゴリ
    for key2 in data[key]:
        ft.write('    title:'+key2['title'].encode('utf-8')+'\turl:'+key2['link'].encode('utf-8')+'\text:"html"\timage_path:'+key2['iamge_path'].encode('utf-8')+'\n') # タイトル
=======
    ft.write('\ttitle:'+key.encode('utf-8')+'\n') # カテゴリ
    for key2 in data[key]:
        ft.write('\t\ttitle:'+key2['title'].encode('utf-8')+',url:'+key2['link'].encode('utf-8')+',ext:"html",image_path:'+key2['iamge_path'].encode('utf-8')+'\n') # タイトル
>>>>>>> 45b1b40b183a20217d6da37e7802ff1f7034d47a
