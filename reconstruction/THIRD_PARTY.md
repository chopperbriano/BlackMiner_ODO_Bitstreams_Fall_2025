# Third-party sources

## BlackMiner

Source: https://github.com/black1225/blackminer

Pinned reference commit: `15e3c9dd3bc86890bd36ede3c4a1ab1f522c5912`.

`constraints/415t.xdc` is the published BlackMiner 415T constraint file, retained with attribution so the reconstruction uses the board vendor's pin mapping.

## MentalCollatz OdoCrypt FPGA miner

Source: https://github.com/MentalCollatz/odo-miner

Pinned commit: `fb1bd94892e3b1893bfc2439ebec877b25856b18`.

The upstream project is GPL-3.0-or-later. This repository does not vendor its HDL/C++ source. `scripts/bootstrap_upstream.ps1` clones the pinned upstream commit into the ignored `third_party/` directory. Any redistribution of upstream or derivative GPL code must follow its license.

The reconstruction wrapper files in this directory are separate project glue; review licensing before distributing a combined binary/source package.
