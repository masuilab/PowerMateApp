import json
import os

fp = open('allrecipe.json','rb')
data = json.load(fp)

for key in data:
    os.mkdir(key)

