class EnemyBullet {

  float x, y;
  float dx, dy;

  float speed;
  float damage;
  float radius = 5;

  boolean alive;

  EnemyBullet(float x, float y, float angle, float speed, float damage) {
    this.x = x;
    this.y = y;

    this.speed = speed;
    this.damage = damage;

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
    fill(255, 0, 80);
    ellipse(x, y, radius * 2, radius * 2);
  }

}
