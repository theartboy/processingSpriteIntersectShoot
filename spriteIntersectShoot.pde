Sprite s;
Enemy e;
PImage [] spriteImages;
PImage [] enemyImages;
int spriteFrames;
int enemyFrames;

boolean left, right, up, down, space;

int lives, score;

Bullet b;

void setup() {
  size(600, 400);
  background(255);
  smooth();

  //number of images to load for sprite animation
  spriteFrames = 23;
  enemyFrames = 6;

  loadAssets();

  s = new Sprite(spriteFrames);
  e = new Enemy(enemyFrames);
  b = new Bullet();

  left = false;
  right = false;
  up = false;
  down = false;
  space = false;

  lives = 5;
  score = 0;
}

void loadAssets() {
  spriteImages = new PImage[spriteFrames];
  for (int i = 0; i<spriteFrames; i++) {
    spriteImages[i]=loadImage("Face"+nf(i+1, 4)+".png");
  }
  enemyImages = new PImage[enemyFrames];
  for (int i = 0; i<enemyFrames; i++) {
    enemyImages[i] = loadImage("unicorn"+nf(i+1, 4)+".png");
  }
}

void draw() {
  background(255);
  s.update();
  e.update(s.x, s.y);
  if (rectangleIntersect(s, e)) {
    fill(255, 255, 0);
    rect(0, 0, width, height);
    removeLife();
  }
  if (rectangleIntersect(b, e)) {
    addScore();
  }
  if (space) {
    float spriteRotation;
    if (!s.flipped) {
      spriteRotation = 0;
    } else {
      spriteRotation = PI;
    }
    b.setStartLocation(s.x, s.y, spriteRotation);
  }
  b.update();
  b.display();
  s.display();
  e.display();
  fill(0);
  text("Lives "+lives +"\nScore: "+ score, 50, 50);
}
void removeLife() {
  lives--;
  s.die();
  e.die();
}
void addScore() {
  score++;
  e.die();
  b.reset();
}

boolean rectangleIntersect(Sprite r1, Enemy r2) {
  //what is the distance apart on x-axis
  float distanceX = (r1.x) - (r2.x);
  //what is the distance apart on y-axis
  float distanceY = (r1.y) - (r2.y);


  //what is the combined half-widths
  float combinedHalfW = r1.w/2 + r2.w/2;
  //what is the combined half-heights
  float combinedHalfH = r1.h/2 + r2.h/2;

  //check for intersection on x-axis
  if (abs(distanceX) < combinedHalfW) {
    //check for intersection on y-axis
    if (abs(distanceY) < combinedHalfH) {
      //huzzah they are intersecting
      return true;
    }
  }
  return false;
}

boolean rectangleIntersect(Bullet r1, Enemy r2) {
  //what is the distance apart on x-axis
  float distanceX = (r1.x) - (r2.x);
  //what is the distance apart on y-axis
  float distanceY = (r1.y) - (r2.y);


  //what is the combined half-widths
  float combinedHalfW = r1.w/2 + r2.w/2;
  //what is the combined half-heights
  float combinedHalfH = r1.h/2 + r2.h/2;

  //check for intersection on x-axis
  if (abs(distanceX) < combinedHalfW) {
    //check for intersection on y-axis
    if (abs(distanceY) < combinedHalfH) {
      //huzzah they are intersecting
      return true;
    }
  }
  return false;
}

void keyPressed() {
  switch (keyCode) {
  case 37://left
    left = true;
    break;
  case 39://right
    right = true;
    break;
  case 38://up
    up = true;
    break;
  case 40://down
    down = true;
    break;
  case 32://space
    space = true;
    break;
  }
}
void keyReleased() {
  switch (keyCode) {
  case 37://left
    left = false;
    break;
  case 39://right
    right = false;
    break;
  case 38://up
    up = false;
    break;
  case 40://down
    down = false;
    break;
  case 32://space
    space = false;
    break;
  }
}
class Bullet {
  float x, y, w, h;
  float speed, rotation, maxSpeed, minSpeed;
  boolean firing;

  Bullet() {
    x = 100;
    y = -100;
    w = 20;
    h = 10;

    speed = 0;
    rotation = 0;
    maxSpeed = 15;
    minSpeed = 5;
    firing = false;
  }
  void setStartLocation(float startX, float startY, float startRotation) {
    if (firing == false) {
      x = startX;
      y = startY;
      rotation = startRotation;
      firing = true;
      speed = 20;
    }
  }
  void update() {
    if (firing == true) {
      //if (speed < maxSpeed) {
      //  speed += 2;
      //}
      if (speed > minSpeed) {
        speed -= 0.3;
      }
      //speed = maxSpeed;
      x += cos(rotation) * speed;
      y += sin(rotation) * speed;

      //check for moving out of bounds
      if (x>width||x<0||y>height||y<0) {
        reset();
      }
    }
  }
  void reset() {
    speed = 0;
    firing = false;
    y = -100;
  }
  void display() {
    pushMatrix();
    translate(x, y);
    rotate(rotation);
    fill(0, 255, 0);
    rect(-w/2, -h/2, w, h);
    popMatrix();
  }
}

class Enemy {
  float x, y, w, h;
  int currentFrame, frames;

  float speedX, speedY;
  boolean walking;
  boolean flipped;


  Enemy(int eFrames) {
    x = random(100, width-100);
    y = random(100, height-100);
    currentFrame = 0;
    frames = eFrames;
    w = 140;
    h = 95;

    speedX = 0;
    speedY = 0;
    walking = false;
    flipped = false;
  }
  void die() {
    x = 500;
    y = random(100, height-100);
  }
  void update(float sx, float sy) {
    //when the player is less than 200px away start chasing
    if (dist(x, y, sx, sy) < 200) {
      walking = true;
      if (abs(x - sx) < abs(y - sy)) {
        //bigger gap on y axis
        if (y < sy) {
          //enemy is above player
          speedX = 0;
          speedY = 2;
        } else {
          //enemy is below player
          speedX = 0;
          speedY = -2;
        }
      } else {
        //bigger gap on x axis
        if (x < sx) {
          //enemy is left of player
          speedX = 2;
          speedY = 0;
          flipped = false;
        } else {
          //enemy is right of player
          speedX = -2;
          speedY = 0;
          flipped = true;
        }
      }
    } else {
      //not chasing the player
      walking = false;
      speedX = 0;
      speedY = 0;
    }
    x+=speedX;
    y+=speedY;
  }
  void display() {
    // tint(255,0,0);
    pushMatrix();
    translate(x, y);
    if (flipped) {
      scale(-1.0, 1.0);
    } else {
      scale(1.0, 1.0);
    }
    image(enemyImages[currentFrame], -w/2, -h/2);
    popMatrix();
    // currentFrame = (currentFrame+1)%frames;
    if (walking == true) {
      currentFrame++;
    } else {
      currentFrame = 0;
    }
    if (currentFrame == frames) {
      currentFrame = 0;
    }
  }
}

class Sprite {
  float x, y, w, h;
  int currentFrame, frames;

  float speedX, speedY;
  boolean walking;
  boolean flipped;

  Sprite(int sframes) {
    frames = sframes;
    x = 100;
    y = 100;
    currentFrame = 0;
    w = 32;
    h = 32;

    speedX = 0;
    speedY = 0;
    walking = false;
    flipped = false;
  }
  void die() {
    x = 100;
    y = random(100, height-100);
  }
  void update() {
    if (left) {
      walking=true;
      speedX =-5;
      flipped = true;
    }
    if (right) {
      walking=true;
      speedX =5;
      flipped = false;
    }
    if (!left&&!right) {
      speedX=0;
    } else if (left&&right) {
      speedX=0;
    }

    if (up) {
      walking=true;
      speedY =-5;
    }
    if (down) {
      walking=true;
      speedY =5;
    }
    if (!up&&!down) {
      speedY=0;
    } else if (up&&down) {
      speedY=0;
    }
    if (!up&&!down&&!left&&!right) {
      walking = false;
    }
    x+=speedX;
    y+=speedY;
  }
  void display() {
    tint(255);
    image(spriteImages[currentFrame], x-w/2, y-h/2);
    // currentFrame = (currentFrame+1)%frames;
    if (walking==true) {
      currentFrame++;
      // println(currentFrame);
    } else {
      currentFrame = 0;
    }
    if (currentFrame == frames) {
      currentFrame = 0;
    }
  }
}
