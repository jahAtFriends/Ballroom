public class BouncyBall { //<>//
  private static final float GRAVITY = 0.0098;
  private static final float AIR_DRAG = 0.999999;
  private static final float BOUNCE_FRICTION = 0.95;
  private static final float MIN_BOUNCE_SPEED = 0.0000001;
  PVector velocity, position;
  float mass;
  private color ballColor;
  float diameter, radius;


  BouncyBall(float xPosition, float yPosition, float xSpeed, float ySpeed, color myColor, float mydiameter) {
    
    this.position = new PVector(xPosition, yPosition);
    this.velocity = new PVector(xSpeed, ySpeed);
    ballColor = myColor;
    diameter = mydiameter;
    mass = 0.5 * pow(diameter/2,2);
    radius = diameter/2;
  }
  
  BouncyBall(PVector position, PVector velocity, color ballColor, float diameter){
    this.position = position.copy();
    this.velocity = velocity.copy();
    this.ballColor = ballColor;
    this.diameter = diameter;
    this.radius = diameter/2;
  }
  
  BouncyBall(){
    this.position = PVector.random2D();
    this.velocity = PVector.random2D();
    this.ballColor = color(random(0,255),random(0,255), random(0,255));
    this.diameter = random(0,width/5);
    this.radius = diameter/2;
  }
  
  color getColor(){
    return this.ballColor; 
  }
  
  void changeColor(color x){
    this.ballColor = x; 
  }

  void drawBall() {
    fill(ballColor);
    ellipse(position.x, position.y, diameter, diameter);
  }

  void move() { 
    velocity.y += GRAVITY;
    velocity.x *= AIR_DRAG;
    velocity.y *= AIR_DRAG;
    
    position.add(velocity);

    if (position.x - radius < 0) {
      position.x = radius;
      if(abs(velocity.x) > MIN_BOUNCE_SPEED)
        bounce(0);
    }

    if (position.x + radius > width) {
      position.x = width - radius;
      if(velocity.x > MIN_BOUNCE_SPEED)
        bounce(0);
    }

    if (position.y < radius) {
      position.y = radius;
      bounce(1);
    }

    if (position.y + radius > height) {
      position.y = height - radius;
      if(velocity.y > MIN_BOUNCE_SPEED)
        bounce(1);
    }
    
  }

  void bounce(int dir) {
    if (dir == 0)
      velocity.x *= -1 * BOUNCE_FRICTION ;
    if (dir == 1)
      velocity.y *= -1 * BOUNCE_FRICTION;
  }
  
  boolean hasHit(BouncyBall other){
    PVector bVect = PVector.sub(other.position, position);

    // calculate magnitude of the vector separating the balls
    float bVectMag = bVect.mag();

    return(bVectMag < radius + other.radius);
  }
  
  void collideWith(BouncyBall other){
    // get distances between the balls components
    PVector bVect = PVector.sub(other.position, position);

    // calculate magnitude of the vector separating the balls
    float bVectMag = bVect.mag();

    if (bVectMag < radius + other.radius) {
      // get angle of bVect
      float theta  = bVect.heading();
      // precalculate trig values
      float sine = sin(theta);
      float cosine = cos(theta);

      /* bTemp will hold rotated ball positions. You 
       just need to worry about bTemp[1] position*/
      PVector[] bTemp = {
        new PVector(), new PVector()
        };

        /* this ball's position is relative to the other
         so you can use the vector between them (bVect) as the 
         reference point in the rotation expressions.
         bTemp[0].position.x and bTemp[0].position.y will initialize
         automatically to 0.0, which is what you want
         since b[1] will rotate around b[0] */
        bTemp[1].x  = cosine * bVect.x + sine * bVect.y;
      bTemp[1].y  = cosine * bVect.y - sine * bVect.x;

      // rotate Temporary velocities
      PVector[] vTemp = {
        new PVector(), new PVector()
        };

        vTemp[0].x  = cosine * velocity.x + sine * velocity.y;
      vTemp[0].y  = cosine * velocity.y - sine * velocity.x;
      vTemp[1].x  = cosine * other.velocity.x + sine * other.velocity.y;
      vTemp[1].y  = cosine * other.velocity.y - sine * other.velocity.x;

      /* Now that velocities are rotated, you can use 1D
       conservation of momentum equations to calculate 
       the final velocity along the x-axis. */
      PVector[] vFinal = {  
        new PVector(), new PVector()
        };

      // final rotated velocity for b[0]
      vFinal[0].x = ((mass - other.mass) * vTemp[0].x + 2 * other.mass * vTemp[1].x) / (mass + other.mass);
      vFinal[0].y = vTemp[0].y;

      // final rotated velocity for b[0]
      vFinal[1].x = ((other.mass - mass) * vTemp[1].x + 2 * mass * vTemp[0].x) / (mass + other.mass);
      vFinal[1].y = vTemp[1].y;

      // hack to avoid clumping
      bTemp[0].x += vFinal[0].x;
      bTemp[1].x += vFinal[1].x;

      /* Rotate ball positions and velocities back
       Reverse signs in trig expressions to rotate 
       in the opposite direction */
      // rotate balls
      PVector[] bFinal = { 
        new PVector(), new PVector()
        };

      bFinal[0].x = cosine * bTemp[0].x - sine * bTemp[0].y;
      bFinal[0].y = cosine * bTemp[0].y + sine * bTemp[0].x;
      bFinal[1].x = cosine * bTemp[1].x - sine * bTemp[1].y;
      bFinal[1].y = cosine * bTemp[1].y + sine * bTemp[1].x;

      // update balls to screen position
      other.position.x = position.x + bFinal[1].x;
      other.position.y = position.y + bFinal[1].y;

      position.add(bFinal[0]);

      // update velocities
      velocity.x = cosine * vFinal[0].x - sine * vFinal[0].y;
      velocity.y = cosine * vFinal[0].y + sine * vFinal[0].x;
      other.velocity.x = cosine * vFinal[1].x - sine * vFinal[1].y;
      other.velocity.y = cosine * vFinal[1].y + sine * vFinal[1].x;
      
    }
  }
}  