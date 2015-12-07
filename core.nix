{ stdenv, fetchFromGitHub, readline, ncurses, linuxHeaders }:

let
  version = "3.0.4";

in stdenv.mkDerivation {
  name = "netkit-ng-core-${version}";

  src = fetchFromGitHub {
    owner = "netkit-ng";
    repo = "netkit-ng-core";
    rev = version;
    sha256 = "0fx1xxmgz6vgv04kxl6qfhfh8zj6xf01fc554idmgf80hskvms5r";
  };

  buildInputs = [ readline ncurses linuxHeaders ];

  postPatch = ''
    sed -i \
      -e 's/-static-libgcc//g' \
      -e 's/-static//g' \
      -e 's/-ltinfo//g' \
      src/mconsole/Makefile
    sed -i \
      -e 's,/usr/include/linux,${linuxHeaders}/include/linux,g' \
      src/Makefile
  '';

  installTargets = [ "package" ];

  installPhase = ''
    mkdir -p $out
    cp -r build/netkit-ng/* $out
  '';

  meta = with stdenv.lib; {
    description = "Scripts and tools that make up the Netkit core";
    homepage = https://netkit-ng.github.io/;
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ abbradar ];
  };
}
