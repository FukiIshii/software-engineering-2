class Bullet {

  float x;
  float y;

  float dx;
  float dy;

  float speed;
  float damage;

  String attackType;

  boolean alive;

  Bullet(float x, float y, float angle, float speed, float damage, String attackType) {

    this.x = x;
    this.y = y;

    this.speed = speed;
    this.damage = damage;

    this.attackType = attackType;

    dx = cos(angle);
    dy = sin(angle);

    alive = true;
  }

  void update() {
    move();
    display();
  }

  void move() {

    x += dx * speed;
    y += dy * speed;

    // 画面外なら消える
    if (x < 0 || x > width || y < 0 || y > height) {
      alive = false;
    }
  }

  void display() {

    fill(255, 255, 0);
    ellipse(x, y, 10, 10);

  }

}