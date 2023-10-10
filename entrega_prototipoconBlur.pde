import fisica.*;
import ddf.minim.*;

//cargar assets
PImage backgroundImage;
PImage[] palomaAnim = new PImage[11];
PImage[] personaAnim = new PImage[10];
PImage[] clouds = new PImage[4];
PImage[] assignedCloudImages;
PShader blur;
FWorld world;

//menu principal
PImage startButton;
boolean Menu = true;

//cargar datos
float angulo = 0;
float circleDiameter = 100;
int currentFrame = 0;
float diameter = circleDiameter; 
boolean gameover = false;
int contadorPuntos = 0;

//velocidad animacion
int frameDelay = 5;
int frameDelayPersona = 20;

//Fisica
FCircle paloma;
FCircle persona;
ArrayList<FBox> cloudBoxes = new ArrayList<FBox>();
float xPos;

//objetos audio
AudioPlayer flautis;
Minim minim;

boolean conBlur = false;


void setup() {
  //size(1200, 600);
  size(1200, 600,P2D);
  
  startButton = loadImage("1.png");
  
  // fondo y blur
  backgroundImage = loadImage("animacion/nubes/CLOUDS.jpeg");
  blur = loadShader("blur.glsl");
  
  //sonido
  minim = new Minim(this);
  flautis = minim.loadFile("flautis.mp3", 2048);
  flautis.loop();

  //mundo
  Fisica.init(this);
  world = new FWorld( 0, 0, 50000, 600 );
  world.setEdges(0, 0, 50000, 600);
  FBox bottomBoundary = new FBox(50000, 10);
  bottomBoundary.setPosition(width/2, height - 5); 
  bottomBoundary.setStatic(true);
  bottomBoundary.setFill(0);
  bottomBoundary.setCategoryBits(2);
  bottomBoundary.setName("piso");
  world.add(bottomBoundary);
  
  //paloma
  paloma = new FCircle( circleDiameter / 2);
  paloma.setName("paloma");
  paloma.setFill(0, 0, 0, 0);
  paloma.setStroke(0, 0, 0, 0);
  paloma.setRestitution(0.95);
  paloma.setPosition( 50, 250);
  world.add( paloma );
  for (int i=0; i < palomaAnim.length; i ++){
    palomaAnim[i] = loadImage("animacion/paloma/bird"+i+".png");
  }
  
  //nubes
  for (int i = 0; i < clouds.length; i++) {
    clouds[i] = loadImage("animacion/nubes/cloud" + i + ".png");
  }
  assignedCloudImages = new PImage[10]; 
  for (int i = 0; i < 10; i++) {
    float x = map(i, 0, 10, 200, 4800);
    int cloudIndex = int(random(clouds.length));
    PImage cloudImage = clouds[cloudIndex];
    
    FBox cloud = new FBox(cloudImage.width, cloudImage.height);
    cloud.setStatic(true);    
    cloud.setSensor(true);
    cloud.setName("nube");
    cloud.setFill(0, 0, 0, 1);
    cloud.setStroke(0, 0, 0, 1);
    cloud.setPosition(x, random(50, 450));
    world.add(cloud);
    cloudBoxes.add(cloud);
    
    assignedCloudImages[i] = cloudImage; 
  }
  
  //persona
  persona = new FCircle( circleDiameter / 2);
  persona.setName("persona");
  persona.setFill(0, 0, 0, 0);
  persona.setStroke(0, 0, 0, 0);
  persona.setRestitution(0.95);
  persona.setPosition( 20, 150);
  world.add( persona );
  for (int i=0; i < personaAnim.length; i ++){
    personaAnim[i] = loadImage("animacion/persona/p"+i+".png");
  }
  
  stroke(255, 0, 0);
  rectMode(CENTER);
}

void draw() {
  //println(gameover);
  
  if (Menu) {
    image(backgroundImage, 0, 0, width, height);
    image(startButton, width / 2 - startButton.width / 2, height / 2 - startButton.height / 2);

    if (mouseX >= width / 2 - startButton.width / 2 &&
        mouseX <= width / 2 + startButton.width / 2 &&
        mouseY >= height / 2 - startButton.height / 2 &&
        mouseY <= height / 2 + startButtone.height / 2) {
      cursor(HAND); // Change cursor to a hand when over the button
      if (mousePressed) {
        Menu = false;
      }
    } 
  } else {
 
    
  if( gameover == false){
    
    
    
    image(backgroundImage, 0, 0, width, height);
    world.step();
    
    push();
    translate( -paloma.getX()+width/2, 0 );
    
    for (int i = 0; i < cloudBoxes.size(); i++) {
      FBox cloud = cloudBoxes.get(i);
      PImage cloudImage = assignedCloudImages[i]; 
      float cloudWidth = cloud.getWidth();
      float cloudHeight = cloud.getHeight();
      float posX = cloud.getX() - cloudWidth / 2;
      float posY = cloud.getY() - cloudHeight / 2;
      image(cloudImage, posX, posY, cloudWidth, cloudHeight);
    }
  
    
  
    //animaciones
    image(palomaAnim[currentFrame], paloma.getX() - diameter / 2, paloma.getY() - diameter / 2, diameter, diameter);
    if (frameCount % frameDelay == 0) {
      currentFrame = (currentFrame + 1) % palomaAnim.length;
    }

    pop();
    
    textSize(30);
    textAlign(RIGHT);
    fill(255);
    text(frameCount, width - 30, 50);
    
    if ( keyPressed ) {
      if ( keyCode == LEFT ) {
        paloma.setVelocity( -500, -300 );
      } else if ( keyCode == RIGHT ) {
        paloma.setVelocity( 500, -300 );
      }
    }
  }
  else {
    image(backgroundImage, 0, 0, width, height);
    textSize(20);
    textAlign(CENTER);
    text("perdiste", width/2, height/2);
    text("'y' para empezar de nuevo", width/2, height/2 + 30);
  }
  
  if(conBlur == true){
      filter(blur);
      println("filtro");
    }
   }
}


//mecanicas
void contactStarted(FContact colision) {
  FBody cuerpo1 = colision.getBody1();
  FBody cuerpo2 = colision.getBody2();

  if (cuerpo1 != null && cuerpo2 != null) {
    
    int instante = frameCount;
    
    String nombre1 = cuerpo1.getName();
    String nombre2 = cuerpo2.getName();
    if (nombre1 != null && nombre2 != null) {
      if ( (nombre1.equals("paloma") && nombre2.equals("nube") ) || ( nombre1.equals("nube") && nombre2.equals("paloma")) ) {
        System.out.println("Colisión entre paloma y nube");
        if(frameCount <= instante + 5){
          conBlur = true;
          println(conBlur);
        } else {
          conBlur = false;
          println(conBlur);
        }
      }
      if( (nombre1.equals("paloma") && nombre2.equals("piso") ) || ( nombre1.equals("piso") && nombre2.equals("paloma") ) ) {
        System.out.println("Perdiste");
        gameover = true;
      } 
    }
  }
}

void keyPressed(){
   if(gameover == true && key == 'y'){
      gameover = false; 
      paloma.setPosition( 50, 250);
      frameCount = 0;
   }
}
