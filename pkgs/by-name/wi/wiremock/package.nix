{
  fetchurl,
  gitUpdater,
  jre,
  lib,
  makeWrapper,
  stdenv,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wiremock";
  version = "3.5.2";

  src = fetchurl {
    url = "mirror://maven/org/wiremock/wiremock-standalone/${finalAttrs.version}/wiremock-standalone-${finalAttrs.version}.jar";
    hash = "sha256-27DIcfP5R1Qiwl2fhvUQjFsE8pTHTv5MuFqHGa+whVY=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p "$out"/{share/wiremock,bin}
    cp ${finalAttrs.src} "$out/share/wiremock/wiremock.jar"

    makeWrapper ${jre}/bin/java $out/bin/${finalAttrs.meta.mainProgram} \
      --add-flags "-jar $out/share/wiremock/wiremock.jar"
  '';

  passthru = {
    tests.version = testers.testVersion {
      command = "${lib.getExe finalAttrs.finalPackage} --version";
      package = finalAttrs.finalPackage;
    };
    updateScript = gitUpdater {
      url = "https://github.com/wiremock/wiremock.git";
      ignoredVersions = "(alpha|beta|rc).*";
    };
  };

  meta = {
    description = "A flexible tool for building mock APIs";
    homepage = "https://wiremock.org/";
    changelog = "https://github.com/wiremock/wiremock/releases/tag/${finalAttrs.version}";
    maintainers = with lib.maintainers; [ bobvanderlinden anthonyroussel ];
    mainProgram = "wiremock";
    platforms = jre.meta.platforms;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.asl20;
  };
})
