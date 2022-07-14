//Cloth Object. It's the cloth!
//CSCI 5611 Project 2.2
// Jasper Rutherford <ruthe124@umn.edu>

public class Cloth
{
  public PVector p[][];  //stores all the positions of all the nodes
  public PVector v[][];  //stores all the velocities of all the nodes
  public PVector a[][];  //stores all the accelerations of all the nodes
  public float l0;       //default distance from one node to a neighbor node
  public float ks;       //string factor to be used with distance
  public float kd;       //string factor to be used with velocity
  public float dt;       //length of a time step

  public Cloth(int nodeWidth, int nodeHeight, float l0, float ks, float kd, float dt)
  {
    this.l0 = l0;
    this.ks = ks;
    this.kd = kd;
    this.dt = dt;

    //initialize positions
    p = new PVector[nodeWidth][nodeHeight];
    for (int x = 0; x < nodeWidth; x++)
    {
      for (int y = 0; y < nodeHeight; y++)
      {
        p[x][y] = new PVector(y * -l0 + (l0 * nodeWidth / 2), 0, x * -l0  - 200);
      }
    }

    //initialize velocities to 0
    v = new PVector[nodeWidth][nodeHeight];
    a = new PVector[nodeWidth][nodeHeight];
    for (int x = 0; x < nodeWidth; x++)
    {
      for (int y = 0; y < nodeHeight; y++)
      {
        v[x][y] = new PVector(0, 0, 0);
      }
    }
  }

  //updates all the nodes in the cloth
  //this code is heavily based off of the "RopeStarter_Vec2" activity
  public void update()
  {
    //Reset accelerations each timestep (momentum only applies to velocity)
    for (int x = 0; x < p.length; x++)
    {
      for (int y = 0; y < p[0].length; y++)
      {
        a[x][y] = new PVector(0, 0, 0);
        a[x][y].add(gravity);
      }
    }

    //update nodes relative to their horizontal neighbors first
    for (int x = 0; x < p.length - 1; x++)
    {
      for (int y = 0; y < p[0].length; y++)
      {
        PVector dir = PVector.sub(p[x + 1][y], p[x][y]);
        float force = -ks * (dir.mag() - l0);

        dir.normalize();
        float projVbot = v[x][y].dot(dir);
        float projVtop = v[x + 1][y].dot(dir);
        float dampF = -kd * (projVtop - projVbot);


        dir.mult(force + dampF);

        dir.mult(1.0/mass);

        a[x][y].sub(dir);
        a[x + 1][y].add(dir);
      }
    }

    //update nodes relative to their vertical neighbors second
    for (int x = 0; x < p.length; x++)
    {
      for (int y = 0; y < p[0].length - 1; y++)
      {
        PVector dir = PVector.sub(p[x][y + 1], p[x][y]);
        float force = -ks * (dir.mag() - l0);

        dir.normalize();
        float projVbot = v[x][y].dot(dir);
        float projVtop = v[x][y + 1].dot(dir);
        float dampF = -kd * (projVtop - projVbot);


        dir.mult(force + dampF);

        dir.mult(1.0/mass);

        a[x][y].sub(dir);
        a[x][y + 1].add(dir);
      }
    }



    //Eulerian integration
    for (int x = 0; x < p.length; x++)
    {
      for (int y = 1; y < p[0].length; y++) //start at 1 to pin the top row
      {
        //if (!((x == 0 && y == 0) || (x == p.length - 1) && (y == 0)))
        //{
        PVector helper = new PVector(a[x][y].x, a[x][y].y, a[x][y].z);
        helper.mult(dt);
        v[x][y].add(helper);

        helper = new PVector(v[x][y].x, v[x][y].y, v[x][y].z);
        helper.mult(dt);

        p[x][y].add(helper);
        //}
      }
    }

    //collision detection and response
    for (int x = 0; x < p.length; x++)
    {
      for (int y = 0; y < p[0].length; y++)
      {
        PVector helper = new PVector(p[x][y].x, p[x][y].y, p[x][y].z);
        helper.sub(sphereCenter);      //set helper to be the vector pointing from the center of the sphere to the node in collision

        //if the given node is colliding with the sphere
        if (helper.mag() <= sphereRadius + .02)
        {
          //move it to the edge of the sphere along the normal
          helper.normalize();
          helper.mult(sphereRadius + .02);
          helper.add(sphereCenter);
          p[x][y] = new PVector(helper.x, helper.y, helper.z);

          //reflect velocity
          helper.sub(sphereCenter);
          helper.mult(1 / (sphereRadius + .02));      //set helper back to the normal
          helper.mult(helper.dot(v[x][y]));   //project the velocity onto the normal

          helper.mult(1);  //don't bounce with 100% energy
          v[x][y].sub(helper);
        }
      }
    }
  }

  //I shamelessly adapted this code from https://youtu.be/FeXnJSCFj-Q
  public void render()
  {
    noFill();
    noStroke();
    textureMode(NORMAL);
    for (int y = 0; y < p[0].length - 1; y++)
    {
      beginShape(TRIANGLE_STRIP);
      texture(face);
      for (int x = 0; x < p.length; x++)
      {
        float u = map(x, 0, p.length - 1, 0, 1);
        float v1 = map(y, 0, p[0].length - 1, 0, 1);
        vertex(p[x][y].x, p[x][y].y, p[x][y].z, u, v1);
        float v2 = map(y + 1, 0, p[0].length - 1, 0, 1);
        vertex(p[x][y + 1].x, p[x][y + 1].y, p[x][y + 1].z, u, v2);
      }
      endShape();
    }
  }
}
