class Enemy extends Entity {

  String weakType;

  int exp;
  int attackPower;
  int scoreValue;
  float radius;

  Enemy(float x, float y) {
    super(x, y, 50, 2);

    weakType = "斬撃";

    exp = 10;
    attackPower = 10;
    scoreValue = 100;
    radius = 12.5;  // display()のellipse(25,25)に合わせた半径
  }

  void update() {
  move();
  avoidOverlap();
  attack();
  display();
}

  void move() {

    // プレイヤーの方向へ向かう
    float dx = player.x - x;
    float dy = player.y - y;

    float distance = dist(x, y, player.x, player.y);

    if (distance > 0) {
      x += dx / distance * speed;
      y += dy / distance * speed;
    }
  }

  void avoidOverlap() {

  for (Enemy other : enemies) {

    if (other == this) continue;

    float dx = x - other.x;
    float dy = y - other.y;

    float distance = dist(x, y, other.x, other.y);
    float minDist = radius + other.radius;

    if (distance > 0 && distance < minDist) {

      float overlap = minDist - distance;

      x += (dx / distance) * overlap * 0.5;
      y += (dy / distance) * overlap * 0.5;
    }
  }
}

  float attackCooldown = 0;

void attack() {

  float distance = dist(x, y, player.x, player.y);

  if (distance < radius + 15) {  // 15はplayerのellipse(30,30)相当の半径

    if (millis() - attackCooldown > 500) {  // 0.5秒に1回攻撃
      player.takeDamage(attackPower);
      attackCooldown = millis();
    }
  }
}

  void dropExpOrb() {

    // 後で実装

  }

  void display() {

    fill(255, 80, 80);
    ellipse(x, y, 25, 25);

  }

}