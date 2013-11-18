import os
import sys

argvs = sys.argv

# 第一引数:ファイル名 第二引数:拡張子
for i in range(50):
    f=open(argvs[1]+str(i)+argvs[2],"w")
