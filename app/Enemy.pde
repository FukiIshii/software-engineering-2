class Enemy extends Entity {

  String type;

  String weakType;
  String weakType2;  // 複数弱点を持つ敵用

  int exp;
  int attackPower;
  int scoreValue;
  float radius;

  float attackCooldown = 0;

  // ノックバック（時間とともに減衰しながら滑るように動く）
  float knockbackX = 0;
  float knockbackY = 0;
  float knockbackFriction = 0.85;

  // 弾を撃つタイプの敵用（0なら弾は撃たない）
  int rangedAttackInterval = 0;
  int bulletCount = 8;
  float enemyBulletSpeed = 4;
  float enemyBulletDamage = 8;
  int lastRangedAttackTime = 0;

  Enemy(float x, float y, String type) {
    super(x, y, 50, 2);

    this.type = type;
    weakType2 = null;

    if (type.equals("heavy")) {   // 重装兵：打撃に弱い
      weakType = "打撃";
      hp = 90;
      speed = 1.2;
      attackPower = 15;
      scoreValue = 150;
      radius = 16;
      exp = 20;
    } else if (type.equals("flying")) {  // 飛行型：貫通に弱い
      weakType = "貫通";
      hp = 20;
      speed = 3.5;
      attackPower = 6;
      scoreValue = 120;
      radius = 10;
      exp = 15;
    } else if (type.equals("obstacle")) { // 障害物型：爆発に弱い・動かない・円状に弾を発射
      weakType = "爆発";
      hp = 75;
      speed = 0;
      attackPower = 5;
      scoreValue = 200;
      radius = 20;
      exp = 25;
      rangedAttackInterval = 2000;
    } else if (type.equals("boss")) {
      weakType = "";
      hp = 1600;
      speed = 1.0;
      attackPower = 20;
      scoreValue = 1000;
      radius = 35;
      exp = 200;
    } else {
      weakType = "";
      hp = 50;
      speed = 2;
      attackPower = 10;
      scoreValue = 100;
      radius = 12.5;
      exp = 10;
    }

    lastRangedAttackTime = millis();  // スポーン直後にいきなり発射しないようにする
  }

  void update() {
    move();
    avoidOverlap();
    attack();
    rangedAttack();
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

    // ノックバックを適用しつつ減衰させる（ぬるっと滑って止まる）
    x += knockbackX;
    y += knockbackY;

    knockbackX *= knockbackFriction;
    knockbackY *= knockbackFriction;

    // 画面外に出ないようにする（ノックバックで押し出されても止まる）
    x = constrain(x, radius, width - radius);
    y = constrain(y, radius, height - radius);
  }

  // 弾に押されて後ろへ滑る力を加える
  void applyKnockback(float dx, float dy, float force) {
    knockbackX += dx * force;
    knockbackY += dy * force;
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

  void attack() {

    float distance = dist(x, y, player.x, player.y);

    if (distance < radius + 15) {  // 15はplayerのellipse(30,30)相当の半径

      if (millis() - attackCooldown > 500) {  // 0.5秒に1回攻撃
        player.takeDamage(attackPower);
        attackCooldown = millis();
      }
    }
  }

  // 円状に弾をばらまく攻撃（rangedAttackIntervalが0のタイプは何もしない）
  void rangedAttack() {

    if (rangedAttackInterval <= 0) return;

    if (millis() - lastRangedAttackTime > rangedAttackInterval) {

      for (int i = 0; i < bulletCount; i++) {
        float angle = i * TWO_PI / bulletCount;
        enemyBullets.add(new EnemyBullet(x, y, angle, enemyBulletSpeed, enemyBulletDamage));
      }

      lastRangedAttackTime = millis();
    }
  }

  // 強化選択などでゲームが一時停止していた間の経過時間を無効化し、再開直後に攻撃されないようにする
  void resetTimers() {
    attackCooldown = millis();
    lastRangedAttackTime = millis();
  }

  // 弾の攻撃属性がこの敵の弱点に該当するか
  boolean isWeakAgainst(String attackType) {
    if (weakType != null && weakType.equals(attackType)) return true;
    if (weakType2 != null && weakType2.equals(attackType)) return true;
    return false;
  }

  void dropExpOrb() {
    expOrbs.add(new ExpOrb(x, y, exp));
  }

  void display() {

    color c = color(255, 80, 80);

    if (type.equals("heavy")) c = color(105, 106, 106);       // #696a6a
    else if (type.equals("flying")) c = color(120, 180, 255);
    else if (type.equals("obstacle")) c = color(223, 131, 23); // #df8317
    else if (type.equals("boss")) c = color(200, 0, 200);

    fill(c);
    ellipse(x, y, radius * 2, radius * 2);
  }

}
