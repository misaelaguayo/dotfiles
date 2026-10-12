# agenix recipients. Not imported by the system config; only read by the
# agenix CLI. Edit a secret with `agenix -e <name>.age` from this directory.
let
  misael = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHXOE7ndiXgA0cPKpKdHNvIgNdhgJT/d/DMdssCy+EuN";
  desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILQZBiJMmIg9GSqfqgBrvFjiI17pAd1bVuLIBodwotH2";
in
{
  "nas-smb-credentials.age".publicKeys = [
    misael
    desktop
  ];
}
