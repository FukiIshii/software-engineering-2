class Player extends Entity {

  Weapon currentWeapon;
  ArrayList<Weapon> weapons;

  float maxHp;
  float moveSpeed;

  int score;

  int level;
  int exp;
  int nextLevelExp;

  int lastFireTime;

  boolean pendingLevelUp;  // trueの間、GameManager側がレベルアップ演出への遷移を行う

  float spriteSize = 36;          // 自機画像の表示サイズ（長辺がこの大きさになるよう縮小）
  float spriteRotationOffset = 0; // 画像の正面が右向きでない場合はHALF_PIなどに調整する

  Player(float x, float y) {

  super(x, y, 100, 5);

  maxHp = 100;
  moveSpeed = 5;

  score = 0;

  level = 1;
  exp = 0;
  nextLevelExp = 100;

  weapons = new ArrayList<Weapon>();

  weapons.add(new Weapon("連射モード", "貫通", 6, 150, 14));
  weapons.add(new Weapon("大砲モード", "打撃", 60, 700, 8));
  weapons.add(new Weapon("爆発弾モード", "爆発", 30, 900, 6));

  currentWeapon = weapons.get(0);
}

  void update() {
    move();

  attack();

  display();
  }

  void move() {

  if (up) y -= moveSpeed;
  if (down) y += moveSpeed;
  if (left) x -= moveSpeed;
  if (right) x += moveSpeed;

  x = constrain(x, 15, width - 15);
  y = constrain(y, 15, height - 15);


  // 画面外に出ないようにする
  x = constrain(x, 15, width - 15);
  y = constrain(y, 15, height - 15);

}

  void attack() {

  if (millis() - lastFireTime >= currentWeapon.fireInterval) {

    float angle = atan2(mouseY - y, mouseX - x);

    bullets.add(new Bullet(x, y, angle, currentWeapon.bulletSpeed, currentWeapon.damage, currentWeapon.attackType, currentWeapon.explosionRadius, currentWeapon.knockbackForce));

    lastFireTime = millis();

  }

}

  void switchWeapon(int index) {

  if (index >= 0 && index < weapons.size()) {
    currentWeapon = weapons.get(index);
  }

}

  // マウスホイールでの武器切り替え用（direction: +1で次、-1で前の武器）
  void cycleWeapon(int direction) {

  int index = weapons.indexOf(currentWeapon);
  int size = weapons.size();

  index = (index + direction + size) % size;

  currentWeapon = weapons.get(index);

}

  void heal(float amount) {
    hp += amount;

    if (hp > maxHp) {
      hp = maxHp;
    }
  }

  void gainExp(int amount) {

    exp += amount;

    while (exp >= nextLevelExp) {
      levelUp();
    }

  }

  void levelUp() {

    level++;

    exp -= nextLevelExp;

    nextLevelExp += 50;

    pendingLevelUp = true;

  }

  void applyUpgrade(Upgrade upgrade) {

    if (upgrade.target.equals("PLAYER")) {

      if (upgrade.type.equals("HP")) {
        maxHp += upgrade.value;
        heal(upgrade.value);
      } else if (upgrade.type.equals("SPEED")) {
        moveSpeed += upgrade.value;
      }

    } else if (upgrade.target.equals("WEAPON")) {

      for (Weapon w : weapons) {

        // weaponNameが指定されている強化は、その武器のみに適用する（未指定なら全武器共通）
        if (upgrade.weaponName != null && !upgrade.weaponName.equals(w.name)) continue;

        if (upgrade.type.equals("DAMAGE")) {
          w.damage *= (1 + upgrade.value);  // 武器ごとの現在値に対する割合で上昇
        } else if (upgrade.type.equals("FIRERATE")) {
          w.fireInterval = (int) max(50, w.fireInterval * (1 - upgrade.value));  // 現在の発射間隔に対する割合で短縮
        } else if (upgrade.type.equals("BULLETSPEED")) {
          w.bulletSpeed *= (1 + upgrade.value);  // 武器ごとの現在値に対する割合で上昇
        } else if (upgrade.type.equals("EXPLOSIONRADIUS")) {
          w.explosionRadius *= (1 + upgrade.value);  // 爆発弾モードの爆風範囲を拡大
        } else if (upgrade.type.equals("KNOCKBACK")) {
          w.knockbackForce *= (1 + upgrade.value);  // 大砲モードのノックバック距離を拡大
        }
      }
    }
  }

  void display() {

    PImage img = currentImage();

    if (img != null) {

      float angle = atan2(mouseY - y, mouseX - x);

      pushMatrix();
      translate(x, y);
      rotate(angle + spriteRotationOffset);

      float scale = spriteSize / max(img.width, img.height);
      image(img, 0, 0, img.width * scale, img.height * scale);

      popMatrix();

    } else {
      // 画像が読み込めない場合のフォールバック表示
      fill(0, 200, 255);
      ellipse(x, y, 30, 30);
    }

  }

  // 現在の武器モードに対応した自機画像を返す
  PImage currentImage() {
    if (currentWeapon.attackType.equals("打撃")) return playerImgCannon;
    if (currentWeapon.attackType.equals("爆発")) return playerImgBomb;
    return playerImgSpeed;  // 貫通（連射モード）をデフォルトとする
  }

}