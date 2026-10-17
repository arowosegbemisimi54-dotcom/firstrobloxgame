from PIL import Image,ImageDraw,ImageFilter
import random,math,json
from pathlib import Path
random.seed(18)
W,H=240,150
pictures=[]
for variant in range(2):
 im=Image.new('RGB',(W,H));d=ImageDraw.Draw(im)
 top=(69,110,125) if variant==0 else (44,61,87)
 bottom=(230,186,124) if variant==0 else (199,136,93)
 for y in range(H):
  t=min(1,y/95);d.line((0,y,W,y),fill=tuple(int(a+(b-a)*t) for a,b in zip(top,bottom)))
 for i in range(80):
  x=random.randrange(W);y=random.randrange(15,70);c=(190,183,157) if variant==0 else (133,126,128)
  d.line((x,y,x+random.randrange(4,26),y-1),fill=c,width=random.randrange(1,3))
 d.ellipse((172,32,194,54),fill=(248,217,156))
 for layer,col in enumerate([(105,118,121),(140,109,88),(169,105,66)]):
  y=75+layer*14
  points=[(-10,H),(-10,y)]
  for x in range(-10,W+20,17): points.append((x,y-random.randrange(0,20)))
  points.extend([(W+10,H)]);d.polygon(points,fill=col)
  for i in range(80):
   x=random.randrange(W); yy=random.randrange(y,H)
   if im.getpixel((x,yy))==col:
    cc=tuple(max(0,min(255,v+random.randrange(-18,19))) for v in col)
    d.line((x,yy,x+random.randrange(2,9),yy),fill=cc,width=1)
 if variant==0:
  # Mesas with shaded faces and fine sedimentary seams.
  for x,y,w,h in [(17,67,54,40),(78,81,35,25),(153,87,37,20)]:
   d.polygon([(x-8,y+h),(x+4,y),(x+w-5,y),(x+w+12,y+h)],fill=(151,76,47))
   d.polygon([(x+4,y),(x+15,y+3),(x+7,y+h),(x-8,y+h)],fill=(96,65,53))
   for yy in range(y+5,y+h,6):d.line((x+7,yy,x+w-3,yy-2),fill=(190,120,67),width=2)
  d.polygon([(90,150),(115,117),(122,111),(118,128),(126,150)],fill=(201,161,107))
  for x,y,h in [(28,144,41),(214,143,32),(184,136,17)]:
   col=(41,67,57);d.line((x,y,x,y-h),fill=col,width=5)
   d.line([(x,y-h//2),(x-9,y-h//2-2),(x-9,y-h+10)],fill=col,width=4)
   d.line([(x,y-h//3),(x+8,y-h//3-2),(x+8,y-h+15)],fill=col,width=4)
 else:
  # A quiet roadside cafe, telephone poles and reflected light after rain.
  d.polygon([(0,122),(240,113),(240,150),(0,150)],fill=(51,58,65))
  d.rectangle((57,78,169,114),fill=(202,185,144))
  d.polygon([(50,79),(67,64),(154,64),(178,80)],fill=(99,59,48))
  d.rectangle((59,98,168,106),fill=(149,57,45))
  for x in [66,92,132,150]:
   d.rectangle((x,84,x+14,97),fill=(235,188,93));d.line((x+7,84,x+7,97),fill=(58,74,72),width=2)
  d.rectangle((113,86,125,113),fill=(48,65,67))
  d.rectangle((100,68,132,77),fill=(224,163,80))
  for i in range(40):
   x=random.randrange(55,175);y=random.randrange(121,149)
   d.line((x,y,x+random.randrange(3,15),y),fill=random.choice([(146,114,75),(190,136,70),(78,80,80)]),width=1)
  for x,h in [(23,69),(206,49)]:
   d.line((x,116,x,116-h),fill=(45,42,41),width=3);d.line((x-9,116-h+6,x+9,116-h+6),fill=(45,42,41),width=2)
  d.arc((-5,22,225,66),0,180,fill=(54,49,49),width=1)
 # Brush grain; no text or borrowed art assets.
 for i in range(250):
  x=random.randrange(W);y=random.randrange(H);base=im.getpixel((x,y));delta=random.choice([-8,-4,4,8]);c=tuple(max(0,min(255,a+delta)) for a in base)
  d.line((x,y,min(W-1,x+random.randrange(1,4)),y),fill=c)
 im=im.filter(ImageFilter.GaussianBlur(.5)).resize((96,60),Image.Resampling.LANCZOS).quantize(colors=16)
 im.convert('RGB').resize((720,450)).save('/tmp/diner-painting-'+str(variant)+'.png')
 palette=im.getpalette();rows=[]
 # Merge identical horizontal runs vertically to keep GUI allocation bounded.
 active={};rects=[]
 for y in range(60):
  spans=[];x=0
  while x<96:
   c=im.getpixel((x,y));start=x
   while x<96 and im.getpixel((x,y))==c:x+=1
   spans.append((start,x-start,c))
  nextactive={}
  for span in spans:
   if span in active:r=active.pop(span);r[3]+=1
   else:r=[span[0],y,span[1],1,span[2]+1]
   nextactive[span]=r
  rects.extend(active.values());active=nextactive
 rects.extend(active.values())
 pictures.append({'palette':[palette[i:i+3] for i in range(0,48,3)],'rects':rects})
print('Painting brush patches:',[len(p['rects']) for p in pictures])
# Generated immutable artwork data, rendered as batched rectangular color patches.
s='-- Original painted desert landscapes, authored for this diner. No external image IDs.\nreturn {\n'
for p in pictures:
 s+=' {palette={'+','.join('Color3.fromRGB('+','.join(map(str,c))+')' for c in p['palette'])+'},\n patches={\n'
 s+='\n'.join(' {'+','.join(map(str,r))+'},' for r in p['rects'])+'\n }},\n'
s+='}\n';Path('src/client/DinerPaintings.luau').write_text(s)
