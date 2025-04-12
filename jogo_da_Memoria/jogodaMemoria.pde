ArrayList<Carta> cartas;
PImage verso, logo, imgFundo, imgIntro;
String[] temas = {"Bundesliga", "SerieA", "SerieB", "LaLiga", "PremierLeague"};
int temaSelecionado = 0;

int linhas = 4;
int colunas = 4;
int cartaLargura = 140;
int cartaAltura = 140;
int espacamento = 15;

Carta primeiraCarta = null;
Carta segundaCarta = null;
boolean aguardando = false;
int tempoEspera;

int estadoDoJogo = 0;
int tempoIntro;

PFont fonte;
PFont fonteTitulo;

int quadroX, quadroY;

ArrayList<Particula> particulas = new ArrayList<Particula>();
int tempoVitoria = 0;

void setup() {
  size(1000, 700);
  verso = loadImage("Imagens/imagemPadraoVerso.png");
  verso.resize(cartaLargura, cartaAltura);
  logo = loadImage("Imagens/logo.png");
  logo.resize(350, 250);
  imgFundo = loadImage("Imagens/imagemFundo.jpg");
  imgFundo.resize(1000, 700);
  imgIntro = loadImage("Imagens/imagemTelaInicial.jpg");
  imgIntro.resize(1000, 700);
  fonte = createFont("Arial", 22);
  fonteTitulo = createFont("Arial Bold", 50);
  textFont(fonte);
  frameRate(60);
  calcularCentralizacao();
  tempoIntro = millis();
}

void calcularCentralizacao() {
  int larguraTotal = colunas * (cartaLargura + espacamento) - espacamento;
  int alturaTotal = linhas * (cartaAltura + espacamento) - espacamento;
  quadroX = (width - larguraTotal) / 2;
  quadroY = (height - alturaTotal) / 2;
}

void draw() {
  if (estadoDoJogo == 0) {
    mostrarIntro();
    if (millis() - tempoIntro > 3000) {
      estadoDoJogo = 1;
    }
  } else if (estadoDoJogo == 1) {
    mostrarSelecaoDeTema();
  } else if (estadoDoJogo == 2) {
    mostrarJogo();
  } else if (estadoDoJogo == 3) {
    mostrarTelaVitoria();
  }
}

void mostrarIntro() {
  image(imgIntro, 0, 0);

  // Brilho do logo
  float brilho = sin(frameCount * 0.2) * 50;
  imageMode(CENTER);
  image(logo, width / 2, height / 2 - 130);
  imageMode(CORNER);

  // Fundo translúcido atrás do texto
  fill(0, 0, 0, 180);
  noStroke();
  rect(width / 2 - 120, height / 2 + 50, 240, 50, 10);

  // Texto de carregamento com destaque
  textFont(fonte);
  textSize(28);
  textAlign(CENTER);
  fill(180 + int(brilho), 200, 255);
  text("Carregando...", width / 2, height / 2 + 80);
}


void mostrarSelecaoDeTema() {
  background(50, 50, 80);
  fill(255);
  textAlign(CENTER, CENTER);
  textFont(fonteTitulo);
  textSize(42);
  text("Selecione um Tema", width / 2, 80);
  textFont(fonte);
 for (int i = 0; i < temas.length; i++) {
  if (i == temaSelecionado) {
    fill(0, 180, 0);
    rect(width / 2 - 200, 150 + i * 70, 400, 70, 20); 
    fill(255);
  } else {
    fill(200);
  }
  textSize(36); 
  text(temas[i], width / 2, 190 + i * 70); 
}


  fill(180);
  textSize(18);
  text("Use ↑ ↓ para escolher e ENTER para iniciar", width / 2, height - 50);
}

void mostrarJogo() {
  background(imgFundo);
  fill(60, 60, 80, 180);
  stroke(255);
  strokeWeight(2);
  rect(quadroX - 20, quadroY - 20,
       colunas * (cartaLargura + espacamento) - espacamento + 40,
       linhas * (cartaAltura + espacamento) - espacamento + 40, 20);

  for (Carta c : cartas) {
    c.mostrar();
  }

  if (aguardando && millis() > tempoEspera) {
    if (primeiraCarta != null && segundaCarta != null) {
      if (primeiraCarta.comparar(segundaCarta)) {
        primeiraCarta.combinada = true;
        segundaCarta.combinada = true;
      } else {
        primeiraCarta.virar();
        segundaCarta.virar();
      }
    }
    primeiraCarta = null;
    segundaCarta = null;
    aguardando = false;
  }

  boolean venceu = true;
  for (Carta c : cartas) {
    if (!c.combinada) {
      venceu = false;
      break;
    }
  }

  if (venceu) {
    estadoDoJogo = 3;
    tempoVitoria = millis();
  }
}

void mostrarTelaVitoria() {
  image(imgFundo, 0, 0, width, height);
  textAlign(CENTER, CENTER);
  textFont(fonteTitulo);
  textSize(60);
  if ((millis() / 500) % 2 == 0) {
    fill(0, 255, 0);
    text("VOCÊ VENCEU!", width / 2, height / 2 - 100);
  }
  if (frameCount % 5 == 0) {
    for (int i = 0; i < 10; i++) {
      particulas.add(new Particula(width / 2, height / 2));
    }
  }
  for (int i = particulas.size() - 1; i >= 0; i--) {
    Particula p = particulas.get(i);
    p.atualizar();
    p.mostrar();
    if (p.tempoDeVida <= 0) {
      particulas.remove(i);
    }
  }
  fill(200);
  textFont(fonte);
  textSize(24);
  text("Pressione ENTER para voltar ao menu", width / 2, height - 60);
}

void keyPressed() {
  if (estadoDoJogo == 1) {
    if (keyCode == UP) {
      temaSelecionado = (temaSelecionado - 1 + temas.length) % temas.length;
    } else if (keyCode == DOWN) {
      temaSelecionado = (temaSelecionado + 1) % temas.length;
    } else if (key == ENTER) {
      iniciarCartas(temas[temaSelecionado]);
      estadoDoJogo = 2;
    }
  } else if (estadoDoJogo == 3 && key == ENTER) {
    estadoDoJogo = 1;
  }
}

void mousePressed() {
  if (estadoDoJogo != 2) return;
  for (Carta c : cartas) {
    if (c.contem(mouseX, mouseY) && !c.virada && !c.combinada && !aguardando) {
      c.virar();
      if (primeiraCarta == null) {
        primeiraCarta = c;
      } else if (segundaCarta == null) {
        segundaCarta = c;
        aguardando = true;
        tempoEspera = millis() + 800;
      }
      break;
    }
  }
}

void iniciarCartas(String tema) {
  cartas = new ArrayList<Carta>();
  ArrayList<PImage> imagens = new ArrayList<PImage>();
  for (int i = 0; i < 8; i++) {
    String caminho = "Imagens/" + tema + "/img" + i + ".png";
    PImage img = loadImage(caminho);
    img.resize(cartaLargura, cartaAltura);
    imagens.add(img);
    imagens.add(img);
  }
  imagens = embaralhar(imagens);
  calcularCentralizacao();
  for (int i = 0; i < linhas; i++) {
    for (int j = 0; j < colunas; j++) {
      int x = quadroX + j * (cartaLargura + espacamento);
      int y = quadroY + i * (cartaAltura + espacamento);
      cartas.add(new Carta(x, y, cartaLargura, cartaAltura, imagens.remove(0)));
    }
  }
}

ArrayList<PImage> embaralhar(ArrayList<PImage> lista) {
  for (int i = lista.size() - 1; i > 0; i--) {
    int j = int(random(i + 1));
    PImage temp = lista.get(i);
    lista.set(i, lista.get(j));
    lista.set(j, temp);
  }
  return lista;
}

class Carta {
  int x, y, w, h;
  boolean virada = false;
  boolean combinada = false;
  PImage frente;

  Carta(int x, int y, int w, int h, PImage frente) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.frente = frente;
  }

  void mostrar() {
    noStroke();
    if (virada || combinada) {
      image(frente, x, y, w, h);
    } else {
      image(verso, x, y, w, h);
    }
    if (combinada) {
      stroke(0, 255, 0);
      strokeWeight(3);
      noFill();
      rect(x, y, w, h, 8);
    }
  }

  boolean contem(int mx, int my) {
    return mx > x && mx < x + w && my > y && my < y + h;
  }

  void virar() {
    virada = !virada;
  }

  boolean comparar(Carta outra) {
    return this.frente.equals(outra.frente);
  }
}

class Particula {
  float x, y;
  float vx, vy;
  float tempoDeVida = 255;
  color cor;

  Particula(float x, float y) {
    this.x = x;
    this.y = y;
    this.vx = random(-3, 3);
    this.vy = random(-4, -1);
    this.cor = color(random(255), random(255), random(255));
  }

  void atualizar() {
    x += vx;
    y += vy;
    vy += 0.1;
    tempoDeVida -= 3;
  }

  void mostrar() {
    noStroke();
    fill(cor, tempoDeVida);
    ellipse(x, y, 10, 10);
  }
}
