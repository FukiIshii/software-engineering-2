class Explosion {

  float x, y;
  float maxSize;  // 表示上の最大直径（爆発弾の爆風半径から換算）

  int startTime;
  int duration = 300;  // エフェクトの表示時間（ミリ秒）

  boolean alive;

  Explosion(float x, float y, float blastRadius) {
    this.x = x;
    this.y = y;

    maxSize = blastRadius * 2;

    startTime = millis();
    alive = true;
  }

  void update() {
    display();

    if (millis() - startTime > duration) {
      alive = false;
    }
  }

  void display() {

    float t = constrain((millis() - startTime) / (float) duration, 0, 1);

    float size = maxSize * (0.5 + 0.5 * t);  // だんだん広がる
    float alpha = 255 * (1 - t);             // だんだん消える

    if (explosionImg != null) {
      tint(255, alpha);
      image(explosionImg, x, y, size, size);
      noTint();
    } else {
      fill(255, 150, 0, alpha);
      ellipse(x, y, size, size);
    }
  }

}
