# Editoren: Zed + JetBrains-IDEs.
{
  pkgs,
  lib,
  osConfig,
  ...
}:
{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "toml"
      "dockerfile"
    ];
  };

  home.packages = lib.optionals osConfig.amboss.jetbrains.enable (
    with pkgs.jetbrains;
    [
      idea # Java
      clion # C / C++
      webstorm # JavaScript / TypeScript
      rust-rover # Rust
    ]
  );
}
