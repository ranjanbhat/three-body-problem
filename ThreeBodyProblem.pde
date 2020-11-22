float xangle=-PI/12;
float zangle=0;
float yangle=-PI/12;
float G=1;
float counter=0;
Planet system[]= new Planet[3];
PVector r[]= new PVector[3];
PVector v[]= new PVector[3];
float m[]= new float[3];
float R[]= new float[3];
color fillc[]= new color[3];
color trailc[]= new color[3];
PVector rcom;
PVector vcom;
float totalmass=0;
float dt=0.01;
float flag=1;
void mousePressed()
{
  flag=1-flag;
}

void keyPressed()
{
  if(keyCode==RIGHT) yangle+=0.1;
  else
  if(keyCode==LEFT)  yangle-=0.1;
  else
  if(keyCode==UP) xangle+=0.1;
  else
  if(keyCode==DOWN)  xangle-=0.1;
  else 
  if(keyCode==ESC) exit();
}

void setup()
{
  colorMode(RGB);
  fullScreen(P3D);

  String line = null; 
  BufferedReader reader = createReader("constants1.txt");
  try 
  {
    for(int i=0; i<3; i++) line=reader.readLine();   //first 3 lines
    
    for(int i=0; i<3; i++)                           //masses
      {
        line=reader.readLine();
        String[] pieces=split(line,':');
        m[i]=float(pieces[1]);
      }
    
    for(int i=0; i<3; i++)                           //radii
      {
        line=reader.readLine();
        String[] pieces=split(line,':');
        R[i]=float(pieces[1]);
      }
    
    for(int i=0; i<2; i++) line=reader.readLine();   //next 2 lines
    
    for(int i=0; i<3; i++)                           //initial positions
    {
      float array[]=new float[3];
      for(int j=0; j<3; j++)
      {
        line=reader.readLine();
        String[] pieces=split(line,':');
        array[j]=float(pieces[1]);
      }
      r[i]=new PVector(array[0],array[1],array[2]);     
    }
    
    for(int i=0; i<2; i++) line=reader.readLine();   //next 2 lines
    
    for(int i=0; i<3; i++)                           //initial velocities
    {
      float array[]=new float[3];
      for(int j=0; j<3; j++)
      {
        line=reader.readLine();
        String[] pieces=split(line,':');
        array[j]=float(pieces[1]);
      }
      v[i]=new PVector(array[0],array[1],array[2]);
    }
    
    for(int i=0; i<2; i++) line=reader.readLine();   //next 2 lines
    
    for(int i=0; i<3; i++)                           //fill colors
    {
      int array[]=new int[3];
      for(int j=0; j<3; j++)
      {
        line=reader.readLine();
        String[] pieces=split(line,':');
        array[j]=int(pieces[1]);
      }
      fillc[i]=color(array[0],array[1],array[2]);     
    }
    
    for(int i=0; i<2; i++) line=reader.readLine();   //next 2 lines
    
    for(int i=0; i<3; i++)                           //orbit colors
    {
      int array[]=new int[3];
      for(int j=0; j<3; j++)
      {
        line=reader.readLine();
        String[] pieces=split(line,':');
        array[j]=int(pieces[1]);
      }
      trailc[i]=color(array[0],array[1],array[2]);     
    }
    
    
    reader.close(); 
   
  } catch (IOException e) { 
    e.printStackTrace(); 
  }  
  
  
  for ( int i=0; i<3; i++)
  {
    system[i]=new Planet(r[i], v[i], m[i],fillc[i],trailc[i], R[i]);
  }
  normalizeSystem();
}

void draw()
{
  background(0);
  translate(width/2,height/2,0);
  rotateZ(zangle);
  rotateX(xangle);
  rotateY(yangle);  
  directionalLight(255,255,255,1000,1000,-1000);
  stroke(255);
  strokeWeight(1);
  
  stroke(#FF1493);
  line(0,-10000,0,0,10000,0);
  line(-10000,0,0,10000,0,0);
  line(0,0,-10000,0,0,10000);
  
  for(Planet p : system)
  {
    p.display();
  }
  
  updateSystem();
}

void updateSystem()
{
  for ( int i=0; i<3; i++ )
  {
    for(int j=0; j<3; j++)
    {
      if(i==j) continue;
      PVector rij = new PVector(system[j].position.x-system[i].position.x,
                                system[j].position.y-system[i].position.y,
                                system[j].position.z-system[i].position.z);
      rij.normalize();
      float rijsquare= rij.magSq();
      system[i].force.add(scl(rij, G*system[i].mass*system[j].mass/rijsquare));
    }
  }
  for( int i=0; i<3; i++)
  {
    system[i].update();
  }
}



class Planet
{
  color fillcol;
  ArrayList<PVector> trail;
  color trailcol;
  PVector position;
  PVector velocity;
  PVector acceleration;
  PVector force;
  float mass;
  float radius;
  Planet(PVector pos,PVector vel,float m, color fillc,color trailc, float r)
  {
    fillcol=fillc;
    trailcol=trailc;
    position=pos;
    velocity=vel;
    mass=m;
    radius=r;
    force=new PVector();
    trail=new ArrayList<PVector>();
  }
  
  void display()
  {
    if(flag==1)   showtrail();
    fill(fillcol);
    noStroke();
    translate( position.x, position.y, position.z);
    sphere(radius);
    translate(-position.x,-position.y,-position.z);
  }
  
  void showtrail()
  {
    noFill();
    beginShape();
    for(PVector p: trail)
    {
      stroke(trailcol);
      strokeWeight(2);
      vertex(p.x,p.y,p.z);
    }
    endShape();
  }
  
  void update()
  {
    if (trail.size()>100) trail.remove(0);
    trail.add(new PVector(position.x, position.y, position.z));
    acceleration=scl(force,1.0/mass);
    velocity= velocity.add(scl(acceleration,dt));
    position= position.add(scl(velocity,dt));
    force.set(0,0,0);
  }
  
}

PVector scl(PVector P, float A)
{
  return new PVector(P.x*A, P.y*A, P.z*A);
}

void normalizeSystem()
{
  PVector rcom= new PVector(0,0,0);
  PVector vcom= new PVector(0,0,0);
  for(Planet p : system)
  {
    rcom.add(scl(p.position,p.mass));
    vcom.add(scl(p.velocity,p.mass));
    totalmass+=p.mass;
  }
  rcom= scl(rcom,1/totalmass);
  vcom= scl(vcom,1/totalmass);
  
  for(Planet p : system)
  {
    p.position.sub(rcom);
    p.velocity.sub(vcom);
  }
}
