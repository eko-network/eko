{pkgs}: {
  app,
  pname,
  version,
}: let
  installScript = pkgs.replaceVars ./install.sh {
    inherit pname;
  };
in
  pkgs.stdenv.mkDerivation {
    name = "${pname}-generic-linux-${version}";
    nativeBuildInputs = [pkgs.patchelf pkgs.gnutar pkgs.gzip];
    dontUnpack = true;
    dontPatchELF = true;
    dontBuild = true;
    installPhase = ''
      staging_dir="${pname}-linux-${version}"
      release_root="$staging_dir/${pname}"
      mkdir -p "$release_root"

      cp -R ${app}/app/${pname}/* "$release_root/"
      cp -r ${app}/share "$staging_dir/"

      for lib in libwebcrypto.so libopenmls_frb.so; do
        if [ -f "${app}/build/native_assets/linux/$lib" ]; then
          cp "${app}/build/native_assets/linux/$lib" "$release_root/lib/"
        fi
      done


      chmod -R +w "$staging_dir"

      # --- UN-NIXIFY ---
      patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 "$release_root/${pname}"
      patchelf --set-rpath '$ORIGIN/lib' "$release_root/${pname}"

      if [ -d "$release_root/lib" ]; then
        find "$release_root/lib" -name "*.so" -exec patchelf --set-rpath '$ORIGIN' {} \;
      fi

      # --- INSTALLER SCRIPT ---
      cp ${installScript} "$staging_dir/install.sh"
      chmod +x "$staging_dir/install.sh"

      mkdir -p $out
      tar -czf "$out/${pname}-linux-${version}.tar.gz" "$staging_dir"
    '';
  }
