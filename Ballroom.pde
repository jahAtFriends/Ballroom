ArrayList<BouncyBall> balls = new ArrayList<BouncyBall>();
void setup() {
  size(400, 400);
  surface.setResizable(true);
  frameRate(400);
}

void draw() {
  background(255);
  for (int i = 0; i < balls.size(); i++) {
    
    balls.get(i).move();
    balls.get(i).drawBall();
    
    for (int j = i + 1; j < balls.size(); j++)
      balls.get(i).collideWith(balls.get(j));
  }
}

void mouseClicked(){
    float diameter = random(10, sqrt(height*width)/6);
    color aColor = color(random(0, 255), random(0, 255), random(0, 255));
    balls.add(new BouncyBall(mouseX, mouseY, random(-0.250,0.250), random(-0.25,0.250), aColor, diameter));
  
}