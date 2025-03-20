{
  description = "Dedalus3 flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
        dedalus = pkgs.python311Packages.buildPythonPackage rec {
          pname = "dedalus";
          version = "3.0.3";
          src = pkgs.fetchFromGitHub {
            owner = "DedalusProject";
            repo = "dedalus";
            rev = "8cb06e8dc69a1caa8620cdccf05101158c138d41";
            hash = "sha256-PCtbtq8dQxPpP2o2H5kbAGfhSxTtSkOn5UFER5nw93g=";
          };
          nativeBuildInputs = with pkgs; [ python311Packages.numpy
                                           python311Packages.cython
                                           python311Packages.setuptools
                                           python311Packages.mpi4py
                                           openmpi
                                           fftw
                                           fftwMpi
          ];
          propagatedBuildInputs = with pkgs; [ openmpi fftw fftwMpi ];
        };
        python = pkgs.python311Packages.python;
        pythonEnv = python.withPackages (ps: with ps; [
          pandas
          matplotlib
          numpy
          scipy
          dedalus
          #jupyterlab  # Include JupyterLab in pythonEnv
          ipykernel   # Include ipykernel to register kernels        

          # Dedalus requirements
          numexpr
          mpi4py
          h5py
          xarray
        ]);
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            pythonEnv
            openmpi
            fftw
            fftwMpi
          ];
        };
      }
    );
}
