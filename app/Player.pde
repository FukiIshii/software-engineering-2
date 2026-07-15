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

  Player(float x, float y) {

  super(x, y, 100, 5);

  maxHp = 100;
  moveSpeed = 5;

  score = 0;

  level = 1;
  exp = 0;
  nextLevelExp = 100;

  weapons = new ArrayList<Weapon>();

  weapons.add(new Weapon("ソード", "斬撃", 15, 200, 10));
  weapons.add(new Weapon("ハンマー", "打撃", 40, 700, 8));
  weapons.add(new Weapon("ライフル", "貫通", 10, 150, 14));
  weapons.add(new Weapon("グレネード", "爆発", 30, 900, 6));

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

    bullets.add(new Bullet(x, y, angle, currentWeapon.bulletSpeed, currentWeapon.damage, currentWeapon.attackType));

    lastFireTime = millis();

  }

}

  void switchWeapon(int index) {

  if (index >= 0 && index < weapons.size()) {
    currentWeapon = weapons.get(index);
  }

}

  void heal(float amount) {
    hp += amount;

    if (hp > maxHp) {
      hp = maxHp;
    }
  }

  void gainExp(int amount) {

    exp += amount;

    if (exp >= nextLevelExp) {
      levelUp();
    }

  }

  void levelUp() {

    level++;

    exp -= nextLevelExp;

    nextLevelExp += 50;

  }

  void applyUpgrade(Upgrade upgrade) {

  }

  void display() {

    fill(0, 200, 255);
    ellipse(x, y, 30, 30);

  }

}