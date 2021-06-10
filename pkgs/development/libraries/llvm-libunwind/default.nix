# A "standalone" version of LLVM's libunwind with headers

{ llvmPackages_latest }:

llvmPackages_latest.libunwind.overrideAttrs (old: {
  postInstall = (old.postInstall or "") + ''
    mkdir -p $dev/include
    cp ../include/*.h $dev/include
  '';
})
