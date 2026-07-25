"""Run a scripted battle on a walled hill-fort (gate choke + elevated platform) and
emit a self-contained 3D isometric replay viewer: ../BATTLE_3D.html. Shows walls,
the gate choke, elevation (a hill), and figures moving/fighting/falling per round."""
import json, os, math
from engine import Board, Wall, Platform, LowCover, Figure, Metrics
from game import Game
from loader import load_all

HERE=os.path.dirname(__file__)
PACKETS, FACS = load_all()
TMP=FACS["Order of the Argent Templar"]; MOR=FACS["The Iron Horde of Mordor"]
ALL={**TMP,**MOR}

def battle():
    # A hill-fort: a wall across x=24 with a central GATE (gap y13-19); the Templars
    # stand on an elevated platform (hill) behind it; Mordor assaults from the east.
    board=Board(48,32,
        walls=[Wall(24,0,24,13,6.0), Wall(24,19,24,32,6.0),      # the gate wall
               Wall(24,13,26,13,6.0), Wall(24,19,26,19,6.0)],    # short gate jambs
        platforms=[Platform(2,6,22,26,3.0)],                     # the hill the fort sits on
        covers=[LowCover(30,8,34,12), LowCover(30,20,34,24), LowCover(36,14,40,18)])
    figs=[]
    # Templar defenders — shield line IN the gate, reach behind, arbalest on the hill, hero + sword reserve
    D=[("TMP_SHIELDBROTHER",24.6,14.2),("TMP_SHIELDBROTHER",24.6,17.8),
       ("TMP_HALBERDIER",22.5,16.0),("TMP_MARSHAL",23.0,16.0),
       ("TMP_ARBALEST",12.0,12.0),("TMP_SWORDBROTHER",20.0,20.0),
       ("TMP_GRANDMASTER",18.0,16.0)]
    for i,(d,x,y) in enumerate(D):
        f=Figure(TMP[d],0,f"T{i}",x,y,facing=0.0); figs.append(f)
    # Mordor assault from the east, spread wide to test the choke
    A=[("MOR_CAPTAIN",42,16),("MOR_BERSERKER",40,13),("MOR_WARRIOR",41,19),
       ("MOR_WARRIOR",43,10),("MOR_PIKEMAN",43,22),("MOR_ORC",39,7),
       ("MOR_ORC",39,25),("MOR_ARCHER",45,12),("MOR_WARG",44,28),("MOR_TROLL",46,16)]
    for i,(d,x,y) in enumerate(A):
        f=Figure(MOR[d],1,f"M{i}",x,y,facing=math.pi); figs.append(f)
    g=Game(board,figs,seed=7,metrics=Metrics(),max_rounds=12,record=True)
    res=g.run()
    geo={"w":board.w,"d":board.d,
         "walls":[{"x1":w.x1,"y1":w.y1,"x2":w.x2,"y2":w.y2,"h":w.height} for w in board.walls],
         "platforms":[{"x0":p.x0,"y0":p.y0,"x1":p.x1,"y1":p.y1,"top":p.top} for p in board.platforms],
         "covers":[{"x0":c.x0,"y0":c.y0,"x1":c.x1,"y1":c.y1} for c in board.covers]}
    return geo, g.frames, res

HTML=r"""<!doctype html><html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>CUS · 3D Battle Replay</title>
<style>
:root{--bg:#0e1016;--ink:#e8ecf5;--dim:#8a93a6;--gold:#c9a23f}
@media(prefers-color-scheme:light){:root{--bg:#e9ebf1;--ink:#1a1d26;--dim:#5a6273}}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);font:14px system-ui,sans-serif;overflow:hidden}
#hud{position:fixed;top:0;left:0;right:0;padding:10px 16px;display:flex;gap:14px;align-items:center;z-index:5;
 background:linear-gradient(var(--bg),transparent)}
#hud h1{font-size:15px;margin:0;letter-spacing:1px;color:var(--gold)}
#hud .sp{flex:1}#hud button{background:#20242f;color:var(--ink);border:1px solid #333c;border-radius:7px;padding:6px 12px;cursor:pointer;font-weight:600}
#lab{min-width:92px;font-weight:700}#leg{color:var(--dim);font-size:12px}
input[type=range]{width:min(46vw,520px)}
canvas{display:block}
</style></head><body>
<div id="hud"><h1>⚔ CUS · 3D BATTLE — the Gate of the Argent Templar</h1>
<button id="pp">▶ Play</button><span id="lab">Deploy</span>
<input id="sc" type="range" min="0" value="0" step="1"><span class="sp"></span>
<span id="leg">blue = Templar · red = Mordor · faded = down · ▲ = elevation</span></div>
<canvas id="cv"></canvas>
<script>
const GEO=__GEO__, FRAMES=__FRAMES__, RES=__RES__;
const cv=document.getElementById('cv'), cx=cv.getContext('2d');
let S=15, ZS=13, OX=0, OY=0;   // scale, z-scale, origin
function resize(){cv.width=innerWidth;cv.height=innerHeight; OX=innerWidth*0.30; OY=innerHeight*0.30;}
addEventListener('resize',resize); resize();
const c30=Math.cos(Math.PI/6), s30=Math.sin(Math.PI/6);
function iso(x,y,z){return [ (x-y)*c30*S+OX, (x+y)*s30*S - z*ZS + OY ];}
function quad(p,col){cx.beginPath();cx.moveTo(p[0][0],p[0][1]);for(let i=1;i<p.length;i++)cx.lineTo(p[i][0],p[i][1]);cx.closePath();cx.fillStyle=col;cx.fill();}
function ground(){
  // board tile
  const c=[iso(0,0,0),iso(GEO.w,0,0),iso(GEO.w,GEO.d,0),iso(0,GEO.d,0)];
  quad(c,'#171b24'); cx.strokeStyle='#2a3040';cx.lineWidth=1;
  cx.beginPath();cx.moveTo(c[0][0],c[0][1]);for(let i=1;i<4;i++)cx.lineTo(c[i][0],c[i][1]);cx.closePath();cx.stroke();
  // grid
  cx.strokeStyle='#20263340';
  for(let x=0;x<=GEO.w;x+=4){let a=iso(x,0,0),b=iso(x,GEO.d,0);cx.beginPath();cx.moveTo(a[0],a[1]);cx.lineTo(b[0],b[1]);cx.stroke();}
  for(let y=0;y<=GEO.d;y+=4){let a=iso(0,y,0),b=iso(GEO.w,y,0);cx.beginPath();cx.moveTo(a[0],a[1]);cx.lineTo(b[0],b[1]);cx.stroke();}
}
function prism(x0,y0,x1,y1,top,topcol,sidecol){
  // sides
  const corners=[[x0,y0],[x1,y0],[x1,y1],[x0,y1]];
  for(let i=0;i<4;i++){const a=corners[i],b=corners[(i+1)%4];
    quad([iso(a[0],a[1],0),iso(b[0],b[1],0),iso(b[0],b[1],top),iso(a[0],a[1],top)],sidecol);}
  quad([iso(x0,y0,top),iso(x1,y0,top),iso(x1,y1,top),iso(x0,y1,top)],topcol);
}
function terrain(){
  GEO.platforms.forEach(p=>prism(p.x0,p.y0,p.x1,p.y1,p.top,'#2c3446','#222a38'));
  GEO.covers.forEach(c=>quad([iso(c.x0,c.y0,0),iso(c.x1,c.y0,0),iso(c.x1,c.y1,0),iso(c.x0,c.y1,0)],'#243d2e'));
  GEO.walls.forEach(w=>{const dx=w.x2-w.x1,dy=w.y2-w.y1,L=Math.hypot(dx,dy)||1,nx=-dy/L*0.4,ny=dx/L*0.4;
    prism(Math.min(w.x1,w.x2)-0.2,Math.min(w.y1,w.y2)-0.2,Math.max(w.x1,w.x2)+0.2,Math.max(w.y1,w.y2)+0.2,w.h,'#3a4152','#2b3140');});
}
function token(f){
  const base=iso(f.x,f.y,f.z), top=iso(f.x,f.y,f.z+1.4);
  // drop line to ground for elevation read
  if(f.z>0.1){const g=iso(f.x,f.y,0);cx.strokeStyle='#ffffff22';cx.beginPath();cx.moveTo(g[0],g[1]);cx.lineTo(base[0],base[1]);cx.stroke();}
  const down = f.status!=='ok';
  let col = f.side===0 ? '#4d8fd6' : '#d65a4d';
  if(f.role==='Utility') col = f.side===0?'#c9a23f':'#d0a03a';
  if(down) col = f.side===0?'#33506e':'#6e3a33';
  const rad = f.r*S*0.9;
  // shadow
  cx.fillStyle='#00000040';cx.beginPath();cx.ellipse(base[0],base[1],rad,rad*0.5,0,0,7);cx.fill();
  // body pillar
  cx.strokeStyle=col;cx.lineWidth=Math.max(3,rad*0.8);cx.beginPath();cx.moveTo(base[0],base[1]);cx.lineTo(top[0],top[1]);cx.stroke();
  // head
  cx.fillStyle=col;cx.beginPath();cx.arc(top[0],top[1],rad*0.55,0,7);cx.fill();
  if(f.shape==='Circle'){cx.strokeStyle=f.side===0?'#bfe0ff':'#ffd0c0';cx.lineWidth=2;cx.beginPath();cx.arc(top[0],top[1],rad*0.8,0,7);cx.stroke();}
  if(f.status==='dead'){cx.strokeStyle='#000';cx.lineWidth=2;cx.beginPath();cx.moveTo(top[0]-4,top[1]-4);cx.lineTo(top[0]+4,top[1]+4);cx.moveTo(top[0]+4,top[1]-4);cx.lineTo(top[0]-4,top[1]+4);cx.stroke();}
  // hp pips
  if(f.status==='ok'){for(let i=0;i<f.maxhp;i++){cx.fillStyle=i<f.hp?'#9f6':'#333';cx.fillRect(top[0]-f.maxhp*2+i*4, top[1]-rad*1.4, 3,3);}}
}
function draw(fr){
  cx.clearRect(0,0,cv.width,cv.height); ground(); terrain();
  const figs=[...fr.figs].sort((a,b)=>(a.x+a.y)-(b.x+b.y));  // painter's order back-to-front
  figs.forEach(token);
  document.getElementById('lab').textContent=fr.label;
}
let i=0, playing=false, timer=null;
const sc=document.getElementById('sc'); sc.max=FRAMES.length-1;
function go(n){i=Math.max(0,Math.min(FRAMES.length-1,n));sc.value=i;draw(FRAMES[i]);}
sc.oninput=e=>{i=+e.target.value;draw(FRAMES[i]);};
document.getElementById('pp').onclick=function(){
  playing=!playing;this.textContent=playing?'❚❚ Pause':'▶ Play';
  if(playing){timer=setInterval(()=>{if(i>=FRAMES.length-1){go(0);}else go(i+1);},900);}else clearInterval(timer);
};
// drag to pan
let drag=false,px,py;cv.onmousedown=e=>{drag=true;px=e.clientX;py=e.clientY;};
onmouseup=()=>drag=false;onmousemove=e=>{if(drag){OX+=e.clientX-px;OY+=e.clientY-py;px=e.clientX;py=e.clientY;draw(FRAMES[i]);}};
cv.onwheel=e=>{e.preventDefault();S*=e.deltaY<0?1.08:0.93;ZS=S*0.87;draw(FRAMES[i]);};
go(0);
</script></body></html>"""

def build():
    geo,frames,res=battle()
    page=(HTML.replace("__GEO__",json.dumps(geo)).replace("__FRAMES__",json.dumps(frames))
              .replace("__RES__",json.dumps(res)))
    out=os.path.join(HERE,"..","BATTLE_3D.html")
    with open(out,"w",encoding="utf-8") as f: f.write(page)
    print("wrote",os.path.abspath(out),f"({len(page)} bytes) — {len(frames)} frames; result:",res)

if __name__=="__main__": build()
