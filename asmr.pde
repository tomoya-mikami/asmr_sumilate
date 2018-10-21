import processing.opengl.*;

ProjectionVector pv;
Speaker sp[];

float th[];
color noSwitch;
color leftSwitch;
color rightSwitch;
color spstatus[];

void setup() {
  size(1280, 720, OPENGL);
  background(255, 255, 255);
  pv = new ProjectionVector(-100, 0, 0);

  sp = new Speaker[5];
  for(int i=0; i<sp.length - 1; i++) {
    sp[i] = new Speaker(60*i, 300);
  }
  sp[sp.length-1] = new Speaker(270, 50);
  
  th = new float[4];
  for(int i=0; i<th.length; i++)
  {
    th[i] = cos(radians(i*60));
  }
  
  noSwitch = color(155, 155, 155);
  rightSwitch = color(255, 100, 50);
  leftSwitch = color(50, 220, 255);
  
  spstatus = new color[5];
  for(int i=0; i<spstatus.length; i++) {
    spstatus[i] = noSwitch;
  }
}

void draw() {
  
  background(255, 255, 255);
  
  for(int i=0; i<spstatus.length; i++) {
    spstatus[i] = noSwitch;
  }

  pushMatrix();
  
  // ビューポイントの移動
  translate(width/2, height/2, 0);
  rotateX(radians(70));
  rotateZ(radians(20));
  
  // x, y, z軸の直線
  stroke(0, 0, 0);
  line(-width, 0, 0, width, 0, 0);
  line(0, -height*2, 0, 0, height, 0);
  line(0, 0, -1000, 0, 0, 1000);
  
  // 元のベクトル 赤
  stroke(255, 0, 0);
  line(0, 0, 0, pv.x, pv.y, pv.z);
  
  // 射影ベクトル 緑
  stroke(0, 255, 0);
  pv.projection();
  line(0, 0, 0, pv.p_x, 0, pv.p_z);
  
  // 左耳
  stroke(leftSwitch);
  pv.leftEarVector();
  line(0, 0, 0, pv.l_e_x, 0, pv.l_e_z);
  
  // 右耳
  stroke(rightSwitch);
  pv.rightEarVector();
  line(0, 0, 0, pv.r_e_x, 0, pv.r_e_z);
  
  // 左耳の判定
  checkOnSpeaker(spstatus, pv.l_e_x, pv.l_e_z, th, leftSwitch);
  checkOnSpeaker(spstatus, pv.r_e_x, pv.r_e_z, th, rightSwitch);
  
  for(int i=0; i<sp.length; i++) {
    stroke(spstatus[i]);
    sp[i].drawSpeaker();
  }
  
  popMatrix();
}

color setAlpha(color c, float per) {
  return color(red(c), green(c), blue(c), (int)(255*per));
}
void checkOnSpeaker(color spstatus[], float vec_x, float vec_z, float th[], color spSwitch) {
  float cos = vec_x / sqrt(pow(vec_x, 2) + pow(vec_z, 2));
  float theta = acos(cos);
  float comp_1 = 0;
  float comp_2 = 0;
  if(vec_z < 0) {
    theta = 2*PI - theta;
    if (vec_x == 0) {
      spstatus[4] = setAlpha(spSwitch, 1);
    }else if (vec_x > 0) {
      comp_1 = radians(270);
      comp_2 = radians(360);
      comp_1 = abs(theta - comp_1);
      comp_2 = abs(theta - comp_2);
      spstatus[0] = setAlpha(spSwitch, comp_1/(comp_1 + comp_2));
      spstatus[4] = setAlpha(spSwitch, comp_2/(comp_1 + comp_2));
    } else if (vec_x < 0) {
      comp_1 = radians(180);
      comp_2 = radians(270);
      comp_1 = abs(theta - comp_1);
      comp_2 = abs(theta - comp_2);
      spstatus[3] = setAlpha(spSwitch, comp_2/(comp_1 + comp_2));
      spstatus[4] = setAlpha(spSwitch, comp_1/(comp_1 + comp_2)); 
    }
  } else {
    int i = 0;
    for(i = 0; i< th.length; i++){
      if (th[i] == cos) {
        spstatus[i] = spSwitch;
        break;
      }else if(th[i] < cos) {
        spstatus[i] = spSwitch;
        spstatus[i-1] = spSwitch;
        break;
      }
    }
  }
}

class InputVector {

  public float x;
  public float y;
  public float z;
  
  InputVector(float _x, float _y, float _z) {
    this.x = _x;
    this.y = _y;
    this.z = _z;
  }
  
  public float vectorSize() {
    return sqrt(pow(this.x, 2) + pow(this.y, 2) + pow(this.z, 2));
  }
  
  public void moveHead(float _x, float _y, float _z) {
    this.x = _x;
    this.y = _y;
    this.z = _z;
  }

}

class ProjectionVector extends InputVector {

  public float p_x;
  public float p_z;
  
  public float l_e_x;
  public float l_e_z;
  
  public float r_e_x;
  public float r_e_z;
  
  ProjectionVector(float _x, float _y, float _z){
    super(_x, _y, _z);
    projection();
  }
  
  public void projection() {
    float parametor = sqrt(1-pow(y/this.vectorSize(), 2));
    this.p_x = this.x * parametor;
    this.p_z = this.z * parametor;
  }
  
  public void leftEarVector() {
    this.l_e_x = this.z * -1;
    this.l_e_z = this.x;
  }
  
  public void rightEarVector() {
    this.r_e_x = this.z;
    this.r_e_z = this.x * -1;
  }
}

class Speaker{
  float x;
  float z;
  float sr;
  
  Speaker(float angle, float _r){
    this.x = _r * cos(radians(angle));
    this.z = _r * sin(radians(angle));
    this.sr = 20;
  }
  
  public void drawSpeaker() {
    pushMatrix();
    translate(this.x, 0, this.z);
    sphere(this.sr);
    popMatrix();
  }
}

float a = 10;
void keyPressed() {
  if (key == '-') {
    a = -10;
  }
  if (key == 'j') {
    pv.x += a;// コード化されているキーが押された
  } else if (key == 'k') {
    pv.y += a;
  } else if (key == 'l') {
    pv.z += a;
  }
}

void keyReleased() {
  if (key == '-') {
    a = 10;
  }
}
