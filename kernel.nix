{ stdenv, build, fetchgit, fetchurl, bash, perl, vde2, libpcap, kmod }:

let
  debianPatches = fetchgit {
    url = "git://git.debian.org/git/pkg-uml/user-mode-linux.git";
    rev = "refs/tags/3.2-2um-1";
    sha256 = "2d4417489c98d5d263f9b9da1ccbc67979c27c6dfb36bb51b6f094f778f7c46e";
  };

  #kernelVersion = "3.2.51";
  kernelVersion = "3.2.73";

in stdenv.mkDerivation {
  name = "kernel-netkit-ng-${kernelVersion}-K3.0";

  src = fetchurl {
    url = "https://cdn.kernel.org/pub/linux/kernel/v3.x/linux-${kernelVersion}.tar.xz";
    #sha256 = "1x1yk07ihfbrhsycmd44h9fn6ajg6akwgsxxdi2rk5cs8g706s63";
    sha256 = "0gg4p004wvkc697a50v6rwpqarm795p9b9myvy01k7rcrprmkn8c";
  };

  prePatch = ''
    for mf in $(find -name Makefile -o -name Makefile.include -o -name install.sh); do
      echo "stripping FHS paths in \`$mf'..."
      sed -i "$mf" -e 's|/usr/bin/||g ; s|/bin/||g ; s|/sbin/||g'
    done
    sed -i Makefile -e 's|= depmod|= ${kmod}/sbin/depmod|'
  '';

  patches = [ "${debianPatches}/debian/patches/04_remove_irqf_disabled.patch"
              "${debianPatches}/debian/patches/06-fix-linkage-on-386-arch.patch"
              "${build}/kernel/patches/90-netkit_support.patch"
            ];

  nativeBuildInputs = [ perl ];

  buildInputs = [ 
    (vde2.override { enableStatic = true; })
    (libpcap.override { enableStatic = true; })
  ];

  enableParallelBuilding = true;

  makeFlags = [ "ARCH=um" ];
  buildFlags = [ "linux" "modules" ];
  installFlags = [ "INSTALL_MOD_PATH=$(out)" "INSTALL_MOD_STRIP=1" ];
  installTargets = [ "modules_install" ];

  preBuild = ''
    cp ${build}/kernel/config.i386 .config

    buildFlagsArray+=("KBUILD_BUILD_VERSION=1-NixOS" "KBUILD_BUILD_TIMESTAMP=Thu Jan 1 00:00:01 UTC 1970")
    sed -i 's,/bin/bash,${bash}/bin/bash,g' arch/um/Makefile

    # Fails for a strange reason but updates config anyway
    make $makeFlags oldconfig
  '';

  postInstall = ''
    rm -rf $out/lib/modules/*/build $out/lib/modules/*/source
    mkdir $out/lib/uml
    mv $out/lib/modules $out/lib/uml/modules
    install -D -m755 linux $out/bin/linux.uml
  '';

  meta = with stdenv.lib; {
    description = "User Mode Linux kernel for Netkit-NG";
    homepage = https://kernel.org;
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ abbradar ];
  };
}
