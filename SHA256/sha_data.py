#!/usr/bin/python
# -*- coding: utf-8 -*-
from base64 import b16decode
import hashlib

# 建立 SHA1 物件
fin=open('256input.txt','w+')
fout=open('256output.txt','w+')
##a=1
##x=str(a)
for text in range(100):
    print(text)
    text=str(text)
    ascii_values=''
    x2=''
    for character in text:
        a =ord(character)
        hex=format(a,'b').zfill(8)
        ascii_values+=str(a)
        x2+=hex
    s = hashlib.sha256()
    s.update(text.encode('utf-8'))
    h = s.hexdigest()
    fout.write(h)
    fout.write('\n')
    print("hash:",h)
    ##==============================================
    l=len(text)*8
    ##print(ascii_values)
    print(x2)
    print("lens:",l)
    l=format(l,'b').zfill(64)
    x3=x2+'1'
    print(x3)
    x4=x3.ljust((512-64),'0')+l
    print(x4)
    fin.write(x4)
    fin.write('\n')
    ##print(len(x4))
