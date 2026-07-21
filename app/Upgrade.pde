class Upgrade {

  String name;
  String description;

  String target;    // PLAYER または WEAPON
  String type;      // DAMAGE, FIRERATE, BULLETSPEED, EXPLOSIONRADIUS, KNOCKBACK, HP, SPEED など

  float value;

  String weaponName;  // 特定の武器のみに適用する場合はその武器名、全武器共通ならnull

}

// 全武器共通の強化を1つ作る
Upgrade makeUpgrade(String name, String description, String target, String type, float value) {
  return makeUpgrade(name, description, target, type, value, null);
}

// 特定の武器のみに適用する強化を1つ作る
Upgrade makeUpgrade(String name, String description, String target, String type, float value, String weaponName) {
  Upgrade u = new Upgrade();

  u.name = name;
  u.description = description;
  u.target = target;
  u.type = type;
  u.value = value;
  u.weaponName = weaponName;

  return u;
}

// 強化の全候補
ArrayList<Upgrade> allUpgrades() {
  ArrayList<Upgrade> list = new ArrayList<Upgrade>();

  list.add(makeUpgrade("HP強化", "最大HPが20増加し、全回復する", "PLAYER", "HP", 20));
  list.add(makeUpgrade("移動速度強化", "移動速度が0.5上昇する", "PLAYER", "SPEED", 0.5));
  list.add(makeUpgrade("攻撃力強化", "全武器の威力が20%上昇する", "WEAPON", "DAMAGE", 0.2));
  list.add(makeUpgrade("連射速度強化", "全武器の発射間隔が15%短縮する", "WEAPON", "FIRERATE", 0.15));
  list.add(makeUpgrade("弾速強化", "全武器の弾速が20%上昇する", "WEAPON", "BULLETSPEED", 0.2));

  // 武器ごとの専用強化
  list.add(makeUpgrade("連射モード威力強化", "連射モードの威力が25%上昇する", "WEAPON", "DAMAGE", 0.25, "連射モード"));
  list.add(makeUpgrade("大砲威力強化", "大砲モードの威力が25%上昇する", "WEAPON", "DAMAGE", 0.25, "大砲モード"));
  list.add(makeUpgrade("爆発弾威力強化", "爆発弾モードの威力が25%上昇する", "WEAPON", "DAMAGE", 0.25, "爆発弾モード"));
  list.add(makeUpgrade("爆発範囲強化", "爆発弾モードの爆風範囲が25%広がる", "WEAPON", "EXPLOSIONRADIUS", 0.25, "爆発弾モード"));
  list.add(makeUpgrade("ノックバック強化", "大砲モードのノックバック距離が30%伸びる", "WEAPON", "KNOCKBACK", 0.3, "大砲モード"));

  return list;
}

// 全候補からcount個を重複なしでランダムに選ぶ
ArrayList<Upgrade> randomUpgrades(int count) {
  ArrayList<Upgrade> pool = allUpgrades();
  ArrayList<Upgrade> picked = new ArrayList<Upgrade>();

  for (int i = 0; i < count && pool.size() > 0; i++) {
    int idx = int(random(pool.size()));
    picked.add(pool.remove(idx));
  }

  return picked;
}