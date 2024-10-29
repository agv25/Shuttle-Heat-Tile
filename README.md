This code models the heat distribution through a heat shield tile on the Space Shuttle (or Starship).

Tile surface temperature data is automatically read from the graphs in the .png files.
Four different numerical approximation methods for solving the Heat Equation PDE were used, Forwards Differencing, Backwards Differencing, DuFort-Frankel, and the Crank-Nicolson.
The stability and accuracy of each approximation method was compared. Crank-Nicolson was the most accurate and stable.
The shooting method is used to estimate the optimal tile thickness for various locations on the space shuttle.
MATLAB App Designer was introduced for a more user friendly display.
