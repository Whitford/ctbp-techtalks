#include <stdio.h>      
#include <math.h> 
#include <time.h> 

int main()
{
  // How many steps to perform our simulation
  int steps=pow(10,7);
  // what is our timestep
  float timestep=0.002;
  float pi = 3.14159265358979323846;
  // initial spacing of particles along X
  float spacing=1.0;
  // How many particles should we include
  int N=pow(10,2);
  // The length of the system, based on the spacing and number of particles
  float L=(N+1)*spacing;
  int savefreq = 1000;
  int updatefreq = steps/100;
  // Allocate some memory for the x and y coordinates, velocities and forces
  float * x;
  x = new float[N+2];
  float * y;
  y = new float[N+2];
  float * vx;
  vx = new float[N+2];
  float * vy;
  vy = new float[N+2];
  float * fx;
  fx = new float[N+2];
  float * fy;
  fy = new float[N+2];

  FILE * xyzfile;
  xyzfile = fopen ("traj.omp.xyz","w");
  // keep track of run time
    time_t starttime;
    time_t endtime;

  // set boundary conditions
  // we will fix the x values as 0 and (N+1)*spacing
  // y will be fixed to 0 at the boundaries
  x[0]=0;
  y[0]=0;
  x[N+1]=(N+1.0)*spacing;
  y[N+1]=0;

  // initialize the positions of all particles that are not at the boundaries
  // displace by 3 along y and space evenly along x
  for (int i = 1; i < N+1; i++) {
    x[i]=i*1.0;
    y[i]=3.0;
    vx[i]=0;
    vy[i]=0;
  }

  // integrate equations of motion
  starttime = time(NULL);
  for (int i = 0; i < steps; i++) {

    if(i % updatefreq==0){
      printf("%i\n",i);
    }
    // write to xyz file every savefreq steps
    // we will use .xyz format, so we can view the trajectories
    if(i % savefreq==0){
      fprintf(xyzfile,"%i\n",N+2);
      fprintf(xyzfile,"comment line\n");
      for (int j=0;j<N+2;j++){
       fprintf(xyzfile,"atom %f %f %f\n", x[j],y[j],0.0);
      }

    }

// Initially, let's not use omp.  We'll uncomment the next line in a bit
//#pragma omp parallel for
    for (int j = 1; j < N+1; j++) {
      /* Calculate the forces on all non-boundary atoms, based on their 
       two nearest neighbors 
       Note: we could save compute cycled by applying Newton's third law...
       but, this is easier to parallelize, so let's increase the load and 
       use more cores for a net speed up. */
      fx[j]=x[j+1]-2*x[j]+x[j-1];
      fy[j]=y[j+1]-2*y[j]+y[j-1];
    }

   // Euler-cromer method for updating velocities and positions 
//#pragma omp parallel for
    for (int j = 1; j < N+1; j++) {
      vx[j]+=timestep*fx[j];
      vy[j]+=timestep*fy[j];
      x[j]+=timestep*vx[j];
      y[j]+=timestep*vy[j];
    }

  }
 endtime = time(NULL);
 int seconds =difftime(endtime, starttime);
 printf("Job took %i seconds\n",seconds);
 return 0;
}
