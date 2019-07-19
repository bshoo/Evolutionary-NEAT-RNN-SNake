import java.util.*;

generation g;
List<innovation> GIL; //Global innovation list
int numOutputs = 4;
int numInputs = numOutputs + 49 + 4;
int startingLength = 10;
int population = 1000;
boolean warpSpeed = false;

void setup() {
  size(1280, 720);
  frameRate(30);
  GIL = new ArrayList<innovation>();
  g = new generation(population, true);
  //noLoop();
}

void draw() {
  background(51);
  if(warpSpeed){
    g.updateToCompletion();
  } else {
    g.updateAll();
  }
  if(g.everyoneDead()){
    g = g.nextGen();
  }
  stroke(255);
  line(height,0,height,height);
}

void keyPressed(){
  if(keyCode == UP){
    noLoop();
  }
  if(keyCode == DOWN){
    loop();
  }
  if(keyCode == LEFT){
    warpSpeed = false;
  }
  if(keyCode == RIGHT){
    warpSpeed = true;
  }
  redraw();
}
