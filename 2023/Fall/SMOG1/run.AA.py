from OpenSMOG import SBM

#Choose some basic runtime settings.  We will call our system gb1.CA
SMOGrun = SBM(name='gb1.AA', time_step=0.002, collision_rate=1.0, r_cutoff=0.65, temperature=0.5)

#Select a platform and GPU IDs (if needed)
SMOGrun.setup_openmm(platform='cpu',GPUindex='default')

#Decide where to save your data (here or output_folder)
SMOGrun.saveFolder('.')

#You may optionally set some input file names to variables
SMOG_grofile = 'gb1.AA.gro'
SMOG_topfile = 'gb1.AA.top'
SMOG_xmlfile = 'gb1.AA.xml'

#Load your force field data
SMOGrun.loadSystem(Grofile=SMOG_grofile, Topfile=SMOG_topfile, Xmlfile=SMOG_xmlfile)

#Create the context, and prepare the simulation to run
SMOGrun.createSimulation()

#Perform energy minimization
SMOGrun.minimize(tolerance=1)

#Decide how frequently to save data
SMOGrun.createReporters(trajectory=True, energies=True, energy_components=True, interval=50)

#Launch the simulation
SMOGrun.run(nsteps=2*10**3, report=True, interval=50)

