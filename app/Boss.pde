class Boss extends Enemy {

  int phase;
  float maxHp;

  int lastSpecialAttackTime;
  int specialAttackInterval;
  float specialAttackRadius;
  float specialAttackDamage;

  // 自機狙いの単発攻撃
  int lastAimedShotTime;
  int aimedShotInterval = 2500;
  float aimedShotSpeed = 6;
  float aimedShotDamage = 15;

  // 全方位に弾をばらまくリング攻撃
  int lastRingAttackTime;
  int ringAttackInterval = 4000;
  int ringBulletCount = 12;
  float ringBulletSpeed = 4;
  float ringBulletDamage = 10;

  // 自機狙いの3WAY拡散弾
  int lastSpreadShotTime;
  int spreadShotInterval = 3200;
  float spreadShotSpeed = 7;
  float spreadShotDamage = 12;
  float spreadAngleWidth = radians(20);

  // 弱点はフェーズ（HP）とは切り離し、時間経過でランダムに切り替える
  String[] weakTypeOptions = {"打撃", "貫通", "爆発"};
  int lastWeaknessChangeTime;
  int weaknessChangeInterval = 3500;  // フェーズが進むほど短くなる（updateWeakness()参照）

  Boss(float x, float y) {
    super(x, y, "boss");

    maxHp = hp;
    phase = 1;

    randomizeWeakness();
    lastWeaknessChangeTime = millis();

    lastSpecialAttackTime = millis();
    specialAttackInterval = 3000;
    specialAttackRadius = 130;
    specialAttackDamage = 25;

    lastAimedShotTime = millis();
    lastRingAttackTime = millis();
    lastSpreadShotTime = millis();
  }

  void update() {
    move();
    changePhase();
    updateWeakness();
    attack();
    specialAttack();
    aimedShot();
    ringAttack();
    spreadShot();
    display();
  }

  // HPが減るごとに凶暴化する（速度・攻撃力・各攻撃の間隔のみ。弱点はここでは変えない）
  void changePhase() {
    float ratio = hp / maxHp;

    if (ratio <= 0.3 && phase < 3) {
      phase = 3;
      speed *= 1.3;
      attackPower = (int)(attackPower * 1.3);
      specialAttackInterval = 1500;
      aimedShotInterval = 1500;
      ringAttackInterval = 2500;
      spreadShotInterval = 1800;
    } else if (ratio <= 0.6 && phase < 2) {
      phase = 2;
      speed *= 1.2;
      attackPower = (int)(attackPower * 1.2);
      specialAttackInterval = 2200;
      aimedShotInterval = 2000;
      ringAttackInterval = 3200;
      spreadShotInterval = 2500;
    }
  }

  // 一定間隔で弱点属性をランダムに変える。フェーズが進むほど変化が速くなり忙しくなる
  void updateWeakness() {

    int interval = weaknessChangeInterval;
    if (phase == 2) interval = 2500;
    else if (phase == 3) interval = 1500;

    if (millis() - lastWeaknessChangeTime > interval) {
      randomizeWeakness();
      lastWeaknessChangeTime = millis();
    }
  }

  // ボス固有の攻撃タイマーもまとめてリセットする（一時停止からの復帰直後の即攻撃を防ぐ）
  void resetTimers() {
    super.resetTimers();
    lastSpecialAttackTime = millis();
    lastAimedShotTime = millis();
    lastRingAttackTime = millis();
    lastSpreadShotTime = millis();
    lastWeaknessChangeTime = millis();
  }

  // 現在と異なる弱点を1つランダムに選ぶ（変化が必ず分かるように同じ属性は選ばない）
  void randomizeWeakness() {
    String next = weakType;

    while (next.equals(weakType)) {
      next = weakTypeOptions[int(random(weakTypeOptions.length))];
    }

    weakType = next;
  }

  // 一定間隔でプレイヤー周辺に大ダメージを与える近接範囲攻撃
  void specialAttack() {
    if (millis() - lastSpecialAttackTime > specialAttackInterval) {

      float distance = dist(x, y, player.x, player.y);

      if (distance < specialAttackRadius) {
        player.takeDamage(specialAttackDamage);
      }

      lastSpecialAttackTime = millis();
    }
  }

  // 自機の位置を狙って弾を1発撃つ
  void aimedShot() {
    if (millis() - lastAimedShotTime > aimedShotInterval) {

      float angle = atan2(player.y - y, player.x - x);
      enemyBullets.add(new EnemyBullet(x, y, angle, aimedShotSpeed, aimedShotDamage));

      lastAimedShotTime = millis();
    }
  }

  // 全方位に弾をばらまく攻撃
  void ringAttack() {
    if (millis() - lastRingAttackTime > ringAttackInterval) {

      for (int i = 0; i < ringBulletCount; i++) {
        float angle = i * TWO_PI / ringBulletCount;
        enemyBullets.add(new EnemyBullet(x, y, angle, ringBulletSpeed, ringBulletDamage));
      }

      lastRingAttackTime = millis();
    }
  }

  // 自機狙いに加えて左右に少しずらした3発を同時に撃つ拡散攻撃
  void spreadShot() {
    if (millis() - lastSpreadShotTime > spreadShotInterval) {

      float baseAngle = atan2(player.y - y, player.x - x);

      for (int i = -1; i <= 1; i++) {
        float angle = baseAngle + i * spreadAngleWidth;
        enemyBullets.add(new EnemyBullet(x, y, angle, spreadShotSpeed, spreadShotDamage));
      }

      lastSpreadShotTime = millis();
    }
  }

  void display() {

    color c = color(105, 106, 106);          // 打撃が弱点：灰色
    if (weakType.equals("貫通")) c = color(120, 180, 255); // 水色
    else if (weakType.equals("爆発")) c = color(223, 131, 23); // オレンジ

    fill(c);
    ellipse(x, y, radius * 2, radius * 2);

    // ボスのHPバー
    float ratio = constrain(hp / maxHp, 0, 1);

    fill(80);
    rect(x - radius, y - radius - 16, radius * 2, 6);

    fill(255, 0, 0);
    rect(x - radius, y - radius - 16, radius * 2 * ratio, 6);
  }

}
