{
  lib,
  pkgs,
  config,
  ...
}:
let

  cfg = config.services.domoticz;
  pkgDesc = "Domoticz home automation";

in
{

  options = {

    services.domoticz = {
      enable = lib.mkEnableOption pkgDesc;

      bind = lib.mkOption {
        type = lib.types.str;
        default = "0.0.0.0";
        description = "IP address to bind to.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 8080;
        description = "Port to bind to for HTTP, set to 0 to disable HTTP.";
      };

    };

  };

  config = lib.mkIf cfg.enable {

    systemd.services."domoticz" = {
      description = pkgDesc;
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        DynamicUser = true;
        StateDirectory = "domoticz";
        Restart = "always";
        ExecStart = ''
          ${pkgs.domoticz}/bin/domoticz -noupdates -www ${toString cfg.port} -wwwbind ${cfg.bind} -sslwww 0 -userdata /var/lib/domoticz -approot ${pkgs.domoticz}/share/domoticz/ -pidfile /var/run/domoticz.pid
        '';
      };
    };

  };

}
