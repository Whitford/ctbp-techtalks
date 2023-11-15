/* 
 PHYS 7321: We are going to going completely overkill on our string system
 
 */

#include <mpi.h>
#include <omp.h>
#include <stdio.h>  
#include <math.h> 
#include <time.h> 
#include <string.h> 
#include <string> 
using namespace std;

int main()
{

    // Initialize the MPI environment
    MPI_Init(NULL, NULL);

    // NOTE: Since we have initialized MPI, all instructions are executed by all ranks, unless explicitly stated otherwise...

    // Get the number of processes
    // MPI_COMM_WORLD is the "communicator".  It is essentially a channel that we can access to communicate
    /// world_size will store the number of ranks
    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);

    // Get the rank of each process
    // Since all instructions are executed on all ranks, world_rank is created on each rank, with its own value
    int world_rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

  // number of particles in the system
    int Nglobal=pow(10,5);
    if (Nglobal % world_size != 0) {
      printf("Can not evenly divide the system\n");
      return 1;
    }
  // time step size
    float timestep=0.002;
  // how many time steps to simulate
    int steps=pow(10,6);
  // how often to save coordinates (in time steps)
    int savefreq=10000;
  // initial spacing of particles along x
    float spacing=1.0;
  // initial displacement along y of all particles
    float initialdispy=3.0;
 
  // keep track of run time
    time_t starttime;
    time_t endtime;
  
// send a subset of particles to each rank

   int N = Nglobal/world_size;

    float trans;
    float recv;  
  // make pointers to arrays on each rank
    float * x;
    float * y;
    float * vx;
    float * vy;
    float * fx;
    float * fy;
  // allocate memory to the arrays on each rank: Note, we are allocating N+2, not Nglobal+2, since these are local memory allocations
    x = new float[N+2];
    y = new float[N+2];
    vx = new float[N+2];
    vy = new float[N+2];
    fx = new float[N+2];
    fy = new float[N+2];
  
  // output file handle on each rank
    FILE * xyzfile;
    char filename[20];

  // have each rank open a different file
    sprintf(filename, "output.%d.xyz", world_rank);
    xyzfile = fopen (filename,"w");
  
  // initialize the positions locally
    for (int i = 0; i < N+2; i++) {
      x[i]=(i+world_rank*N)*1.0;
      y[i]=initialdispy;
      vx[i]=0;
      vy[i]=0;
    }
  // set boundary conditions
  // set the first position to 0, but only the first particle on the first rank (world_rank==0)
  if (world_rank == 0) {
    x[0]=0;
    y[0]=0;
  
  }
  // set the last position, but only the last particle position on the last rank (world_rank==world_size-1)
  if (world_rank == world_size-1) {
    x[N+1]=(Nglobal+1)*1.0;
    y[N+1]=0;
  }

// integrate equations of motion
  starttime = time(NULL);
  for (int i = 0; i < steps; i++) {

    // write to xyz file every savefreq steps
    if(i % savefreq==0){
      printf("%i\n",i);
      fprintf(xyzfile,"%i\n",N+2);
      fprintf(xyzfile,"comment line\n");
      for (int j=0;j<N+2;j++){
       fprintf(xyzfile,"atom %f %f %f\n", x[j],y[j],0.0);
      }

    }
// find forces
//#pragma omp parallel for
    for (int j = 1; j < N+1; j++) {
    // now, these are just the forces of the middle N particles on a rank
  /*     but, this is easier to parallelize, so let's increase the load and 
       use more cores for a net speed up. */
      fx[j]=x[j+1]-2*x[j]+x[j-1];
      fy[j]=y[j+1]-2*y[j]+y[j-1];
    }

// Euler-cromer 
//#pragma omp parallel for
    for (int j = 1; j < N+1; j++) {
    // now, these are just the forces of the middle N particles on a rank
      vx[j]+=timestep*fx[j];
      vy[j]+=timestep*fy[j];
      x[j]+=timestep*vx[j];
      y[j]+=timestep*vy[j];
    }

 // at the end of each step, we have to update the positions of the middle N particles
 // But, the boundary particle of each rank was updated by the adjacent rank
 // So, we need to send and receive some information
    if (world_rank < world_size-1 ) {
     // everything but the last rank should send a position forward
     // this is message sent with tag 0             |
      MPI_Send(&x[N], 1, MPI_FLOAT, world_rank+1, 0, MPI_COMM_WORLD);
      MPI_Send(&y[N], 1, MPI_FLOAT, world_rank+1, 0, MPI_COMM_WORLD);
    } 

    if (world_rank >0 ) {
     // receive the last element of the previous rank and save it to the first element of the current
     // this is message received with tag 0       |
      MPI_Recv(&x[0], 1, MPI_FLOAT, world_rank-1, 0, MPI_COMM_WORLD,
                 MPI_STATUS_IGNORE);
      MPI_Recv(&y[0], 1, MPI_FLOAT, world_rank-1, 0, MPI_COMM_WORLD,
                 MPI_STATUS_IGNORE);
    }

    if (world_rank >0 ) {
     // everything but the first rank should send a position back a rank
     // this is message sent with tag 1           |
      MPI_Send(&x[1], 1, MPI_FLOAT, world_rank-1, 1, MPI_COMM_WORLD);
      MPI_Send(&y[1], 1, MPI_FLOAT, world_rank-1, 1, MPI_COMM_WORLD);
    }

    if (world_rank < world_size-1 ) {
     // this is message received with tag 1         |
      MPI_Recv(&x[N+1], 1, MPI_FLOAT, world_rank+1, 1, MPI_COMM_WORLD,
                 MPI_STATUS_IGNORE);
      MPI_Recv(&y[N+1], 1, MPI_FLOAT, world_rank+1, 1, MPI_COMM_WORLD,
                 MPI_STATUS_IGNORE);
    } 

  }
  endtime = time(NULL);
  int seconds =difftime(endtime, starttime);
  printf("Job took %i seconds\n",seconds);
  MPI_Finalize();
  return 0;
}
