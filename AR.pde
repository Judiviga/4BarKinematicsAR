import processing.video.*;
import jp.nyatla.nyar4psg.*;
import controlP5.*;

ControlP5 cp5;
CheckBox checkbox;

PFont font;

Capture cam;
MultiMarker nya;

PMatrix3D m0 = new PMatrix3D();
PMatrix3D m1 = new PMatrix3D();
PMatrix3D m2 = new PMatrix3D();
PMatrix3D m3 = new PMatrix3D();
PMatrix3D m01 = new PMatrix3D();
PMatrix3D m02 = new PMatrix3D();
PMatrix3D m03 = new PMatrix3D();
PMatrix3D m6 = new PMatrix3D();

boolean cero_b=false;
boolean uno_b=false;
boolean dos_b=false;
boolean tres_b=false;
boolean start=false;

float x1, y1, x1_l, y1_l;
float x2, y2, x2_l, y2_l;
float x3, y3;

float theta01, theta32, theta12, theta01_sum, theta32_sum, theta12_sum, theta01_l, theta32_l, theta12_l;

float omegha01, omegha32, omegha12, omegha01_sum, omegha32_sum, omegha12_sum, omegha01_l, omegha32_l, omegha12_l;

float alpha01, alpha32, alpha12;

float d_01, d_12, d_23, d_03;

float sum01, sum12, sum23, sum03;

int t, n, c, l_01, l_12, l_32;

float time, time_l, dt;

float rpm;

float[] data = new float[640];
float[] data2 = new float[640];
float[] data3 = new float[640];
float[] data4 = new float[640];

int f;

boolean rev=false;

float value, value2, value3;
boolean show_01, show_12, show_32;
boolean v;
float RPM, RPM_sum, RPM_c;
void settings() {
  size(640, 480, P3D);
}

void setup() {

  colorMode(RGB, 100);
  font=createFont("Times New Roman Bold", 32);
  cam=new Capture(this, 640, 480, "Logitech HD Webcam C270");
  nya=new MultiMarker(this, 640, 480, "camera_para.dat", NyAR4PsgConfig.CONFIG_PSG);
  //nya.addARMarker("patt.hiro", 80);//id=0
  //nya.addARMarker("patt.kanji", 80);//id=1
  nya.addNyIdMarker(0, 16);//id=0
  nya.addNyIdMarker(5, 16);//id=1
  nya.addNyIdMarker(9, 16);//id=2
  nya.addNyIdMarker(8, 16);//id=3
  nya.setARPerspective();
  cam.start();

  String[] args = {"TwoFrameTest"};
  SecondApplet sa = new SecondApplet();
  PApplet.runSketch(args, sa);
}
void RPM() {
}

void drawgrid()
{
  pushMatrix();
  stroke(0);
  strokeWeight(2);
  line(0, 0, 0, -50, 0, 0);
  textFont(font, 12.0); 
  text("X", -50, 0, 0);
  line(0, 0, 0, 0, 50, 0);
  textFont(font, 12.0);  
  rotate(PI);
  text("Y", 0, -50, 0);
  rotate(-PI);
  line(0, 0, 0, 0, 0, 100);
  textFont(font, 10.0); 
  text("Z", 0, 0, 100);


  popMatrix();
}
void draw()
{

  cam.read();
  nya.detect(cam);
  background(0);
  nya.drawBackground(cam);//frustum???????????????????????????
  delay(10);
  for (int i=0; i<=3; i++) 
  {
    if ((nya.isExist(i)))
    {
      nya.beginTransform(i);
      if (i==0) {

        m0 = nya.getMarkerMatrix(0); 
        m01 = nya.getMarkerMatrix(0);
        m02 = nya.getMarkerMatrix(0);
        m03 = nya.getMarkerMatrix(0);
        fill(250, 0, 0);
        cero_b=true;//leyo marcador 0
        drawgrid();
      } 

      if (i==1) {
        m1 = nya.getMarkerMatrix(1);   
        stroke(0, 250, 0);
        fill(0, 250, 0);        
        uno_b=true;//leyo marcador 1
        sphere(3);
      }
      if (i==2) {
        m2 = nya.getMarkerMatrix(2); 
        stroke(148, 0, 211);
        fill(148, 0, 211);
        dos_b=true;
        sphere(3);
      } 

      if (i==3) {
        m3 = nya.getMarkerMatrix(3); 
        fill(255, 0, 0);
        stroke(255, 0, 0);
        tres_b=true;
        sphere(3);
      } 


      nya.endTransform();
    } else //no detecta el marcador i 
    {
      if (i==0)
      {
        cero_b=false;
      }
      if (i==1)
        uno_b=false;
      if (i==2)
        dos_b=false;
    }
  }
  if (cero_b ==true) {
    //si detecta en la iteracion los marcadore 1 y 2
    //si tiene una lectura valida de 0 y 3  

    resetMatrix();
    stroke(250, 0, 0);
    line(m0.m03, m0.m13, m0.m23, m1.m03, m1.m13, m1.m23);
    line(m1.m03, m1.m13, m1.m23, m2.m03, m2.m13, m2.m23);
    line(m2.m03, m2.m13, m2.m23, m3.m03, m3.m13, m3.m23);
    line(m0.m03, m0.m13, m0.m23, m3.m03, m3.m13, m3.m23);

    //calcular la matriz transformada de 1 2 y 3 respecto a 0
    m01.invert();
    m02.invert();
    m03.invert();

    m01.apply(m1); 
    m02.apply(m2); 
    m03.apply(m3);
    //////////////////////////

    x1_l=x1; //x1 anterior
    y1_l=y1;
    x1=-m01.m03; 
    y1=-m01.m13;

    x2_l=x2;   
    y2_l=y2;
    x2=-m02.m03;
    y2=-m02.m13; 


    x3=-m03.m03;
    y3=-m03.m13;


    if (start==false)//initialize
    {
      //longitudes de las barras
      d_01=sqrt(sq(x1)+sq(y1));
      d_12=sqrt(sq(x2-x1)+sq(y2-y1));
      d_23=sqrt(sq(x3-x2)+sq(y3-y2));
      d_03=sqrt(sq(x3)+sq(y3));

      //promedio de las distancias
      sum01=sum01+d_01;
      sum12=sum12+d_12;
      sum23=sum23+d_23;
      sum03=sum03+d_03;
      c++;

      RPM();
      //println(d_01, " , ", d_12, " , ", d_23, " , ", d_03);
    } else //despues de la inicializacion
    {
      d_01=sum01/c;
      d_12=sum12/c;
      d_23=sum23/c;
      d_03=sum03/c;
      //    println(x2_l);
    } 
    //angulo de 1 resceto a la horizontal
    theta01_l=theta01;
    theta01=degrees(atan2(x1, y1));
    if (theta01>90)theta01=theta01-90;
    else if (theta01<90)theta01=theta01+270; 
    //angulo de 2 respecto a 3
    theta32_l=theta32;
    theta32=degrees(atan2(x2-x3, y2-y3));
    if (theta32>90)theta32=theta32-90;
    else if (theta32<90)theta32=theta32+270; 
    //angulo de 2 respecto a 1
    theta12_l=theta12;
    theta12=degrees(atan2(x2-x1, y2-y1));
    if (theta12>90)theta12=theta12-90;
    else if (theta12<90)theta12=theta12+270; 

    if (abs(theta32-theta32_l)>200)rev=true;
    else rev=false;


    if (f<5) {
      theta01_sum=theta01_sum+theta01-theta01_l;
      theta32_sum=theta32_sum+theta32-theta32_l;
      theta12_sum=theta12_sum+theta12-theta12_l;
      // println( theta12_sum, ",",  theta32_sum, ",", theta01_sum);
      v=false;
      f++;
    } else {
      v=true;
      f=0;
      time_l=time;
      time=millis();
      dt=time-time_l;
      //velocidades angulares
      omegha01_l=omegha01;
      omegha12_l=omegha12;
      omegha32_l=omegha32;

      omegha01=1000*(theta01_sum)/dt;
      omegha12=1000*(theta12_sum)/dt;
      omegha32=1000*(theta32_sum)/dt;
      if (omegha32>0)omegha32=-50;
      if (omegha32<-150)omegha32=-100;
      theta01_sum=0;
      theta12_sum=0;
      theta32_sum=0;
      if (omegha32!=0) {
        RPM_sum+=abs(omegha32)*60/360;
        RPM_c++;
        RPM=(RPM_sum/RPM_c);
      } else {
        RPM=0;
        RPM_sum=0;
        RPM_c=0;
      }

      //aceleraciones angulares
      alpha01=1000*(omegha01-omegha01_l)/dt;
      alpha32=1000*(omegha32-omegha32_l)/dt;
      alpha12=1000*(omegha12-omegha12_l)/dt;
      if (alpha01>200)alpha01=200;
      if (alpha01<-200)alpha01=-200;
      if (alpha32>200)alpha32=200;
      if (alpha32<-200)alpha32=-200;
      if (alpha12>200)alpha12=200;
      if (alpha12<-200)alpha12=-200;
    }
  }
}
String matrixToString(PMatrix3D m) { //Convierte a string los valores de la matriz
  return "[" + nf(m.m00, 1, 3) + " , " + nf(m.m01, 1, 3) + " , " + nf(m.m02, 1, 3) + " , " + nf(m.m03, 1, 0) + " ,\n" +
    " "+ nf(m.m10, 1, 3) + " , " + nf(m.m11, 1, 3) + " , " + nf(m.m12, 1, 3) + " , " + nf(m.m13, 1, 0) + " ,\n" +
    " "+ nf(m.m20, 1, 3) + " , " + nf(m.m21, 1, 3) + " , " + nf(m.m22, 1, 3) + " , " + nf(m.m23, 1, 0) + " ,\n" +
    " "+ nf(m.m30, 1, 3) + " , " + nf(m.m31, 1, 3) + " , " + nf(m.m32, 1, 3) + " , " + nf(m.m33, 1, 0) + " ]";
}

public class SecondApplet extends PApplet {

  String buttonName;

  public void settings() {
    size(640, 600);
  }
  public void setup() {
    background(255);
    t=32;
    interf();
    reset();
  }
  public void draw() {
    fill(50);
    stroke(50);
    rect(0, 480, 640, 440);//rectangulo de abajo para botones

    if (buttonName=="Start")
    {
      if (c>=100)//inicializacion
        start=true;
    }

    if (start==true)
    {
      if (buttonName=="Trayect")
      {
        stroke(0, 255, 0);        
        strokeWeight(2);
        xy(x1, y1, x1_l, y1_l);
        stroke(148, 0, 211);
        strokeWeight(2);
        xy(x2, y2, x2_l, y2_l);
      }
      if (buttonName=="Angulo")
      {
        tethaTime();
      }

      if (buttonName=="Velocidad")
        omeghaTime();

      if (buttonName=="Accel")
        alphaTime();

      if (buttonName=="Reset") {
        start=false;
        reset();
      }
    }
  }
  public void controlEvent(ControlEvent theEvent) {

    if (theEvent.isFrom(checkbox)) {
      if (checkbox.getArrayValue()[0]==1) show_32=true;
      else show_32=false;
      if (checkbox.getArrayValue()[1]==1) show_12=true;
      else show_12=false;
      if (checkbox.getArrayValue()[2]==1) show_01=true;
      else show_01=false;
    } else {
      background(255);
      fill(50);
      rect(0, 480, 640, 440);

      t=32;
      n=0;
      //   println(theEvent.getController().getName());
      buttonName=theEvent.getController().getName();
    }
  }

  public void xy(float a, float b, float a_l, float b_l) {

    line(a_l+640/2, b_l+480/2, a+640/2, b+480/2);

    stroke(0);
    strokeWeight(3);
    line(1000, 480/2, -1000, 480/2);
    line(640/2, 480, 640/2, -1000);
    stroke(255);
    fill(255);
    rect(440, 420, 200, 50);
    stroke(0);
    fill(0);
    textSize(25);
    text("RPM="+round(RPM), 480, 450);
  }

  public void tethaTime() {

    stroke(255);
    fill(255);
    rect(440, 420, 200, 50);
    stroke(0);
    fill(0);
    textSize(25);
    text("RPM="+round(RPM), 480, 450);

    strokeWeight(3);
    line(1000, 160+480/2, -1000, 160+480/2);
    line(30, 480, 30, -1000);
    strokeWeight(1);
    stroke(220);
    textSize(15); 
    text("45", 5, map(45, 0, 360, 160, -200)+480/2);
    line(1000, map(45, 0, 360, 160, -200)+480/2, -1000, map(45, 0, 360, 160, -200)+480/2);
    text("90", 5, map(90, 0, 360, 160, -200)+480/2);
    line(1000, map(90, 0, 360, 160, -200)+480/2, -1000, map(90, 0, 360, 160, -200)+480/2);
    text("135", 5, map(135, 0, 360, 160, -200)+480/2);
    line(1000, map(135, 0, 360, 160, -200)+480/2, -1000, map(135, 0, 360, 160, -200)+480/2);
    text("180", 5, map(180, 0, 360, 160, -200)+480/2);
    line(1000, map(180, 0, 360, 160, -200)+480/2, -1000, map(180, 0, 360, 160, -200)+480/2);
    text("225", 5, map(225, 0, 360, 160, -200)+480/2);
    line(1000, map(225, 0, 360, 160, -200)+480/2, -1000, map(225, 0, 360, 160, -200)+480/2);
    text("270", 5, map(270, 0, 360, 160, -200)+480/2);
    line(1000, map(270, 0, 360, 160, -200)+480/2, -1000, map(270, 0, 360, 160, -200)+480/2);
    text("315", 5, map(315, 0, 360, 160, -200)+480/2);
    line(1000, map(315, 0, 360, 160, -200)+480/2, -1000, map(315, 0, 360, 160, -200)+480/2);
    text("360", 5, map(360, 0, 360, 160, -200)+480/2);
    line(1000, map(360, 0, 360, 160, -200)+480/2, -1000, map(360, 0, 360, 160, -200)+480/2);
    strokeWeight(2);

    if (uno_b && cero_b ==true) {
      value=map(theta01, 0, 360, 160, -200);//angulo a posicion de la pantalla
      data[t-n]=value+480/2;
      for (int i=l_01; i>0; i--)
        data[t-n-i]=((data[t-n]-data[t-n-l_01])/l_01)*(l_01-i)+data[t-n-l_01];
      l_01=0;
    } else l_01++;

    if (uno_b && cero_b && dos_b ==true) {
      value2=map(theta12, 0, 360, 160, -200);
      data2[t-n]=value2+480/2;
      for (int i=l_12; i>0; i--)
        data2[t-n-i]=((data2[t-n]-data2[t-n-l_12])/l_12)*(l_12-i)+data2[t-n-l_12];
      l_12=0;
    } else l_12++;

    if (cero_b && dos_b ==true) {
      value3=map(theta32, 0, 360, 160, -200);
      data3[t-n]=value3+480/2;
      for (int i=l_32; i>0; i--)
        data3[t-n-i]=((data3[t-n]-data3[t-n-l_32])/l_32)*(l_32-i)+data3[t-n-l_32];
      l_32=0;
    } else l_32++;

    // println(data[t-n]);
    if (t>=600)
    {
      background(255);

      stroke(255);
      fill(255);
      rect(440, 420, 200, 50);
      stroke(0);
      fill(0);
      textSize(25);
      text("RPM="+round(RPM), 480, 450);

      fill(50);
      stroke(50);
      rect(0, 480, 640, 440);
      stroke(0);
      strokeWeight(3);
      line(1000, 160+480/2, -1000, 160+480/2);
      line(30, 480, 30, -1000);
      strokeWeight(1);
      stroke(220);
      textSize(15); 
      text("45", 5, map(45, 0, 360, 160, -200)+480/2);
      line(1000, map(45, 0, 360, 160, -200)+480/2, -1000, map(45, 0, 360, 160, -200)+480/2);
      text("90", 5, map(90, 0, 360, 160, -200)+480/2);
      line(1000, map(90, 0, 360, 160, -200)+480/2, -1000, map(90, 0, 360, 160, -200)+480/2);
      text("135", 5, map(135, 0, 360, 160, -200)+480/2);
      line(1000, map(135, 0, 360, 160, -200)+480/2, -1000, map(135, 0, 360, 160, -200)+480/2);
      text("180", 5, map(180, 0, 360, 160, -200)+480/2);
      line(1000, map(180, 0, 360, 160, -200)+480/2, -1000, map(180, 0, 360, 160, -200)+480/2);
      text("225", 5, map(225, 0, 360, 160, -200)+480/2);
      line(1000, map(225, 0, 360, 160, -200)+480/2, -1000, map(225, 0, 360, 160, -200)+480/2);
      text("270", 5, map(270, 0, 360, 160, -200)+480/2);
      line(1000, map(270, 0, 360, 160, -200)+480/2, -1000, map(270, 0, 360, 160, -200)+480/2);
      text("315", 5, map(315, 0, 360, 160, -200)+480/2);
      line(1000, map(315, 0, 360, 160, -200)+480/2, -1000, map(315, 0, 360, 160, -200)+480/2);
      text("360", 5, map(360, 0, 360, 160, -200)+480/2);
      line(1000, map(360, 0, 360, 160, -200)+480/2, -1000, map(360, 0, 360, 160, -200)+480/2);

      if (rev==true) {
        data4[t-n]=450;
      } else data4[t-n]=-1000;

      for (int i=33; i<600; i++) {
        data4[i]=data4[i+1];
        line(i, -1000, i, data4[i]);
      }
      strokeWeight(2);
      for (int i=30; i<600-l_01; i++)
      {
        if (show_01==true) {
          data[i]=data[i+1];
          stroke(210, 210, 0);
          line(i-1, data[i-1], i, data[i]);
        }
      }

      for (int i=30; i<600-l_12; i++)
      {
        if (show_12==true) {
          data2[i]=data2[i+1];
          stroke(0, 0, 255);
          line(i-1, data2[i-1], i, data2[i]);
        }
      }

      for (int i=30; i<600-l_32; i++)
      {
        if (show_32==true) {
          data3[i]=data3[i+1];
          stroke(250, 0, 0);
          line(i-1, data3[i-1], i, data3[i]);
        }
      }
    } else
    {
      if ( uno_b && cero_b && show_01 ==true) {
        stroke(210, 210, 0);
        line(t-n-1, data[t-n-1], t-n, data[t-n-2]);
      }


      if (uno_b && cero_b && dos_b && show_12==true) {
        stroke(0, 0, 255);
        line(t-n-1, data2[t-n-1], t-n, data2[t-n]);
      }
      if (cero_b && dos_b && show_32 ==true) {    
        stroke(250, 0, 0);
        line(t-n-1, data3[t-n-1], t-n, data3[t-n]);
      }
    }
    t++;
    if (t>600) 
      n++;
  }



  public void omeghaTime() {

    stroke(255);
    stroke(255);
    fill(255);
    rect(440, 420, 200, 50);
    stroke(0);
    fill(0);
    textSize(25);
    text("RPM="+round(RPM), 480, 450);
    fill(50);
    stroke(50);
    rect(0, 480, 640, 440);
    stroke(0);
    strokeWeight(3);
    textSize(15); 
    text("0", 5, map(0, -200, 200, 160, -200)+480/2);
    line(1000, map(0, -200, 200, 160, -200)+480/2, -1000, map(0, -200, 200, 160, -200)+480/2);
    line(30, 480, 30, -1000);
    strokeWeight(1);

    stroke(220);

    text("-200", 5, map(-200, -200, 200, 160, -200)+480/2);
    line(1000, map(-200, -200, 200, 160, -200)+480/2, -1000, map(-200, -200, 200, 160, -200)+480/2);
    text("-150", 5, map(-150, -200, 200, 160, -200)+480/2);
    line(1000, map(-150, -200, 200, 160, -200)+480/2, -1000, map(-150, -200, 200, 160, -200)+480/2);
    text("-100", 5, map(-100, -200, 200, 160, -200)+480/2);
    line(1000, map(-100, -200, 200, 160, -200)+480/2, -1000, map(-100, -200, 200, 160, -200)+480/2);
    text("-50", 5, map(-50, -200, 200, 160, -200)+480/2);
    line(1000, map(-50, -200, 200, 160, -200)+480/2, -1000, map(-50, -200, 200, 160, -200)+480/2);
    text("50", 5, map(50, -200, 200, 160, -200)+480/2);
    line(1000, map(50, -200, 200, 160, -200)+480/2, -1000, map(50, -200, 200, 160, -200)+480/2);
    text("100", 5, map(100, -200, 200, 160, -200)+480/2);
    line(1000, map(100, -200, 200, 160, -200)+480/2, -1000, map(100, -200, 200, 160, -200)+480/2);
    text("150", 5, map(150, -200, 200, 160, -200)+480/2);
    line(1000, map(150, -200, 200, 160, -200)+480/2, -1000, map(150, -200, 200, 160, -200)+480/2);
    text("200", 5, map(200, -200, 200, 160, -200)+480/2);
    line(1000, map(200, -200, 200, 160, -200)+480/2, -1000, map(200, -200, 200, 160, -200)+480/2);
    strokeWeight(2);

    float value=map(omegha01, -200, 200, 160, -200);//angulo a posicion de la pantalla
    float value2=map(omegha12, -200, 200, 160, -200);
    float value3=map(omegha32, -200, 200, 160, -200);

    data[t-n]=value+480/2;
    data2[t-n]=value2+480/2;
    data3[t-n]=value3+480/2;

    if (t>=600)
    {
      background(255);
      stroke(255);
      fill(255);
      rect(440, 420, 200, 50);
      stroke(0);
      fill(0);
      textSize(25);
      text("RPM="+round(RPM), 480, 450);
      fill(50);
      stroke(50);
      rect(0, 480, 640, 440);
      stroke(0);
      strokeWeight(3);
      textSize(15); 
      text("0", 5, map(0, -200, 200, 160, -200)+480/2);
      line(1000, map(0, -200, 200, 160, -200)+480/2, -1000, map(0, -200, 200, 160, -200)+480/2);
      line(30, 480, 30, -1000);
      strokeWeight(1);

      stroke(220);

      text("-200", 5, map(-200, -200, 200, 160, -200)+480/2);
      line(1000, map(-200, -200, 200, 160, -200)+480/2, -1000, map(-200, -200, 200, 160, -200)+480/2);
      text("-150", 5, map(-150, -200, 200, 160, -200)+480/2);
      line(1000, map(-150, -200, 200, 160, -200)+480/2, -1000, map(-150, -200, 200, 160, -200)+480/2);
      text("-100", 5, map(-100, -200, 200, 160, -200)+480/2);
      line(1000, map(-100, -200, 200, 160, -200)+480/2, -1000, map(-100, -200, 200, 160, -200)+480/2);
      text("-50", 5, map(-50, -200, 200, 160, -200)+480/2);
      line(1000, map(-50, -200, 200, 160, -200)+480/2, -1000, map(-50, -200, 200, 160, -200)+480/2);
      text("50", 5, map(50, -200, 200, 160, -200)+480/2);
      line(1000, map(50, -200, 200, 160, -200)+480/2, -1000, map(50, -200, 200, 160, -200)+480/2);
      text("100", 5, map(100, -200, 200, 160, -200)+480/2);
      line(1000, map(100, -200, 200, 160, -200)+480/2, -1000, map(100, -200, 200, 160, -200)+480/2);
      text("150", 5, map(150, -200, 200, 160, -200)+480/2);
      line(1000, map(150, -200, 200, 160, -200)+480/2, -1000, map(150, -200, 200, 160, -200)+480/2);
      text("200", 5, map(200, -200, 200, 160, -200)+480/2);
      line(1000, map(200, -200, 200, 160, -200)+480/2, -1000, map(200, -200, 200, 160, -200)+480/2);

      if (rev==true) {
        data4[t-n]=450;
      } else data4[t-n]=-1000;

      for (int i=33; i<600; i++) {
        data4[i]=data4[i+1];
        line(i, -1000, i, data4[i]);
      }
      strokeWeight(2);




      if (uno_b && cero_b && v ==true) {
        for (int i=l_01; i>0; i--)
          data[t-n-i]=((data[t-n]-data[t-n-l_01])/l_01)*(l_01-i)+data[t-n-l_01];
        l_01=0;
      } else l_01++;

      for (int i=33; i<600-l_01; i++)
      {
        if (show_01==true) {
          data[i]=data[i+1];
          stroke(210, 210, 0);
          line(i-1, data[i-1], i, data[i]);
        }
      }

      if (uno_b && cero_b && dos_b && v ==true) {
        for (int i=l_12; i>0; i--)
          data2[t-n-i]=((data2[t-n]-data2[t-n-l_12])/l_12)*(l_12-i)+data2[t-n-l_12];
        l_12=0;
      } else l_12++;

      for (int i=33; i<600-l_12; i++)
      {
        if (show_12==true) {
          data2[i]=data2[i+1];
          stroke(0, 0, 255);
          line(i-1, data2[i-1], i, data2[i]);
        }
      }

      if (cero_b && dos_b && v==true) {  
        for (int i=l_32; i>0; i--)
          data3[t-n-i]=((data3[t-n]-data3[t-n-l_32])/l_32)*(l_32-i)+data3[t-n-l_32];
        l_32=0;
      } else l_32++;

      for (int i=33; i<600-l_32; i++)
      {
        if (show_32==true) {
          data3[i]=data3[i+1];
          stroke(250, 0, 0);
          line(i-1, data3[i-1], i, data3[i]);
        }
      }
    } else
    {
      if (uno_b && cero_b && show_01 ==true) {
        stroke(210, 210, 0);
        line(t-n-1, data[t-n-1], t-n, value+480/2);
      }
      if (uno_b && cero_b && dos_b && show_12==true) {
        stroke(0, 0, 255);
        line(t-n-1, data2[t-n-1], t-n, value2+480/2);
      }
      if (cero_b && dos_b && show_32 ==true) {    
        stroke(250, 0, 0);
        line(t-n-1, data3[t-n-1], t-n, value3+480/2);
      }
    }
    t++;
    if (t>600) 
      n++;
  }


  public void alphaTime() {
     stroke(255);
      fill(255);
      rect(440, 420, 200, 50);
      stroke(0);
      fill(0);
      textSize(25);
      text("RPM="+round(RPM), 480, 450);
      fill(50);
      stroke(50);
      rect(0, 480, 640, 440);
      stroke(0);
      strokeWeight(3);
      textSize(15); 
      text("0", 5, map(0, -200, 200, 160, -200)+480/2);
      line(1000, map(0, -200, 200, 160, -200)+480/2, -1000, map(0, -200, 200, 160, -200)+480/2);
      line(30, 480, 30, -1000);
      strokeWeight(1);

      stroke(220);

      text("-200", 5, map(-200, -200, 200, 160, -200)+480/2);
      line(1000, map(-200, -200, 200, 160, -200)+480/2, -1000, map(-200, -200, 200, 160, -200)+480/2);
      text("-150", 5, map(-150, -200, 200, 160, -200)+480/2);
      line(1000, map(-150, -200, 200, 160, -200)+480/2, -1000, map(-150, -200, 200, 160, -200)+480/2);
      text("-100", 5, map(-100, -200, 200, 160, -200)+480/2);
      line(1000, map(-100, -200, 200, 160, -200)+480/2, -1000, map(-100, -200, 200, 160, -200)+480/2);
      text("-50", 5, map(-50, -200, 200, 160, -200)+480/2);
      line(1000, map(-50, -200, 200, 160, -200)+480/2, -1000, map(-50, -200, 200, 160, -200)+480/2);
      text("50", 5, map(50, -200, 200, 160, -200)+480/2);
      line(1000, map(50, -200, 200, 160, -200)+480/2, -1000, map(50, -200, 200, 160, -200)+480/2);
      text("100", 5, map(100, -200, 200, 160, -200)+480/2);
      line(1000, map(100, -200, 200, 160, -200)+480/2, -1000, map(100, -200, 200, 160, -200)+480/2);
      text("150", 5, map(150, -200, 200, 160, -200)+480/2);
      line(1000, map(150, -200, 200, 160, -200)+480/2, -1000, map(150, -200, 200, 160, -200)+480/2);
      text("200", 5, map(200, -200, 200, 160, -200)+480/2);
      line(1000, map(200, -200, 200, 160, -200)+480/2, -1000, map(200, -200, 200, 160, -200)+480/2);
      strokeWeight(2);

    float value=map(alpha01, -200, 200, 160, -200);//angulo a posicion de la pantalla
    float value2=map(alpha12, -200, 200, 160, -200);
    float value3=map(alpha32, -200, 200, 160, -200);

    data[t-n]=value+480/2;
    data2[t-n]=value2+480/2;
    data3[t-n]=value3+480/2;

    if (t>=600)
    {
      background(255);
      stroke(255);
      fill(255);
      rect(440, 420, 200, 50);
      stroke(0);
      fill(0);
      textSize(25);
      text("RPM="+round(RPM), 480, 450);
      fill(50);
      stroke(50);
      rect(0, 480, 640, 440);
      stroke(0);
      strokeWeight(3);
      textSize(15); 
      text("0", 5, map(0, -200, 200, 160, -200)+480/2);
      line(1000, map(0, -200, 200, 160, -200)+480/2, -1000, map(0, -200, 200, 160, -200)+480/2);
      line(30, 480, 30, -1000);
      strokeWeight(1);

      stroke(220);

      text("-200", 5, map(-200, -200, 200, 160, -200)+480/2);
      line(1000, map(-200, -200, 200, 160, -200)+480/2, -1000, map(-200, -200, 200, 160, -200)+480/2);
      text("-150", 5, map(-150, -200, 200, 160, -200)+480/2);
      line(1000, map(-150, -200, 200, 160, -200)+480/2, -1000, map(-150, -200, 200, 160, -200)+480/2);
      text("-100", 5, map(-100, -200, 200, 160, -200)+480/2);
      line(1000, map(-100, -200, 200, 160, -200)+480/2, -1000, map(-100, -200, 200, 160, -200)+480/2);
      text("-50", 5, map(-50, -200, 200, 160, -200)+480/2);
      line(1000, map(-50, -200, 200, 160, -200)+480/2, -1000, map(-50, -200, 200, 160, -200)+480/2);
      text("50", 5, map(50, -200, 200, 160, -200)+480/2);
      line(1000, map(50, -200, 200, 160, -200)+480/2, -1000, map(50, -200, 200, 160, -200)+480/2);
      text("100", 5, map(100, -200, 200, 160, -200)+480/2);
      line(1000, map(100, -200, 200, 160, -200)+480/2, -1000, map(100, -200, 200, 160, -200)+480/2);
      text("150", 5, map(150, -200, 200, 160, -200)+480/2);
      line(1000, map(150, -200, 200, 160, -200)+480/2, -1000, map(150, -200, 200, 160, -200)+480/2);
      text("200", 5, map(200, -200, 200, 160, -200)+480/2);
      line(1000, map(200, -200, 200, 160, -200)+480/2, -1000, map(200, -200, 200, 160, -200)+480/2);

      if (rev==true) {
        data4[t-n]=450;
      } else data4[t-n]=-1000;

      for (int i=33; i<600; i++) {
        data4[i]=data4[i+1];
        line(i, -1000, i, data4[i]);
      }
      strokeWeight(2);


      if (uno_b && cero_b && v ==true) {
        for (int i=l_01; i>0; i--)
          data[t-n-i]=((data[t-n]-data[t-n-l_01])/l_01)*(l_01-i)+data[t-n-l_01];
        l_01=0;
      } else l_01++;

      for (int i=33; i<600-l_01; i++)
      {
        if (show_01==true) {
          data[i]=data[i+1];
          stroke(210, 210, 0);
          line(i-1, data[i-1], i, data[i]);
        }
      }

      if (uno_b && cero_b && dos_b && v ==true) {
        for (int i=l_12; i>0; i--)
          data2[t-n-i]=((data2[t-n]-data2[t-n-l_12])/l_12)*(l_12-i)+data2[t-n-l_12];
        l_12=0;
      } else l_12++;

      for (int i=33; i<600-l_12; i++)
      {
        if (show_12==true) {
          data2[i]=data2[i+1];
          stroke(0, 0, 255);
          line(i-1, data2[i-1], i, data2[i]);
        }
      }

      if (cero_b && dos_b && v==true) {  
        for (int i=l_32; i>0; i--)
          data3[t-n-i]=((data3[t-n]-data3[t-n-l_32])/l_32)*(l_32-i)+data3[t-n-l_32];
        l_32=0;
      } else l_32++;

      for (int i=33; i<600-l_32; i++)
      {
        if (show_32==true) {
          data3[i]=data3[i+1];
          stroke(250, 0, 0);
          line(i-1, data3[i-1], i, data3[i]);
        }
      }
    } else
    {
      if (uno_b && cero_b && show_01 ==true) {
        stroke(210, 210, 0);
        line(t-n-1, data[t-n-1], t-n, value+480/2);
      }
      if (uno_b && cero_b && dos_b && show_12==true) {
        stroke(0, 0, 255);
        line(t-n-1, data2[t-n-1], t-n, value2+480/2);
      }
      if (cero_b && dos_b && show_32 ==true) {    
        stroke(250, 0, 0);
        line(t-n-1, data3[t-n-1], t-n, value3+480/2);
      }
    }
    t++;
    if (t>600) 
      n++;
  }

  public void reset() {
    //  println(theta01, ",", theta12, ",", theta32);
    background(255);
    fill(50);
    rect(0, 480, 640, 440);

    t=1;
    n=0;


    String s = "INSTRUCCIONES";    
    textSize(12);

    text(s, 300, 220);

    s = "1. Situe la camara frente al mecanismo bien iluminado";
    text(s, 80, 260);

    s = "2. Revise que la camara lea adecuadamente todos los marcadores";
    text(s, 80, 282);

    s = "(deben verse las lineas rojas sobre las barras)";
    text(s, 80, 304);

    s = "3. Presione START y seleccione un tipo de grafico para mostrar";
    text(s, 80, 326);

    s = "TRAYECT grafica la posicion X Y de los dos puntos moviles";
    text(s, 100, 348);

    s = "ANGULO grafica los angulos 1 2 y 3 respecto al tiempo";
    text(s, 100, 370);

    s = "VELOCIDAD grafica la velocidad angular 1 2 y 3 respecto al tiempo";
    text(s, 100, 392);

    s = "ACCEL grafica la aceleracion angular 1 2 y 3 respecto al tiempo";
    text(s, 100, 414);

    s = "4. Utilize los checkbox 1 2 y 3 para mostrar o ocultar los angulos respectivos";
    text(s, 80, 436);

    s = "5. Presione STOP para detener el grafico y regresar a esta pantalla";
    text(s, 80, 458);


    float x0=100;
    float y0=200;
    float e=1.2;

    strokeWeight(4);
    stroke(210, 210, 0);
    float x1=e*141*cos(75*PI/180)+x0;
    float y1=e*-141*sin(75*PI/180)+y0;
    line(x0, y0, x1, y1);

    stroke(0);
    strokeWeight(2);
    line(x0, y0, x0+100, y0);
    textFont(font, 20.0); 
    text("X", x0+100, y0+20);
    line(x0, y0, x0, y0-100);
    textFont(font, 20.0);  
    text("Y", x0-20, y0-100);

    strokeWeight(4);
    stroke(0, 0, 255);
    float x2=e*167*cos(5*PI/180)+x1;
    float y2=e*167*sin(5*PI/180)+y1;
    line(x1, y1, x2, y2);


    strokeWeight(4);
    stroke(255, 0, 0);
    float x3=e*-90*cos(65*PI/180)+x2;
    float y3=e*90*sin(65*PI/180)+y2;
    line(x2, y2, x3, y3);

    noFill();
    stroke(0);
    strokeWeight(1);
    arc(x0, y0, 150, 150, 2*PI-75*PI/180, 2*PI);

    noFill();
    stroke(0);
    strokeWeight(1);
    arc(x1, y1, 70, 70, 0, 2*PI-5*PI/180);
    line(x1, y1, x1+200, y1);

    arc(x3, y3, 150, 150, 2*PI-65*PI/180, 2*PI);
    line(x3, y3, x3+100, y3);

    noStroke();
    fill(0, 255, 0);
    ellipse(x1, y1, 30, 30);
    fill(148, 0, 211);
    ellipse(x2, y2, 30, 30);

    fill(0);
    text(3, x0+30, y0-20);
    text(2, x1-30, y1);
    text(1, x3+30, y3-20);
  }

  public void interf() {

    cp5 = new ControlP5(this);  

    cp5.addButton("Trayect")
      .setValue(0)
      .setPosition(85, 560)
      .setSize(100, 19);  

    cp5.addButton("Angulo")
      .setValue(0)
      .setPosition(200, 560)
      .setSize(100, 19);  

    cp5.addButton("Velocidad")
      .setValue(100)
      .setPosition(315, 560)
      .setSize(100, 19);    

    cp5.addButton("Accel")
      .setPosition(430, 560)
      .setSize(100, 19)
      .setValue(0);

    //  PImage[] imgs = {loadImage("button_a.png"), loadImage("button_b.png"), loadImage("button_c.png")};

    cp5.addButton("Start")
      .setValue(128)
      .setPosition(335, 490)
      .setSize(100, 40)
      .setValue(0);
    //.setImages(imgs)
    //.updateSize();

    //   PImage[] imgs2 = {loadImage("button_a_2.png"), loadImage("button_b_2.png"), loadImage("button_c_2.png")};

    cp5.addButton("Reset")
      .setValue(128)
      .setPosition(450, 490)
      .setSize(100, 40)
      .setValue(0);
    //   .setImages(imgs2)
    //   .updateSize();

    checkbox = cp5.addCheckBox("checkBox")
      .setPosition(85, 500)
      .setColorForeground(color(120))
      .setColorActive(color(255))
      .setColorLabel(color(255))
      .setSize(25, 25)
      .setItemsPerRow(3)     
      .setSpacingColumn(30)
      .addItem("1", 1)
      .addItem("2", 2)
      .addItem("3", 3)                
      ;
  }
}
