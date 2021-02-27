{
  busybox = import <nix/fetchurl.nix> {
    url = "http://---/busybox";
    sha256 = "962e6a7d14884608eb070ef8b04e7b639f463c19da149e562fd9df6a406fb92b";
    executable = true;
  };

  bootstrapTools = import <nix/fetchurl.nix> {
    url = "http://---/bootstrap-tools.tar.xz";
    sha256 = "288eda2285baac7e98ab28e6b273db4cdbd04a3b88af5c9a31654cd9bd2731fa";
  };
}
