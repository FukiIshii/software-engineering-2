class Weapon {

  String name;
  String attackType;   // 攻撃属性（斬撃・打撃・貫通・爆発）

  float damage;
  int fireInterval;    // 発射間隔（ミリ秒）
  float bulletSpeed;

  Weapon(String name, String attackType, float damage, int fireInterval, float bulletSpeed) {
    this.name = name;
    this.attackType = attackType;

    this.damage = damage;
    this.fireInterval = fireInterval;
    this.bulletSpeed = bulletSpeed;
  }
}
