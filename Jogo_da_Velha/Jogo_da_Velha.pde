int tamanho = 200;
int[][] tabuleiro = new int[3][3];
boolean jogadorX = true, jogoAtivo = true, transicao = false;
int fase = 0, letrasAparecendo = 0;
PFont fonte;
float corFundo = 50, opacidadeTabuleiro = 0;
int numSimbolos = 20;
float[] xPos = new float[numSimbolos], yPos = new float[numSimbolos], xDir = new float[numSimbolos], yDir = new float[numSimbolos];
char[] simbolos = new char[numSimbolos];

// Partículas dos fogos de artifício
class Particula {
  float x, y, velX, velY, tamanho;
  color cor;
  int vida;

  Particula(float x, float y) {
    this.x = x; this.y = y;
    velX = random(-3, 3); velY = random(-3, 3);
    tamanho = random(5, 10); cor = color(random(255), random(255), random(255));
    vida = 60;
  }

  void atualizar() { x += velX; y += velY; vida--; }
  void desenhar() { if (vida > 0) { fill(cor, vida * 4); noStroke(); ellipse(x, y, tamanho, tamanho); } }
}

ArrayList<Particula> fogos = new ArrayList<>();

void setup() {
  size(600, 650);
  fonte = createFont("Arial Bold", 100);

  for (int i = 0; i < numSimbolos; i++) {
    xPos[i] = random(width); yPos[i] = random(height);
    xDir[i] = random(-0.5, 0.5); yDir[i] = random(-0.5, 0.5);
    simbolos[i] = random(1) > 0.5 ? 'X' : 'O';
  }
}

void draw() {
  if (fase == 0) animacaoInicial();
  else {
    if (transicao) opacidadeTabuleiro = min(opacidadeTabuleiro + 5, 255);
    background(lerpColor(color(200, 230, 255), color(150, 200, 255), sin(corFundo) * 0.5 + 0.5));
    corFundo += 0.02;
    desenharTabuleiro(); desenharSimbolos();

    int vencedor = verificarVitoria();
    if (vencedor != 0) { jogoAtivo = false; animacaoVitoria(vencedor); }
    else if (verificarEmpate()) { jogoAtivo = false; animacaoEmpate(); }

    for (int i = fogos.size() - 1; i >= 0; i--) {
      Particula p = fogos.get(i);
      p.atualizar(); p.desenhar();
      if (p.vida <= 0) fogos.remove(i);
    }
  }
}

void animacaoInicial() {
  background(50, 100, 255);
  fill(255, 50); textSize(80); textAlign(CENTER, CENTER);

  for (int i = 0; i < numSimbolos; i++) {
    xPos[i] += xDir[i]; yPos[i] += yDir[i];
    if (xPos[i] < 50 || xPos[i] > width - 50) xDir[i] *= -1;
    if (yPos[i] < 50 || yPos[i] > height - 50) yDir[i] *= -1;
    text(simbolos[i], xPos[i], yPos[i]);
  }

  fill(255); textSize(60); String titulo = "JOGO DA VELHA";
  if (frameCount % 5 == 0 && letrasAparecendo < titulo.length()) letrasAparecendo++;
  text(titulo.substring(0, letrasAparecendo), width / 2, height / 3);

  if (letrasAparecendo == titulo.length()) {
    float brilho = sin(frameCount * 0.1) * 50 + 200;
    fill(255, 200, 0, brilho); rect(200, 400, 200, 80, 20);
    fill(0); textSize(30); text("Jogar", width / 2, 440);
  }
}

void desenharTabuleiro() {
  strokeWeight(5); stroke(0, 0, 0, opacidadeTabuleiro);
  for (int i = 1; i < 3; i++) { line(i * tamanho, 0, i * tamanho, height - 50); line(0, i * tamanho, width, i * tamanho); }
}

void desenharSimbolos() {
  textFont(fonte); textAlign(CENTER, CENTER);
  for (int i = 0; i < 3; i++) for (int j = 0; j < 3; j++) {
    int x = j * tamanho + tamanho / 2, y = i * tamanho + tamanho / 2;
    if (tabuleiro[i][j] != 0) {
      fill(tabuleiro[i][j] == 1 ? color(255, 0, 0) : color(0, 0, 255));
      textSize(100); text(tabuleiro[i][j] == 1 ? "X" : "O", x, y);
    }
  }
}

void animacaoVitoria(int vencedor) {
  color corVitoria = vencedor == 1 ? color(255, 0, 0) : color(0, 0, 255);
  fill(lerpColor(corVitoria, color(255, 255, 0), sin(frameCount * 0.2) * 0.5 + 0.5));
  textSize(50); text("Jogador " + (vencedor == 1 ? "X" : "O") + " venceu!", width / 2, height - 50);
  if (frameCount % 5 == 0) for (int i = 0; i < 10; i++) fogos.add(new Particula(random(width), random(height - 50)));
}

void animacaoEmpate() {
  fill(0);  // Cor preta
  textSize(50);
  text("Empate!", width / 2, height - 50);
}

boolean verificarEmpate() {
  for (int i = 0; i < 3; i++) for (int j = 0; j < 3; j++) if (tabuleiro[i][j] == 0) return false;
  return verificarVitoria() == 0;
}

int verificarVitoria() {
  for (int i = 0; i < 3; i++) {
    if (tabuleiro[i][0] != 0 && tabuleiro[i][0] == tabuleiro[i][1] && tabuleiro[i][1] == tabuleiro[i][2]) {
      desenharLinhaVitoria(i, 0, i, 2); return tabuleiro[i][0];
    }
  }
  for (int j = 0; j < 3; j++) {
    if (tabuleiro[0][j] != 0 && tabuleiro[0][j] == tabuleiro[1][j] && tabuleiro[1][j] == tabuleiro[2][j]) {
      desenharLinhaVitoria(0, j, 2, j); return tabuleiro[0][j];
    }
  }
  if (tabuleiro[0][0] != 0 && tabuleiro[0][0] == tabuleiro[1][1] && tabuleiro[1][1] == tabuleiro[2][2]) {
    desenharLinhaVitoria(0, 0, 2, 2); return tabuleiro[0][0];
  }
  if (tabuleiro[0][2] != 0 && tabuleiro[0][2] == tabuleiro[1][1] && tabuleiro[1][1] == tabuleiro[2][0]) {
    desenharLinhaVitoria(0, 2, 2, 0); return tabuleiro[0][2];
  }
  return 0;
}

void desenharLinhaVitoria(int linha1, int col1, int linha2, int col2) {
  float x1 = col1 * tamanho + tamanho / 2, y1 = linha1 * tamanho + tamanho / 2;
  float x2 = col2 * tamanho + tamanho / 2, y2 = linha2 * tamanho + tamanho / 2;
  strokeWeight(8);
  stroke(tabuleiro[linha1][col1] == 1 ? color(255, 0, 0) : color(0, 0, 255));
  line(x1, y1, x2, y2);
}

void mousePressed() {
  if (fase == 0 && mouseX >= 200 && mouseX <= 400 && mouseY >= 400 && mouseY <= 480) {
    fase = 1; transicao = true; opacidadeTabuleiro = 0; resetTabuleiro();
  } else if (jogoAtivo) {
    int linha = floor(mouseY / tamanho), coluna = floor(mouseX / tamanho);
    if (linha >= 0 && linha < 3 && coluna >= 0 && coluna < 3 && tabuleiro[linha][coluna] == 0) {
      tabuleiro[linha][coluna] = jogadorX ? 1 : 2;
      jogadorX = !jogadorX;
    }
  }
}

void keyPressed() {
  if (key == 'r' || key == 'R') { resetTabuleiro(); jogadorX = true; jogoAtivo = true; fogos.clear(); }
}

void resetTabuleiro() { for (int i = 0; i < 3; i++) for (int j = 0; j < 3; j++) tabuleiro[i][j] = 0; }
