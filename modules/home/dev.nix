# Entwicklungswerkzeuge. Grundausstattung global; projektspezifische
# Versionen kommen per `flake.nix` + direnv aus dem jeweiligen Projekt.
{ pkgs, ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.java.enable = true; # JDK + JAVA_HOME

  home.packages = with pkgs; [
    # C / C++
    gcc
    gnumake
    cmake
    ninja
    gdb
    clang-tools # clangd, clang-format

    # JavaScript / TypeScript
    nodejs
    pnpm
    typescript

    # Rust (Toolchains via `rustup default stable`)
    rustup

    # Java-Buildtools
    maven
    gradle

    # Docker
    docker-compose
    lazydocker

    # Nix
    nixd
    nixfmt
  ];
}
