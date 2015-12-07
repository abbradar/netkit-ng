{ stdenv, build }:

# Too much impurities ATM, built in the VM
stdenv.mkDerivation {
  name = "netkit-ng-fs-0.1.3";

  src = ./netkit-ng-fs.tar.bz2;

  installPhase = ''
    mv $(readlink -f fs/netkit-fs) $out
  '';
}
