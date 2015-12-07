{ stdenv, lib, core, kernel, fs, makeWrapper, xterm }:

stdenv.mkDerivation {
  name = "netkit-ng-${lib.getVersion core}";

  nativeBuildInputs = [ makeWrapper ];

  buildCommand = ''
    mkdir -p $out

    for i in ${core}/{share,netkit.conf,Netkit-konsole.profile}; do
      ln -s $i $out
    done

    mkdir -p $out/bin
    find ${core}/bin -maxdepth 1 -type f -executable | while read i; do
      makeWrapper "$i" "$out/bin/$(basename "$i")" \
        --prefix PATH ':' "${xterm}/bin" \
        --set NETKIT_HOME "$out"
    done
    find ${core}/bin -maxdepth 1 ! -type f -or ! -executable | while read i; do
      ln -s "$i" "$out/bin/$(basename "$i")"
    done

    mkdir $out/fs
    ln -s ${fs} $out/fs/netkit-fs

    mkdir $out/kernel
    ln -s ${kernel}/bin/linux.uml $out/kernel/netkit-kernel
    mkdir $out/kernel/modules
    ln -s ${kernel}/lib $out/kernel/modules/lib
  '';

  meta = with stdenv.lib; {
    description = "Environment for setting up and performing networking experiments";
    homepage = https://netkit-ng.github.io/;
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ abbradar ];
  };
}
