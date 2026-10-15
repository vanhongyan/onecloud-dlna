from PIL import Image, ImageDraw
img = Image.new('RGB', (1920, 1080), (40, 40, 40))
d = ImageDraw.Draw(img)
d.rectangle([0, 0, 1919, 1079], outline=(255, 255, 0), width=8)
d.rectangle([0, 0, 1279, 719], outline=(255, 255, 255), width=8)
d.line([960, 300, 960, 780], fill=(0, 255, 255), width=8)
d.line([660, 540, 1260, 540], fill=(0, 255, 255), width=8)

def block(x, y, c):
    d.rectangle([x, y, x + 90, y + 90], fill=c)

block(60, 60, (255, 255, 255))
block(1600, 900, (255, 255, 0))
block(1600, 60, (255, 0, 255))
block(60, 900, (0, 255, 0))
with open('/dev/fb0', 'r+b') as f:
    f.write(img.convert('RGB').tobytes())
print('MARK-DONE')
