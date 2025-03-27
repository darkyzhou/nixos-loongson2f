{
  stdenv,
  fetchFromGitHub,
  cmake,
  texinfo,
  autoconf,
  automake,
  libtool,
  curl,
  libffi,
}:
stdenv.mkDerivation {
  pname = "txiki";
  version = "ba8bf77";

  src = fetchFromGitHub {
    owner = "saghul";
    repo = "txiki.js";
    rev = "ba8bf7742e2304816ddada0872284cc6047a3c8c";
    sha256 = "sha256-lwjoY+iHXCPH7oM8AJGTTZiWMjRBX+cEJAIyP3n7J2I=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    texinfo
    autoconf
    automake
    libtool
  ];

  buildInputs = [
    curl
    libffi
  ];

  cmakeFlags = [
    "-DUSE_EXTERNAL_FFI=ON"
    "-DBUILD_WITH_MIMALLOC=OFF"
  ];

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv tjs $out/bin
  '';
}
