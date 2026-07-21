class Bullet {

  float x;
  float y;

  float dx;
  float dy;

  float speed;
  float damage;

  String attackType;

  boolean alive;

  boolean pierce;  // 貫通属性なら敵を貫いて飛び続ける
  ArrayList<Enemy> hitEnemies;  // 貫通弾が同じ敵に多重ヒットしないようにする

  boolean explosive;       // 爆発属性なら着弾地点周囲に範囲ダメージを与える
  float explosionRadius;   // 爆風が届く半径（強化で変動するため武器から受け取る）

  float knockbackForce;    // 命中時のノックバックの強さ（強化で変動するため武器から受け取る）

  float bulletDiameter;    // 見た目・当たり判定に使う弾の直径

  Bullet(float x, float y, float angle, float speed, float damage, String attackType, float explosionRadius, float knockbackForce) {

    this.x = x;
    this.y = y;

    this.speed = speed;
    this.damage = damage;

    this.attackType = attackType;

    dx = cos(angle);
    dy = sin(angle);

    alive = true;

    pierce = attackType.equals("貫通");
    hitEnemies = new ArrayList<Enemy>();

    explosive = attackType.equals("爆発");
    this.explosionRadius = explosionRadius;
    this.knockbackForce = knockbackForce;

    // 大砲モード（打撃）は大砲の砲弾イメージで他より大きめの球にする
    bulletDiameter = attackType.equals("打撃") ? 18 : 10;
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
    ellipse(x, y, bulletDiameter, bulletDiameter);

  }

}