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

    systemd.services.rstatus = {
      enable = true;
      description = "Rstatus";
      serviceConfig = {
        Environment = "DISPLAY=:0";
        ExecStart = "${pkgs.rstatus}/bin/rstatus";
      };
      wantedBy = ["multi-user.target"];
    };
  };
}
