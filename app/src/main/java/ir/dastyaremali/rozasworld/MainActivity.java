package ir.dastyaremali.rozasworld;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.SharedPreferences;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.Typeface;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Toast;

public class MainActivity extends Activity {
    @Override public void onCreate(Bundle state) { super.onCreate(state); setContentView(new WorldView()); }

    private final class WorldView extends View {
        private final Paint p = new Paint(Paint.ANTI_ALIAS_FLAG);
        private final SharedPreferences prefs = getSharedPreferences("save", MODE_PRIVATE);
        private int coins = prefs.getInt("coins", 30), xp = prefs.getInt("xp", 0), stars = prefs.getInt("stars", 0);
        private int outfit = prefs.getInt("outfit", 0), pet = prefs.getInt("pet", 0), place = 0, game = 0;
        private final String[] places = {"خانه‌ی رنگین‌کمان", "جنگل جادویی", "دهکده‌ی دوست‌ها", "ساحل ستاره‌ای", "قلعه‌ی ابرها", "کوه برفی"};
        private final int[] skies = {0xFFFFD8E8,0xFFD7F6D9,0xFFFFE9B5,0xFFBFEFFF,0xFFE4D7FF,0xFFE0F5FF};
        private final int[] grounds = {0xFFFFA4C5,0xFF78D596,0xFFFFCF70,0xFF70D4E5,0xFFB49BEF,0xFFA6D9F0};
        private final int[] dresses = {0xFFFF4D9D,0xFF8E73EF,0xFFFFA04A,0xFF37BFB0,0xFF68A8F7};
        private float startX, startY;
        WorldView() { super(MainActivity.this); setLayerType(View.LAYER_TYPE_SOFTWARE, null); }
        private void fill(int c) { p.setColor(c); p.setStyle(Paint.Style.FILL); p.setStrokeWidth(2); }
        private void box(Canvas c,float l,float t,float r,float b,int col,float radius) { fill(col); c.drawRoundRect(new RectF(l,t,r,b),radius,radius,p); }
        private void dot(Canvas c,float x,float y,float r,int col) { fill(col); c.drawCircle(x,y,r,p); }
        private void label(Canvas c,String s,float x,float y,float size,int col,boolean bold) { fill(col); p.setTextSize(size); p.setTextAlign(Paint.Align.CENTER); p.setTypeface(Typeface.create("sans-serif-rounded",bold?Typeface.BOLD:Typeface.NORMAL)); c.drawText(s,x,y,p); }
        private void persist() { prefs.edit().putInt("coins",coins).putInt("xp",xp).putInt("stars",stars).putInt("outfit",outfit).putInt("pet",pet).apply(); }
        @Override protected void onDraw(Canvas c) {
            super.onDraw(c); float w=getWidth(),h=getHeight(); c.drawColor(skies[place]);
            for(int i=0;i<4;i++){float x=w*(i+1)/5f;dot(c,x,h*.12f,18,0xCCFFFFFF);dot(c,x+17,h*.115f,24,0xCCFFFFFF);dot(c,x+37,h*.12f,17,0xCCFFFFFF);}
            label(c,"ROZA'S WORLD",w/2,h*.065f,w*.065f,0xFF704A91,true); label(c,"دنیای جادویی رزا",w/2,h*.105f,w*.042f,0xFF704A91,true);
            box(c,w*.06f,h*.14f,w*.94f,h*.215f,0xDFFFFFFF,24);
            label(c,"🪙 "+coins,w*.22f,h*.187f,w*.045f,0xFF9B6000,true); label(c,"⭐ "+stars,w*.50f,h*.187f,w*.045f,0xFFB27A00,true); label(c,"سطح "+(1+xp/40),w*.78f,h*.187f,w*.043f,0xFF6F50A0,true);
            box(c,w*.08f,h*.225f,w*.92f,h*.235f,0x44FFFFFF,10); box(c,w*.08f,h*.225f,w*(.08f+.84f*(xp%40)/40f),h*.235f,0xFF9A78E8,10);
            box(c,w*.05f,h*.27f,w*.95f,h*.705f,0xBFFFFFFF,35); dot(c,w*.5f,h*.49f,w*.29f,0xFFE9F8D8); dot(c,w*.5f,h*.49f,w*.235f,grounds[place]);
            for(int i=0;i<4;i++){float x=w*(.14f+i*.24f),y=h*(.47f+(i%2)*.11f);box(c,x-4,y+12,x+4,y+40,0xFF9B6946,4);dot(c,x,y,21,i%2==0?0xFF41B86B:0xFF65D181);dot(c,x-9,y+3,11,0xFF91E4A1);}
            float x=w*.5f,y=h*.465f;
            // little cottage
            box(c,x-52,y,x+52,y+65,0xFFFFF5E7,9); Path roof=new Path();roof.moveTo(x-65,y+3);roof.lineTo(x,y-44);roof.lineTo(x+65,y+3);roof.close();fill(0xFFE984A2);c.drawPath(roof,p);
            box(c,x-11,y+30,x+11,y+65,0xFF9A709A,4);box(c,x-40,y+17,x-21,y+36,0xFF9EDDF3,4);box(c,x+21,y+17,x+40,y+36,0xFF9EDDF3,4);
            // Roza avatar
            dot(c,x,y-62,21,0xFFFFD7B6);dot(c,x-16,y-76,12,0xFF633C31);dot(c,x+16,y-76,12,0xFF633C31);dot(c,x,y-78,22,0xFF633C31);dot(c,x,y-61,17,0xFFFFD7B6);
            dot(c,x-6,y-63,2.4f,0xFF3F2D37);dot(c,x+6,y-63,2.4f,0xFF3F2D37);fill(0xFFE87C91);p.setStyle(Paint.Style.STROKE);p.setStrokeWidth(2.5f);c.drawArc(x-6,y-58,x+6,y-48,5,170,false,p);p.setStyle(Paint.Style.FILL);
            box(c,x-19,y-40,x+19,y+4,dresses[outfit],12);box(c,x-13,y+1,x-4,y+19,0xFFFFD7B6,4);box(c,x+4,y+1,x+13,y+19,0xFFFFD7B6,4);
            if(pet>0){int pc=pet%2==0?0xFFFFC85C:0xFFB29AF8;dot(c,x+63,y+12,17,pc);dot(c,x+57,y+8,2.5f,0xFF40334F);dot(c,x+68,y+8,2.5f,0xFF40334F);dot(c,x+63,y+17,3,0xFF655064);}
            label(c,places[place],w/2,h*.66f,w*.05f,0xFF593B7A,true); label(c,"برای رفتن به جای بعدی، صفحه را لمس کن",w/2,h*.692f,w*.031f,0xFF746483,false);
            float top=h*.735f,g=w*.025f,bw=(w*.88f-2*g)/3f,left=w*.06f,bottom=top+h*.075f;
            button(c,left,top,left+bw,bottom,0xFF9074EA,"🎯 بازی‌ها");button(c,left+bw+g,top,left+2*bw+g,bottom,0xFFFFA04B,"👗 لباس");button(c,left+2*(bw+g),top,w*.94f,bottom,0xFF3CBBA7,"🐾 حیوان");
            button(c,w*.06f,h*.83f,w*.94f,h*.90f,0xFF699CEB,"📋 مأموریت روزانه");label(c,"ذخیره‌ی خودکار • بدون اینترنت",w/2,h*.95f,w*.031f,0xFF776C89,false);
        }
        private void button(Canvas c,float l,float t,float r,float b,int col,String s){box(c,l,t,r,b,col,22);label(c,s,(l+r)/2,(t+b)/2+getWidth()*.014f,getWidth()*.04f,0xFFFFFFFF,true);}
        @Override public boolean onTouchEvent(android.view.MotionEvent e){float x=e.getX(),y=e.getY(),w=getWidth(),h=getHeight();if(e.getAction()==MotionEvent.ACTION_DOWN){startX=x;startY=y;return true;}if(e.getAction()==MotionEvent.ACTION_UP){
            if(y>h*.27f&&y<h*.715f){if(Math.abs(x-startX)>w*.08f)place=(place+(x<startX?1:5))%6;else if(y>h*.60f)place=(place+1)%6;else place=(place+1)%6;invalidate();return true;}
            if(y>=h*.735f&&y<h*.82f){if(x<w*.36f)games();else if(x<w*.65f){outfit=(outfit+1)%dresses.length;coins=Math.max(0,coins-2);xp+=2;persist();Toast.makeText(MainActivity.this,"لباس جدید برای رزا! 👗",Toast.LENGTH_SHORT).show();}else{pet++;coins=Math.max(0,coins-5);xp+=3;persist();Toast.makeText(MainActivity.this,"یک دوست بامزه پیدا شد! 🐾",Toast.LENGTH_SHORT).show();}invalidate();return true;}
            if(y>=h*.83f&&y<h*.92f){mission();return true;}return true;}return true;}
        private void games(){new AlertDialog.Builder(MainActivity.this).setTitle("بازی‌های کوچک 🎮").setItems(new String[]{"شکار ستاره‌ها ⭐","حافظه‌ی جادویی 🧠","پازل رنگی 🧩"},(d,which)->{if(which==0){int reward=5+(int)(Math.random()*6);stars+=reward;coins+=reward;xp+=10;Toast.makeText(MainActivity.this,"آفرین! "+reward+" ستاره پیدا کردی! ⭐",Toast.LENGTH_LONG).show();}else if(which==1){stars+=3;coins+=4;xp+=7;Toast.makeText(MainActivity.this,"حافظه‌ات عالیه! ۳ ستاره گرفتی",Toast.LENGTH_LONG).show();}else{stars+=2;coins+=3;xp+=5;Toast.makeText(MainActivity.this,"پازل کامل شد!",Toast.LENGTH_SHORT).show();}persist();invalidate();}).setNegativeButton("برگشت",null).show();}
        private void mission(){final String[] missions={"۱۰ دقیقه کتاب خواندن 📚","مرتب کردن اتاق 🧸","مسواک زدن 🪥","کمک در کار خانه 💖"};new AlertDialog.Builder(MainActivity.this).setTitle("مأموریت امروز 🌟").setItems(missions,(d,which)->new AlertDialog.Builder(MainActivity.this).setTitle("آفرین به تلاش تو!").setMessage("این کار را با هماهنگی مامان یا بابا انجام بده. بعد از تأیید آن‌ها، جایزه را دریافت کن.").setPositiveButton("مامان/بابا تأیید کردند",(dd,ww)->{coins+=10;xp+=8;stars++;persist();invalidate();Toast.makeText(MainActivity.this,"۱۰ سکه و یک ستاره گرفتی! 🎉",Toast.LENGTH_LONG).show();}).setNegativeButton("بعداً",null).show()).setNegativeButton("بستن",null).show();}
    }
}
