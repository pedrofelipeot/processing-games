String[] nivelFacil = {"JAVA", "ALGORITMO", "DESENVOLVIMENTO", "APLICATIVO", "COMPUTADOR"};
String[] nivelMedio = {"CLOUD", "PYTHON", "SOFTWARE", "DEBUG", "FRONTEND"};
String[] nivelDificil = {"INFRAESTRUTURA", "REACT", "DEVOPS", "PROCESSING", "PROCESSAMENTO"};

// Variáveis para controle do nível escolhido
int nivelEscolhido = 0; // 0 = Fácil, 1 = Médio, 2 = Difícil

String palavraSecreta;
char[] letrasDescobertas;
int tentativasRestantes;
String letrasTentadas;
float oscilar = 0;  
float efeitoTexto = 0;
boolean jogoFinalizado = false;

// Partículas de fundo animadas
int numParticulas = 100;
float[] particulaX = new float[numParticulas];
float[] particulaY = new float[numParticulas];
float[] particulaVel = new float[numParticulas];

// Controle da tela inicial
boolean telaInicial = true;

void setup() {
  size(700, 500);
  iniciarJogo();
  
  // Configurar partículas do fundo
  for (int i = 0; i < numParticulas; i++) {
    particulaX[i] = random(width);
    particulaY[i] = random(height);
    particulaVel[i] = random(1, 3);
  }
}

void draw() {
  if (telaInicial) {
    desenharTelaInicial();
  } else {
    desenharFundoAnimado();
    
    // Exibir palavra com traços alinhados
    textSize(32);
    float startX = width / 2 - palavraSecreta.length() * 22;
    for (int i = 0; i < palavraSecreta.length(); i++) {
      if (letrasDescobertas[i] == '_') {
        fill(200);
        text("_", startX + i * 45, 400);
      } else {
        fill(lerpColor(color(255, 255, 255), color(255, 255, 0), sin(frameCount * 0.1)));
        text(letrasDescobertas[i], startX + i * 45, 400);
      }
    }

    // Informações do jogo
    textSize(22);
    fill(255);
    text("Tentativas restantes: " + tentativasRestantes, width - 250, 80);
    text("Letras tentadas:", width - 200, 120);
    textSize(20);
    text(letrasTentadas, width - 200, 150);
    textSize(18);
    textAlign(LEFT, CENTER); // Alinhar à esquerda
    text("Pressione 'ENTER' para reiniciar", 20, 30); // Lado esquerdo da tela

    // Desenhar forca e boneco
    desenharForca();

    // Exibir mensagem de vitória ou derrota
    if (jogoFinalizado) {
      efeitoTexto = min(efeitoTexto + 3, 255);  // Fade-in
      textSize(30 + sin(frameCount * 0.1) * 5); // Efeito pulsante
      String mensagem = "";
      if (tentativasRestantes == 0) {
        mensagem = "Você perdeu! A palavra era: " + palavraSecreta;
        fill(255, 0, 0, efeitoTexto);
      } else {
        mensagem = "Parabéns! Você venceu!";
        fill(0, 255, 0, efeitoTexto);
      }
      
      // Calcular a largura da mensagem para centralizar
      float larguraMensagem = textWidth(mensagem);
      text(mensagem, width / 2 - larguraMensagem / 2, height - 50); // No final da tela e centralizado
    }
  }
}

// Função para a tela inicial com animação
void desenharTelaInicial() {
  background(20, 10, 40);
  fill(255);
  textSize(50);
  textAlign(CENTER, CENTER);
  text("Jogo da Forca", width / 2, height / 3);

  textSize(25);
  text("Escolha um nível", width / 2, height / 2 - 20);

  // Desenhar os botões apenas se o jogo não tiver iniciado
  if (telaInicial) {
    fill(0, 200, 255);
    rect(width / 4 - 75, height / 2 + 10, 150, 40); // Botão Fácil
    rect(width / 2 - 75, height / 2 + 10, 150, 40); // Botão Médio
    rect(3 * width / 4 - 75, height / 2 + 10, 150, 40); // Botão Difícil

    fill(255);
    textSize(20);
    text("Fácil", width / 4, height / 2 + 30);
    text("Médio", width / 2, height / 2 + 30);
    text("Difícil", 3 * width / 4, height / 2 + 30);
  }

  // Partículas de fundo animadas
  for (int i = 0; i < numParticulas; i++) {
    fill(lerpColor(color(255, 50, 50), color(50, 50, 255), sin(frameCount * 0.02 + i)));
    ellipse(particulaX[i], particulaY[i], 5, 5);
    particulaY[i] += particulaVel[i];

    // Reset da partícula ao sair da tela
    if (particulaY[i] > height) {
      particulaY[i] = 0;
      particulaX[i] = random(width);
    }
  }
}


void keyPressed() {
  if (telaInicial) {
    desenharTelaInicial();
    return;
  }

  if (key == ENTER) {
    iniciarJogo(); // Reiniciar jogo ao pressionar ENTER
    return;
  }

  if (!jogoFinalizado && tentativasRestantes > 0) {
    char letra = Character.toUpperCase(key);
    if (letrasTentadas.indexOf(letra) == -1 && Character.isLetter(letra)) {
      letrasTentadas += letra + " ";
      boolean acertou = false;
      
      // Comparar letras considerando a acentuação correta
      for (int i = 0; i < palavraSecreta.length(); i++) {
        if (palavraSecreta.charAt(i) == letra) {
          letrasDescobertas[i] = letra;
          acertou = true;
        }
      }

      if (!acertou) {
        tentativasRestantes--;
        oscilar = 20; // Ativar balanço do boneco ao errar
      }

      // Verificar fim do jogo
      if (tentativasRestantes == 0 || String.valueOf(letrasDescobertas).equals(palavraSecreta)) {
        jogoFinalizado = true;
      }
    }
  }
}

void iniciarJogo() {
  // Seleciona palavra com base no nível escolhido
  switch (nivelEscolhido) {
    case 0: // Nível fácil
      palavraSecreta = nivelFacil[int(random(nivelFacil.length))];
      break;
    case 1: // Nível médio
      palavraSecreta = nivelMedio[int(random(nivelMedio.length))];
      break;
    case 2: // Nível difícil
      palavraSecreta = nivelDificil[int(random(nivelDificil.length))];
      break;
  }

  letrasDescobertas = new char[palavraSecreta.length()];
  for (int i = 0; i < letrasDescobertas.length; i++) {
    letrasDescobertas[i] = '_';
  }
  tentativasRestantes = 6;
  letrasTentadas = "";
  oscilar = 0;
  efeitoTexto = 0;
  jogoFinalizado = false;
  loop();
}

void desenharForca() {
  stroke(255);
  line(100, 350, 200, 350);
  line(150, 350, 150, 150);
  line(150, 150, 250, 150);
  line(250, 150, 250, 170);

  // Oscilação ao errar
  float deslocamento = sin(frameCount * 0.1) * oscilar;
  if (oscilar > 0) oscilar *= 0.95;

  // Boneco balançando
  if (tentativasRestantes <= 5) ellipse(250 + deslocamento, 190, 40, 40);
  if (tentativasRestantes <= 4) line(250 + deslocamento, 210, 250 + deslocamento, 270);
  if (tentativasRestantes <= 3) line(250 + deslocamento, 230, 230 + deslocamento, 260);
  if (tentativasRestantes <= 2) line(250 + deslocamento, 230, 270 + deslocamento, 260);
  if (tentativasRestantes <= 1) line(250 + deslocamento, 270, 230 + deslocamento, 310);
  if (tentativasRestantes == 0) line(250 + deslocamento, 270, 270 + deslocamento, 310);
}

// Fundo animado com partículas flutuando
void desenharFundoAnimado() {
  background(20, 10, 40);

  for (int i = 0; i < numParticulas; i++) {
    fill(lerpColor(color(255, 50, 50), color(50, 50, 255), sin(frameCount * 0.02 + i)));
    ellipse(particulaX[i], particulaY[i], 5, 5);
    particulaY[i] += particulaVel[i];

    // Reset da partícula ao sair da tela
    if (particulaY[i] > height) {
      particulaY[i] = 0;
      particulaX[i] = random(width);
    }
  }
}

// Função para verificar se o mouse clicou em um dos botões
void mousePressed() {
  if (mouseX > width / 4 - 75 && mouseX < width / 4 + 75 && mouseY > height / 2 + 10 && mouseY < height / 2 + 50) {
    nivelEscolhido = 0; // Fácil
    iniciarJogo();
    telaInicial = false;
  } else if (mouseX > width / 2 - 75 && mouseX < width / 2 + 75 && mouseY > height / 2 + 10 && mouseY < height / 2 + 50) {
    nivelEscolhido = 1; // Médio
    iniciarJogo();
    telaInicial = false;
  } else if (mouseX > 3 * width / 4 - 75 && mouseX < 3 * width / 4 + 75 && mouseY > height / 2 + 10 && mouseY < height / 2 + 50) {
    nivelEscolhido = 2; // Difícil
    iniciarJogo();
    telaInicial = false;
  }
}
