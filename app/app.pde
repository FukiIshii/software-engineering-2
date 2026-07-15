PFont jpFont;

Player player;

ArrayList<Enemy> enemies;

ArrayList<Bullet> bullets;

// キー入力
boolean up, down, left, right;

boolean gameOver = false;

void setup() {
  size(800, 600);

  jpFont = createFont("美咲ゴシック", 32, true);

  resetGame();
}

void resetGame() {

  player = new Player(width/2, height/2);

  enemies = new ArrayList<Enemy>();

  enemies.add(new Enemy(100,100));
  enemies.add(new Enemy(700,100));
  enemies.add(new Enemy(100,500));
  enemies.add(new Enemy(100,500));
  enemies.add(new Enemy(100,500));

  bullets = new ArrayList<Bullet>();

  gameOver = false;
}

void draw() {

  background(30);

  if (gameOver) {
  textFont(jpFont);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(40);
  text("GAME OVER", width/2, height/2);

  textSize(20);
  text("Rキーでリトライ", width/2, height/2 + 50);
  return;
}

  player.update();

  if (player.isDead()) {
    gameOver = true;
  }

  for (Enemy enemy : enemies) 
  {
    enemy.update();
  }

  
  for (int i = bullets.size()-1; i >= 0; i--) {

  Bullet b = bullets.get(i);

  b.update();

  // 敵との当たり判定
  for (int j = enemies.size()-1; j >= 0; j--) {

    Enemy e = enemies.get(j);

    float distance = dist(b.x, b.y, e.x, e.y);

    if (distance < e.radius + 5) {  // 5 = 弾の半径（Bulletのellipse(10,10)相当）

      float dmg = b.damage;

      if (b.attackType.equals(e.weakType)) {
        dmg *= 1.5;  // 弱点属性への倍率
      }

      e.takeDamage(dmg);
      b.alive = false;

      if (e.isDead()) {
        player.score += e.scoreValue;
        enemies.remove(j);
      }

      break;  // この弾は消費したので敵ループを抜ける
    }
  }

  if (!b.alive) {
    bullets.remove(i);
  }
}

}

// キーが押されたとき
void keyPressed() {
  if (key == 'w' || key == 'W') up = true;
  if (key == 's' || key == 'S') down = true;
  if (key == 'a' || key == 'A') left = true;
  if (key == 'd' || key == 'D') right = true;

  if (key == '1') player.switchWeapon(0);
  if (key == '2') player.switchWeapon(1);
  if (key == '3') player.switchWeapon(2);
  if (key == '4') player.switchWeapon(3);

  if (gameOver && (key == 'r' || key == 'R')) {
    resetGame();
  }
}

// キーが離されたとき
void keyReleased() {
  if (key == 'w' || key == 'W') up = false;
  if (key == 's' || key == 'S') down = false;
  if (key == 'a' || key == 'A') left = false;
  if (key == 'd' || key == 'D') right = false;
}
