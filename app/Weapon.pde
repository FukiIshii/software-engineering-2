class Weapon {

  String name;
  String attackType;   // 攻撃属性（打撃・貫通・爆発）

  float damage;
  int fireInterval;    // 発射間隔（ミリ秒）
  float bulletSpeed;

  float explosionRadius;  // 爆風が届く半径（爆発属性以外は0）
  float knockbackForce;   // 命中時のノックバックの強さ（打撃属性以外は0）

  Weapon(String name, String attackType, float damage, int fireInterval, float bulletSpeed) {
    this.name = name;
    this.attackType = attackType;

    this.damage = damage;
    this.fireInterval = fireInterval;
    this.bulletSpeed = bulletSpeed;

    explosionRadius = attackType.equals("爆発") ? 95 : 0;
    knockbackForce = attackType.equals("打撃") ? 10 : 0;
  }
}
