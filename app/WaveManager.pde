class WaveManager {

  int currentWave;
  int enemyCount;
  boolean cleared;

  int totalWaves = 5;  // 最終Waveでボスが出現する

  int waveStartTime;

  int waveClearBaseBonus = 200;    // Wave到達数に応じたボーナスの係数（到達Wave数に比例）
  int speedBonusMax = 500;         // 突破速度ボーナスの上限（0秒クリアの場合）
  int speedBonusDecayPerSec = 10;  // 1秒経過するごとに速度ボーナスが減る量

  WaveManager() {
    currentWave = 0;
    enemyCount = 0;
    cleared = false;
  }

  void nextWave() {
    currentWave++;
    cleared = false;
    waveStartTime = millis();
    spawnEnemies();
  }

  void spawnEnemies() {
    enemies.clear();

    if (currentWave >= totalWaves) {
      enemies.add(new Boss(width / 2, 100));
    } else {

      int count = 3 + currentWave * 2;
      String[] types = {"heavy", "flying", "obstacle"};

      // Waveが進むほど敵が強くなるようにHP・攻撃力を底上げする
      float scale = 1 + (currentWave - 1) * 0.15;

      float minSpawnDistance = 200;  // 自機からこれ以上離れた位置に湧かせる

      for (int i = 0; i < count; i++) {
        float ex, ey;
        int attempts = 0;

        do {
          ex = random(60, width - 60);
          ey = random(60, height - 60);
          attempts++;
        } while (dist(ex, ey, player.x, player.y) < minSpawnDistance && attempts < 20);

        String type = types[int(random(types.length))];

        Enemy e = new Enemy(ex, ey, type);
        e.hp *= scale;
        e.attackPower = (int)(e.attackPower * scale);

        enemies.add(e);
      }
    }

    enemyCount = enemies.size();
  }

  boolean isClear() {
    cleared = enemies.isEmpty();
    return cleared;
  }

  // Wave到達ボーナス＋突破速度ボーナスを計算する
  // isClear()がtrueになった直後に1回だけ呼ぶ想定
  int calculateClearBonus() {

    int waveBonus = waveClearBaseBonus * currentWave;

    int elapsedSeconds = (millis() - waveStartTime) / 1000;
    int speedBonus = max(0, speedBonusMax - elapsedSeconds * speedBonusDecayPerSec);

    return waveBonus + speedBonus;
  }

}
