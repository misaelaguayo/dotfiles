{ config, pkgs, ... }:
{
  age.secrets.nas-smb-credentials.file = ../../../secrets/nas-smb-credentials.age;

  environment.systemPackages = [ pkgs.cifs-utils ];

  fileSystems."/mnt/smb" = {
    device = "//192.168.0.43/SMB";
    fsType = "cifs";
    options = [
      "credentials=${config.age.secrets.nas-smb-credentials.path}"
      "uid=1000"
      "gid=100"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "_netdev"
    ];
  };
}
