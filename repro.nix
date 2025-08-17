{
  salt ? "",
}:
let
  pkgs = import ./. {};
  inherit (pkgs) lib;

  # Set to null to use LEGIT(tm) ld64
  xcode = null;
  #xcode = "/Applications/Xcode.app";
  xcodeBin = "${xcode}/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin";

  # Set to your ld64 clone
  ld64src = /Users/zhaofeng/Git/ld64;

  oldToolset = {
    inherit (pkgs)
      ld64
      cctools;
    inherit (pkgs.darwin)
      binutils-unwrapped;
  };

  toolset = if xcode != null then rec {
    # Xcode
    ld64 = pkgs.writeShellScriptBin "ld" ''
      #exec /usr/bin/arch -x86_64 ${xcodeBin}/ld "$@"
      exec ${xcodeBin}/ld "$@"
    '';
    cctools = pkgs.runCommand (lib.replaceString oldToolset.cctools.version "9999.9" oldToolset.cctools.name) {
      version = "9999.9";
      outputs = [ "out" "libtool" ];
    } ''
      mkdir -p $out/bin $libtool/bin
      ln -s "${xcodeBin}/libtool" "$libtool/bin/libtool"

      tools=(
        ar
        bitcode_strip
        cmpdylib
        codesign_allocate
        ctf_insert
        install_name_tool
        libtool
        lipo
        nm
        nmedit
        otool
        pagestuff
        ranlib
        redo_prebinding
        segedit
        size
        strings
        strip
        vtool
      )

      for tool in "''${tools[@]}"; do
        ln -s "${xcodeBin}/$tool" "$out/bin/$tool"
      done
    '';
    binutils-unwrapped = oldToolset.binutils-unwrapped.override {
      inherit ld64 cctools;
    };
  } else rec {
    # Patched ld64
    ld64 = oldToolset.ld64.overrideAttrs (old: {
      pname = old.pname + "-maybe-legit";
      src = pkgs.nix-gitignore.gitignoreSource [ ] ld64src;
      patches = [];
      prePatch = "";
    });
    cctools = oldToolset.cctools.override {
      inherit ld64;
    };
    binutils-unwrapped = oldToolset.binutils-unwrapped.override {
      inherit ld64 cctools;
    };
  };

  apple-sdk = pkgs.replaceDependencies {
    drv = pkgs.apple-sdk;
    replacements = [
      {
        oldDependency = pkgs.darwin.binutils-unwrapped;
        newDependency = toolset.binutils-unwrapped;
      }
      {
        oldDependency = pkgs.cctools.libtool;
        newDependency = toolset.cctools.libtool;
      }
    ];
  };

  binutils = (pkgs.darwin.binutils.override {
    bintools = toolset.binutils-unwrapped;
    apple-sdk = apple-sdk;
  }).overrideAttrs (old: {
    #postFixup = (old.postFixup or "") + ''
    #  sed -i '2i NIX_DEBUG=1' $out/bin/ld
    #'';
  });

  stdenv = pkgs.stdenv.override {
    cc = pkgs.stdenv.cc.override {
      bintools = binutils;
      apple-sdk = apple-sdk;
    };
    extraBuildInputs = [];
    allowedRequisites = null;
  };

  gitFull = (pkgs.gitFull.override {
    inherit stdenv;
    #withManual = false;
  }).overrideAttrs (old: {
    NIX_CFLAGS_LINK = "-v";
    SALT = salt;

    #postFixup = (old.postFixup or "") + ''
    #  ${pkgs.gnutar}/bin/tar cvf $out/git.tar $out/bin/git
    #'';
  });
in {
  inherit
    toolset
    binutils
    stdenv
    gitFull
    ;
}
