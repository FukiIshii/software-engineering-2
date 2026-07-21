PFont jpFont;

// 自機の見た目（武器モードごとに切り替える）
PImage playerImgSpeed;   // 連射モード
PImage playerImgCannon;  // 大砲モード
PImage playerImgBomb;    // 爆発弾モード

PImage explosionImg;  // 爆発弾モードの着弾エフェクト

Player player;

ArrayList<Enemy> enemies;
ArrayList<Bullet> bullets;
ArrayList<EnemyBullet> enemyBullets;
ArrayList<ExpOrb> expOrbs;
ArrayList<Upgrade> upgradeChoices;
ArrayList<Explosion> explosions;

WaveManager waveManager;
UI ui;

int lastWaveBonus = 0;  // 直近のWaveクリアで加算されたボーナス（演出表示用）

// キー入力
boolean up, down, left, right;

// ゲームの状態
final int STATE_TITLE    = 0;
final int STATE_PLAYING  = 1;
final int STATE_LEVELUP  = 2;
final int STATE_WAVECLEAR = 3;
final int STATE_GAMEOVER = 4;
final int STATE_GAMECLEAR = 5;

int gameState;

void setup() {
  size(800, 600);

  jpFont = createFont("美咲ゴシック", 32, true);
  ui = new UI();

  imageMode(CENTER);

  playerImgSpeed = safeLoadImage("player_speed.jpg");
  playerImgCannon = safeLoadImage("player_cannon.jpg");
  playerImgBomb = safeLoadImage("player_bomb.jpg");

  explosionImg = safeLoadImage("explosion.png");

  resetGame();
}

// 画像が無い/読み込めない場合はnullを返す（呼び出し側で円にフォールバックする）
PImage safeLoadImage(String filename) {
  try {
    return loadImage(filename);
  } catch (Exception e) {
    return null;
  }
}

void resetGame() {

  player = new Player(width/2, height/2);

  enemies = new ArrayList<Enemy>();
  bullets = new ArrayList<Bullet>();
  enemyBullets = new ArrayList<EnemyBullet>();
  expOrbs = new ArrayList<ExpOrb>();
  upgradeChoices = new ArrayList<Upgrade>();
  explosions = new ArrayList<Explosion>();

  waveManager = new WaveManager();

  gameState = STATE_TITLE;
}

void startGame() {
  waveManager.nextWave();
  gameState = STATE_PLAYING;
}

void draw() {

  background(30);
  textFont(jpFont);

  if (gameState == STATE_TITLE) {
    ui.drawTitle();
    return;
  }

  if (gameState == STATE_GAMEOVER) {
    ui.drawGameOver(player);
    return;
  }

  if (gameState == STATE_GAMECLEAR) {
    ui.drawGameClear(player);
    return;
  }

  if (gameState == STATE_LEVELUP || gameState == STATE_WAVECLEAR) {

    // 選択待ちの間もフィールドは静止した状態で表示する
    for (Enemy enemy : enemies) {
      enemy.display();
    }
    for (ExpOrb orb : expOrbs) {
      orb.display();
    }
    player.display();

    ui.drawUpgradeMenu(upgradeChoices, gameState == STATE_WAVECLEAR, lastWaveBonus);
    return;
  }

  // ---- ここから STATE_PLAYING ----

  player.update();

  if (player.isDead()) {
    gameState = STATE_GAMEOVER;
    return;
  }

  for (Enemy enemy : enemies) {
    enemy.update();
  }

  // 弾の移動・当たり判定
  for (int i = bullets.size()-1; i >= 0; i--) {

    Bullet b = bullets.get(i);

    b.update();

    // 敵との当たり判定
    for (int j = enemies.size()-1; j >= 0; j--) {

      Enemy e = enemies.get(j);

      if (b.hitEnemies.contains(e)) continue;  // 貫通弾は同じ敵に2回ヒットしない

      float distance = dist(b.x, b.y, e.x, e.y);

      if (distance < e.radius + b.bulletDiameter / 2) {  // 弾ごとの見た目のサイズに合わせた当たり判定

        if (b.explosive) {
          explode(b);  // 着弾地点周囲の敵すべてに範囲ダメージ
        } else {
          damageEnemy(e, b);
        }

        if (b.pierce) {
          b.hitEnemies.add(e);  // 貫通：消えずに次の敵へ飛び続ける
        } else {
          b.alive = false;
        }

        if (!b.pierce) break;  // 非貫通弾は1体に命中したら消費される
      }
    }

    if (!b.alive) {
      bullets.remove(i);
    }
  }

  // 敵弾の移動・プレイヤーとの当たり判定
  for (int i = enemyBullets.size()-1; i >= 0; i--) {

    EnemyBullet eb = enemyBullets.get(i);

    eb.update();

    if (dist(eb.x, eb.y, player.x, player.y) < 15 + eb.radius) {  // 15はplayerのellipse(30,30)相当の半径
      player.takeDamage(eb.damage);
      eb.alive = false;
    }

    if (!eb.alive) {
      enemyBullets.remove(i);
    }
  }

  // 爆発エフェクトの更新
  for (int i = explosions.size()-1; i >= 0; i--) {

    Explosion ex = explosions.get(i);

    ex.update();

    if (!ex.alive) {
      explosions.remove(i);
    }
  }

  // 経験値オーブの移動・回収
  for (int i = expOrbs.size()-1; i >= 0; i--) {

    ExpOrb orb = expOrbs.get(i);

    orb.update();

    if (dist(orb.x, orb.y, player.x, player.y) < 18) {
      orb.collect(player);
    }

    if (!orb.alive) {
      expOrbs.remove(i);
    }
  }

  ui.drawHP(player);
  ui.drawScore(player);
  ui.drawWave(waveManager);
  ui.drawWeapon(player);

  // レベルアップ発生 → 強化選択画面へ（Wave進行より優先）
  if (player.pendingLevelUp) {
    player.pendingLevelUp = false;
    upgradeChoices = randomUpgrades(3);
    gameState = STATE_LEVELUP;
    return;
  }

  // Waveクリア判定
  if (waveManager.isClear()) {

    lastWaveBonus = waveManager.calculateClearBonus();
    player.score += lastWaveBonus;

    if (waveManager.currentWave >= waveManager.totalWaves) {
      gameState = STATE_GAMECLEAR;
    } else {
      upgradeChoices = randomUpgrades(3);
      gameState = STATE_WAVECLEAR;
    }
  }
}

// 弾を1体の敵にヒットさせ、弱点判定・撃破処理まで行う
void damageEnemy(Enemy e, Bullet b) {

  float dmg = b.damage;

  if (e.isWeakAgainst(b.attackType)) {
    dmg *= 1.5;  // 弱点属性への倍率
  } else {
    dmg *= 0.5;  // 弱点でない属性はダメージ減少（武器選択の重要性を高める）
  }

  e.takeDamage(dmg);

  if (b.attackType.equals("打撃")) {
    e.applyKnockback(b.dx, b.dy, b.knockbackForce);  // 大砲モードは命中した敵を後ろへ滑らせる（強化で伸びる）
  }

  if (e.isDead()) {
    player.score += e.scoreValue;
    e.dropExpOrb();
    enemies.remove(e);
  }
}

// 爆発弾モード：着弾地点から半径explosionRadius内の敵すべてにダメージを与える
void explode(Bullet b) {

  explosions.add(new Explosion(b.x, b.y, b.explosionRadius));

  for (int k = enemies.size()-1; k >= 0; k--) {

    Enemy e = enemies.get(k);

    if (dist(b.x, b.y, e.x, e.y) < b.explosionRadius) {
      damageEnemy(e, b);
    }
  }
}

// キーが押されたとき
void keyPressed() {
  if (key == 'w' || key == 'W') up = true;
  if (key == 's' || key == 'S') down = true;
  if (key == 'a' || key == 'A') left = true;
  if (key == 'd' || key == 'D') right = true;

  if (gameState == STATE_TITLE) {
    if (key == ENTER || key == RETURN || key == ' ') {
      startGame();
    }
    return;
  }

  if (gameState == STATE_LEVELUP || gameState == STATE_WAVECLEAR) {

    int idx = -1;
    if (key == '1') idx = 0;
    if (key == '2') idx = 1;
    if (key == '3') idx = 2;

    if (idx >= 0 && idx < upgradeChoices.size()) {
      player.applyUpgrade(upgradeChoices.get(idx));

      if (gameState == STATE_WAVECLEAR) {
        waveManager.nextWave();
      }

      // 選択画面で止まっていた間の経過時間を無効化し、再開直後に攻撃されないようにする
      for (Enemy enemy : enemies) {
        enemy.resetTimers();
      }

      gameState = STATE_PLAYING;
    }
    return;
  }

  if (gameState == STATE_PLAYING) {
    if (key == '1') player.switchWeapon(0);
    if (key == '2') player.switchWeapon(1);
    if (key == '3') player.switchWeapon(2);
  }

  if ((gameState == STATE_GAMEOVER || gameState == STATE_GAMECLEAR) && (key == 'r' || key == 'R')) {
    resetGame();
    startGame();
  }
}

// キーが離されたとき
void keyReleased() {
  if (key == 'w' || key == 'W') up = false;
  if (key == 's' || key == 'S') down = false;
  if (key == 'a' || key == 'A') left = false;
  if (key == 'd' || key == 'D') right = false;
}

// マウスホイールでの武器切り替え
void mouseWheel(MouseEvent event) {
  if (gameState != STATE_PLAYING) return;

  if (event.getCount() > 0) {
    player.cycleWeapon(1);
  } else if (event.getCount() < 0) {
    player.cycleWeapon(-1);
  }
}
