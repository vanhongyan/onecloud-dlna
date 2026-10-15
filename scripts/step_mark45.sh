#!/bin/bash
python3 - <<'PYEOF'
from PIL import Image, ImageDraw
FB='/dev/fb0'
img=Image.new('RGB',(1920,1080),(40,40,40))
d=ImageDraw.Draw(img)
d.rectangle([0,0,1919,1079],outline=(255,255,0),width=8)
d.rectangle([0,0,1279,719],outline=(255,255,255),width=8)
d.line([960,300,960,780],fill=(0,255,255),width=8)
d.line([660,540,1260,540],fill=(0,255,255),width=8)
def block(x,y,c):
    d.rectangle([x,y,x+90,y+90],fill=c)
block(60,60,(255,255,255))       # A 窗口内左上
block(1600,900,(255,255,0))      # B 窗口外右下
block(1600,60,(255,0,255))       # C 窗口外右上
block(60,900,(0,255,0))          # D 窗口外左下
raw=img.convert('RGB').tobytes()
with open(FB,'r+b') as f:
    f.write(raw)
print('MARK-DONE')
PYEOF
echo M-DONE
