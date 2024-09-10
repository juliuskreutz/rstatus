inputs: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.rstatus;
in {
  options.services.rstatus = {
    enable = lib.mkEnableOption "rstatus";
    package = lib.mkPackageOption pkgs "rstatus" {};
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [inputs.self.overlays.default];

    systemd.user.services.rstatus = {
      description = "Rstatus";
      wantedBy = ["multi-user.target"];
      serviceConfig.execStart = "${pkgs.rstatus}/bin/rstatus";
    };
  };
}
