class UI {

  void drawTitle() {
    fill(255);
    textAlign(CENTER, CENTER);

    textSize(36);
    text("武器切り替え型アリーナシューティング", width / 2, height / 2 - 60);

    textSize(20);
    text("Enterキーでスタート", width / 2, height / 2);

    textSize(14);
    text("WASD:移動　マウス:照準　左クリック不要（自動発射）　1〜3 or ホイール:武器切替", width / 2, height / 2 + 40);
  }

  void drawHP(Player p) {
    float barX = 20;
    float barY = 20;
    float barW = 200;
    float barH = 20;

    float ratio = constrain(p.hp / p.maxHp, 0, 1);

    fill(60);
    rect(barX, barY, barW, barH);

    fill(220, 50, 50);
    rect(barX, barY, barW * ratio, barH);

    fill(255);
    textAlign(LEFT, TOP);
    textSize(14);
    text("HP " + max(0, ceil(p.hp)) + " / " + (int)p.maxHp, barX, barY + barH + 4);
  }

  void drawScore(Player p) {
    fill(255);
    textAlign(RIGHT, TOP);

    textSize(18);
    text("SCORE " + p.score, width - 20, 20);

    textSize(14);
    text("LV " + p.level + "　EXP " + p.exp + "/" + p.nextLevelExp, width - 20, 44);
  }

  void drawWave(WaveManager wm) {
    fill(255);
    textAlign(CENTER, TOP);
    textSize(18);

    if (wm.currentWave >= wm.totalWaves) {
      text("WAVE " + wm.currentWave + " / " + wm.totalWaves + "（BOSS）", width / 2, 20);
    } else {
      text("WAVE " + wm.currentWave + " / " + wm.totalWaves, width / 2, 20);
    }
  }

  void drawWeapon(Player p) {
    fill(255);
    textAlign(LEFT, BOTTOM);
    textSize(16);
    text("武器: " + p.currentWeapon.name + "（" + p.currentWeapon.attackType + "）", 20, height - 20);
  }

  void drawUpgradeMenu(ArrayList<Upgrade> choices, boolean isWaveClear, int waveBonus) {
    fill(0, 0, 0, 180);
    rect(0, 0, width, height);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(28);
    text(isWaveClear ? "WAVE CLEAR!" : "LEVEL UP!", width / 2, height / 2 - 140);

    if (isWaveClear) {
      fill(255, 220, 100);
      textSize(16);
      text("到達ボーナス込み +" + waveBonus + "点（速く突破するほど加算されます）", width / 2, height / 2 - 114);
      fill(255);
    }

    textSize(16);
    text("強化を1つ選んでください（数字キー 1〜" + choices.size() + "）", width / 2, height / 2 - 88);

    float cardW = 220;
    float cardH = 160;
    float totalW = choices.size() * cardW + (choices.size() - 1) * 40;
    float startX = width / 2 - totalW / 2;
    float cardY = height / 2 - 40;

    for (int i = 0; i < choices.size(); i++) {
      Upgrade u = choices.get(i);
      float cardX = startX + i * (cardW + 40);

      fill(50, 50, 70);
      rect(cardX, cardY, cardW, cardH, 8);

      fill(255);
      textAlign(CENTER, TOP);
      textSize(18);
      text((i + 1) + ". " + u.name, cardX + cardW / 2, cardY + 16);

      textSize(13);
      text(u.description, cardX + 10, cardY + 60, cardW - 20, cardH - 70);
    }
  }

  void drawGameOver(Player p) {
    fill(255);
    textAlign(CENTER, CENTER);

    textSize(40);
    text("GAME OVER", width / 2, height / 2 - 20);

    textSize(20);
    text("SCORE " + p.score, width / 2, height / 2 + 20);
    text("Rキーでリトライ", width / 2, height / 2 + 50);
  }

  void drawGameClear(Player p) {
    fill(255);
    textAlign(CENTER, CENTER);

    textSize(40);
    text("GAME CLEAR", width / 2, height / 2 - 20);

    textSize(20);
    text("SCORE " + p.score, width / 2, height / 2 + 20);
    text("Rキーでリトライ", width / 2, height / 2 + 50);
  }

}
