# Editoren: Zed + JetBrains-IDEs.
{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "toml"
      "dockerfile"
    ];
  };

  home.packages = with pkgs.jetbrains; [
    idea # Java
    clion # C / C++
    webstorm # JavaScript / TypeScript
    rust-rover # Rust
  ];
}
