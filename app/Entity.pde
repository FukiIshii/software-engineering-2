class Entity {

  float x;
  float y;
  float hp;
  float speed;
  boolean alive;

  Entity(float x, float y, float hp, float speed) {
    this.x = x;
    this.y = y;
    this.hp = hp;
    this.speed = speed;
    this.alive = true;
  }

  void update() {
  }

  void display() {
  }

  void takeDamage(float damage) {
    hp -= damage;

    if (hp <= 0) {
      alive = false;
    }
  }

  boolean isDead() {
    return !alive;
  }
}