{
  evergarden-whiskers,

  mkShellNoCC,

  writeShellApplication,

  catppuccin-catwalk,
  catppuccin-whiskers,
  fd,
  libwebp,
  ...
}:
let
  generate = writeShellApplication {
    name = "generate";
    runtimeInputs = [
      evergarden-whiskers
    ];
    text = ''
      item="$1"
      file="$(realpath "''${item}")"
      filename="''${item##*/}"
      name="''${filename%.tera}"
      >&2 echo "generating port for $name"
      mkdir -p "ports/''${name}"
      cd "ports/''${name}"
        whiskers "''${file}"
    '';
  };

  generate-all = writeShellApplication {
    name = "generate-all";
    runtimeInputs = [
      generate
    ];
    text = ''
      for item in templates/*.tera; do
        generate "$item"
      done
    '';
  };

  generate-new = writeShellApplication {
    name = "generate-new";
    runtimeInputs = [
      generate
    ];
    text = ''
      for item in templates/*.tera; do
        filename="''${item##*/}"
        name="''${filename%.tera}"
        if [[ ! -d "ports/''${name}" ]]; then
          >&2 echo "generating $item"
          generate "$item"
        else
          >&2 echo "skipping $item"
        fi
      done
    '';
  };

  convert-screenshots = writeShellApplication {
    name = "convert-screenshots";
    runtimeInputs = [
      fd
      libwebp
    ];
    text = ''
      for item in $(fd --exact-depth 3 -t file ".png" ports/); do
        filename="''${item%.png}.webp"
        cwebp -q 100 "$item" -o "$filename"
      done
    '';
  };

  generate-screenshots = writeShellApplication {
    name = "generate-screenshots";
    runtimeInputs = [
      catppuccin-catwalk
      fd
    ];
    text = ''
      for item in $(fd --exact-depth 1 -t directory '''''' ports/); do
        name="''${item##*/}"
        out="''${item}preview.webp"
        if [[ ! -f "$out" ]]; then
          >&2 echo "creating preview for $name -> $out"
          catwalk -C "$item" winter.webp fall.webp falll.webp spring.webp --output preview.webp
        fi
      done
    '';
  };
in
mkShellNoCC {
  packages = [
    catppuccin-catwalk
    catppuccin-whiskers

    generate
    generate-new
    generate-all
    generate-screenshots
    convert-screenshots

    libwebp
  ];
}
