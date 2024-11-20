# homelab

Homelab configuration

## Build

```bash
nix run github:nix-community/nixos-anywhere \
--extra-experimental-features "nix-command flakes" \
-- --flake '.#master0' rekcah@master0
```

## Switch

> [!NOTE]
> Run it locally on master0

```bash
nixos-rebuild switch --flake github:philingood/homelab#master0
```
