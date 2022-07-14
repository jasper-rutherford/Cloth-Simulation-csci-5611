//Cloth falls on a ball in 3D
//Project 2.2
//Jasper Rutherford <ruthe124@umn.edu>

//Simulation Parameters (heavily based off of the RopeStarter in class activity
PVector gravity = new PVector(0, 100, 0);
float restLen = 1;
float mass = 6;
float k = 20000;
float kv = 500;
float dt = 1/(20*frameRate);

//Initial positions and velocities of masses
static int nodeWidth = 50;
static int nodeHeight = 40;

//int numNodes = nodeWidth * nodeHeight;

PVector sphereCenter = new PVector(-15, 35, nodeWidth / 2 * -restLen  - 200);
float sphereRadius = 30;

Camera camera;
Cloth cloth;

PImage face;

void setup()
{
  size(700, 700, P3D);



  camera = new Camera();
  cloth = new Cloth(nodeWidth, nodeHeight, restLen, k, kv, dt);
  face = loadImage("face.png");
}

void draw()
{
  //light blue background
  background(102, 219, 255);

  for (int lcv = 0; lcv < 5; lcv++)
  {
    cloth.update();
  }

  camera.Update(1.0/frameRate);

  //render sphere
  fill(176, 171, 16); //beautiful yellow color //fill(11, 14, 41); <--monke//  
  pushMatrix();
  specular(120, 120, 180);  //Setup lights… 
  ambientLight(90,90,90);   //More light…
  lightSpecular(255,255,255); shininess(20);  //More light…
  directionalLight(200, 200, 200, -1, 1, -1); //More light…
  translate(sphereCenter.x, sphereCenter.y, sphereCenter.z);
  sphere(sphereRadius);
  popMatrix();

  cloth.render();
}


//for the camera
void keyPressed()
{
  camera.HandleKeyPressed();

  //reset the cloth
  if (key == 'o' || key == 'O')
  {
    cloth = new Cloth(nodeWidth, nodeHeight, restLen, k, kv, dt);
  }
  
  //reset everything
  if (key == 'p' || key == 'P')
  {
    setup();
  }
}

void keyReleased()
{
  camera.HandleKeyReleased();
}
