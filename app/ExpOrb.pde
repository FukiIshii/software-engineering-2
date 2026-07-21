class ExpOrb {

  float x, y;
  int exp;
  boolean alive;

  float radius = 5;
  float pickupRadius = 80;  // このrange内ならプレイヤーに引き寄せられる
  float moveSpeed = 6;

  ExpOrb(float x, float y, int exp) {
    this.x = x;
    this.y = y;
    this.exp = exp;
    this.alive = true;
  }

  void update() {
    move();
    display();
  }

  void move() {

    float distance = dist(x, y, player.x, player.y);

    if (distance > 0 && distance < pickupRadius) {
      float dx = player.x - x;
      float dy = player.y - y;

      x += dx / distance * moveSpeed;
      y += dy / distance * moveSpeed;
    }
  }

  void display() {
    fill(120, 255, 120);
    ellipse(x, y, radius * 2, radius * 2);
  }

  void collect(Player p) {
    p.gainExp(exp);
    alive = false;
  }

}
