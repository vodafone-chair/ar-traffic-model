# AR-traffic-model

This repository contains a MATLAB implementation of the traffic model presented in the following publication:

P. Schulz, A. Traßl, N. Schwarzenberg, and G. Fettweis: "Analysis and Modeling of Downlink Traffic in Cloud-Rendering Architectures for Augmented Reality",
to be submitted to IEEE 5G World Forum 2021, Montreal, Canada.

## Overview of the Files
A more detailed description may be found in the files.

### Main functions
Filename | Description
--- | ---
traffic_simulation_demo | Demo that shows the basic functionality and creates the example realizations of the publications
traffic_simulation      | The function to run the simulation
DefaultTrafficModel     | A function that returns the default parameters of the traffic model, which can be adjusted if desired.

### Helper functions
Filename | Description
--- | ---
bounded_ARIMA   | A helper function to simulate a bounded ARIMA process
delayedsum      | helper function for the bounded ARIMA function
DiscreteDist    | returns a distribution object for a discrete random variable (does not implement all functionalities so far)
discrete_random | helper function for Discrete Dist (PDF)
ensure_col      | helper function for dimensionality
