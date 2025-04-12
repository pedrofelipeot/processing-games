int tela = 0;
PFont fonte;
int tempoIntro;

PImage fundo;

int modoSelecionado = 0;
int dificuldadeSelecionada = 1;

float ballX = 0, ballY = 0;
float ballSpeedX = 0, ballSpeedY = 0;
float ballSize = 15;

float paddleW = 15, paddleH = 80;
float player1Y = 0, player2Y = 0;
float playerSpeed = 5;
boolean contraIA = true;

int score1 = 0, score2 = 0;
int limite = 5;

boolean pause = false;

float iaReacao = 0.7;
float bolaVelocidadeBase = 4;

int ultimoPonto = -1;

void setup() {
  size(800, 500);
  fonte = createFont("Arial Black", 32);
  textFont(fonte);
  fundo = loadImage("imagem/fundo.jpg");
  iniciarIntro();
}

void draw() {
  switch (tela) {
    case 0:
      mostrarIntro();
      break;
    case 3:
      background(40, 50, 70);
      mostrarSelecaoModo();
      break;
    case 4:
      background(40, 50, 70);
      mostrarSelecaoDificuldade();
      break;
    case 1:
      if (!pause) jogar();
      else mostrarPause();
      break;
    case 2:
      mostrarVencedor();
      break;
  }
}

void mostrarIntro() {
  image(fundo, 0, 0, width, height);
  float boxWidth = 300;
  float boxHeight = 100;
  float boxX = width / 2 - boxWidth / 2;
  float boxY = height / 2 - boxHeight / 2;

  fill(0, 180);
  noStroke();
  rect(boxX, boxY, boxWidth, boxHeight, 20);

  textAlign(CENTER, CENTER);
  textSize(60);
  fill(0);
  text("PONG", width / 2 + 3, height / 2 + 3);
  fill(255);
  text("PONG", width / 2, height / 2);

  if ((millis() / 500) % 2 == 0) {
    textSize(18);
    fill(255);
    text("Aguarde...", width / 2, height / 2 + 70);
  }

  if (millis() > tempoIntro + 2000) {
    tela = 3;
  }
}

void mostrarSelecaoModo() {
  fill(255);
  textAlign(CENTER);
  textSize(28);
  text("SELECIONE O MODO DE JOGO", width / 2, 100);

  String[] modos = { "Contra IA", "Dois Jogadores" };
  for (int i = 0; i < modos.length; i++) {
    if (i == modoSelecionado) fill(255, 200, 0);
    else fill(255);
    text(modos[i], width / 2, 200 + i * 60);
  }
}

void mostrarSelecaoDificuldade() {
  fill(255);
  textAlign(CENTER);
  textSize(28);
  text("SELECIONE A DIFICULDADE", width / 2, 100);

  String[] niveis = { "Fácil", "Médio", "Difícil" };
  for (int i = 0; i < niveis.length; i++) {
    if (i == dificuldadeSelecionada) fill(255, 200, 0);
    else fill(255);
    text(niveis[i], width / 2, 200 + i * 60);
  }
}

void mostrarPause() {
  fill(255);
  textAlign(CENTER);
  textSize(32);
  text("JOGO PAUSADO", width / 2, height / 2);
}

void mostrarVencedor() {
  for (int i = 0; i < height; i++) {
    float inter = map(i, 0, height, 0, 1);
    stroke(lerpColor(color(20, 30, 50), color(50, 80, 120), inter));
    line(0, i, width, i);
  }

  textAlign(CENTER, CENTER);
  textSize(36);
  fill(255, 220, 100);
  text("FIM DE JOGO", width / 2, 80);

  String vencedor = score1 >= limite ? "Jogador 1 venceu!" : "Jogador 2 venceu!";

  fill(255, 255, 255, 30);
  noStroke();
  rectMode(CENTER);
  rect(width / 2, height / 2 - 20, 400, 100, 20);

  fill(255);
  textSize(32 + sin(frameCount * 0.1) * 2);
  text(vencedor, width / 2, height / 2 - 20);

  fill(220);
  textSize(20);
  text("Pressione R para reiniciar", width / 2, height / 2 + 50);
  text("Pressione ESC para voltar ao menu", width / 2, height / 2 + 85);
}

void jogar() {
  background(25, 25, 35);
  stroke(255);
  line(width / 2, 0, width / 2, height);

  fill(255);
  textSize(26);
  textAlign(CENTER);
  text(score1, width / 4, 40);
  text(score2, width * 3 / 4, 40);

  fill(255);
  rect(30, player1Y, paddleW, paddleH);
  rect(width - 45, player2Y, paddleW, paddleH);

  ellipse(ballX, ballY, ballSize, ballSize);
  ballX += ballSpeedX;
  ballY += ballSpeedY;

  if (ballY < 0 || ballY > height) ballSpeedY *= -1;

  if (ballX < 30 + paddleW && ballY > player1Y && ballY < player1Y + paddleH) {
    ballX = 30 + paddleW;
    ballSpeedX *= -1;
    float impacto = (ballY - (player1Y + paddleH / 2)) / (paddleH / 2);
    ballSpeedY = impacto * 4;
  }

  if (ballX > width - 45 && ballY > player2Y && ballY < player2Y + paddleH) {
    ballX = width - 45;
    ballSpeedX *= -1;
    float impacto = (ballY - (player2Y + paddleH / 2)) / (paddleH / 2);
    ballSpeedY = impacto * 4;
  }

  if (contraIA) {
    if (keyPressed) {
      if (keyCode == UP && player1Y > 0) player1Y -= playerSpeed;
      if (keyCode == DOWN && player1Y + paddleH < height) player1Y += playerSpeed;
    }

    float distancia = ballX - (width - 45);
    float erroIA = random(-30, 30) * (1 - iaReacao);
    float previsaoY = ballY + erroIA;

    if (distancia < 300) {
      float centroIA = player2Y + paddleH / 2;
      float diferenca = previsaoY - centroIA;

      if (abs(diferenca) > 20) {
        if (diferenca > 0 && player2Y + paddleH < height) {
          player2Y += (playerSpeed - 1) * iaReacao;
        } else if (diferenca < 0 && player2Y > 0) {
          player2Y -= (playerSpeed - 1) * iaReacao;
        }
      }
    }
  } else {
    if (keyPressed) {
      if (key == 'w' && player1Y > 0) player1Y -= playerSpeed;
      if (key == 's' && player1Y + paddleH < height) player1Y += playerSpeed;
      if (keyCode == UP && player2Y > 0) player2Y -= playerSpeed;
      if (keyCode == DOWN && player2Y + paddleH < height) player2Y += playerSpeed;
    }
  }

  if (ballX < 0) {
    score2++;
    ultimoPonto = 1; 
    resetBola();
  }
  if (ballX > width) {
    score1++;
    ultimoPonto = 2; 
    resetBola();
  }

  if (score1 >= limite || score2 >= limite) {
    tela = 2;
  }
}

float distanciaInicioBola = 300; 

void resetBola() {
  float dir;

  if (ultimoPonto == -1) {
    dir = random(1) < 0.5 ? -1 : 1;
  } else if (ultimoPonto == 1) {
    dir = 1; 
  } else {
    dir = -1; 
  }

  ballX = width / 2 - (distanciaInicioBola * dir);
  ballY = random(50, height - 50);

  float velBase = contraIA ? bolaVelocidadeBase : 8.0;
  ballSpeedX = velBase * dir;
  ballSpeedY = random(-3, 3);
}


void iniciarJogo() {
  player1Y = height / 2 - paddleH / 2;
  player2Y = height / 2 - paddleH / 2;
  score1 = 0;
  score2 = 0;
  pause = false;
  ultimoPonto = -1;
  resetBola();
  tela = 1;
}

void iniciarIntro() {
  tempoIntro = millis();
  tela = 0;
}

void keyPressed() {
  if (tela == 3) {
    if (keyCode == UP || keyCode == DOWN) modoSelecionado = (modoSelecionado + 1) % 2;
    if (keyCode == ENTER) {
      contraIA = (modoSelecionado == 0);
      if (contraIA) tela = 4;
      else iniciarJogo();
    }
  } else if (tela == 4) {
    if (keyCode == UP) dificuldadeSelecionada = (dificuldadeSelecionada + 2) % 3;
    if (keyCode == DOWN) dificuldadeSelecionada = (dificuldadeSelecionada + 1) % 3;
    if (keyCode == ENTER) {
      if (dificuldadeSelecionada == 0) {
        paddleH = 140;
        iaReacao = 0.4;
        bolaVelocidadeBase = 6;
      } else if (dificuldadeSelecionada == 1) {
        paddleH = 80;
        iaReacao = 0.8;
        bolaVelocidadeBase = 9;
      } else {
        paddleH = 60;
        iaReacao = 1.1;
        bolaVelocidadeBase = 12;
      }
      iniciarJogo();
    }
  } else if (tela == 1 && keyCode == ENTER) {
    pause = !pause;
  } else if (tela == 2 && (key == 'r' || key == 'R')) {
    iniciarJogo();
  }

  if (keyCode == ESC) {
    key = 0;
    iniciarIntro();
  }
}
