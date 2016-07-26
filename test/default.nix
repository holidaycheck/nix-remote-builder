{ system ? "x86_64-linux"
, pkgs ? import <nixpkgs> { inherit system; }
, time ? ""
}:
pkgs.stdenv.mkDerivation {
  name = "build-test";
  src = pkgs.fetchurl {
    url = "mirror://gnu/hello/hello-2.10.tar.gz";
    sha256 = "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89ndq1i";
  };
  fixupPhase = ''
    mkdir -p $out
    echo ${time} > $out/stamp
  '';
}
