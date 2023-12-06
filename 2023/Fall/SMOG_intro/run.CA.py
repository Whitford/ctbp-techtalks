from OpenSMOG import SBM

#Choose some basic runtime settings.  We will call our system gb1.CA
SMOGrun = SBM(name='gb1.CA', time_step=0.002, collision_rate=1.0, r_cutoff=1.1, temperature=0.5)

#Select a platform and GPU IDs (if needed)
SMOGrun.setup_openmm(platform='cpu',GPUindex='default')

#Decide where to save your data (here, output_2ci2)
SMOGrun.saveFolder('.')

#You may optionally set some input file names to variables
SMOG_grofile = 'gb1.CA.gro'
SMOG_topfile = 'gb1.CA.top'
SMOG_xmlfile = 'gb1.CA.xml'

#Load your force field data
SMOGrun.loadSystem(Grofile=SMOG_grofile, Topfile=SMOG_topfile, Xmlfile=SMOG_xmlfile)

#Create the context, and prepare the simulation to run
SMOGrun.createSimulation()

#Perform energy minimization
SMOGrun.minimize(tolerance=1)

#Decide how frequently to save data
SMOGrun.createReporters(trajectory=True, energies=True, energy_components=True, interval=10**2)

#Launch the simulation
SMOGrun.run(nsteps=10**4, report=True, interval=10**2)

