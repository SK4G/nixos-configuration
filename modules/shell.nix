with import <nixpkgs> {};

(python3.withPackages (ps: with ps; [
  spotdl
])).env