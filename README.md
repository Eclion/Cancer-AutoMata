# Cancer AutoMata

## Instructions to start the program

To use this program, you either need Matlab or Octave installed on your computer.

Once installed, open the file UI.m file and run the program.

Please allow between 10-20 minutes for each 20-steps simulation run to complete, on current
 desktop computers with Matlab (at least 2 hours with Octave) with the default parameters.

You can reduce the dish size, dish height in order to make the silumation faster but please
 keep in mind that your output may differ from the paper results.


## Instructions to use the program

Before running a simulation, you can change the following parameters:
* the minimum number of living neighbor cells needed for a living cell to survive (rule i) )
* the maximum number of living neighbor cells needed for a living cell to survive (rule iii) )
* the number of living neighbor cells needed for an empty/dead cell to become a living cell (rule iv) )
* "Save 2D dish snapshot" will save a 2D representation of the dish as an image at the steps presents in the "Snaphot steps" parameter. E cells are green while M cells are red.
* "Save 3D dish snapshot" will save a 3D representation of the dish as an image at the steps presents in the "Snaphot steps" parameter.
* "Snapshot steps" represents the steps where a snapshot of the dish is needed.
* "Number of simulations" represents the number of time a simulation needed to be executed with the current parameters and for every percentages of mesenchymal cells.
* "Number of steps" is the number of steps a simulation will go through.
* "Initial number of cell" is the number of cell before any treatment.
* "Percentages of Mesenchymal cells" is an array of number from 0 to 100. For each element, simulations will be executed.
* "Dish size" is the size of the square dish.
* "Dish height" is the height of the dish.

Once the parameters are set, you can run the simulations by clicking on the button "Run simulations". A "CancerAM_simulations" folder will be created to save data related to the simulations.
