# Known-good BlackMiner OdoCrypt reference images

These files were supplied from the historical BlackMiner F2 OdoCrypt set and inspected directly.

| Epoch seed | UTC epoch start | Bytes | SHA-256 | Vivado header build time |
|---:|---|---:|---|---|
| 1786752000 | 2026-08-15 00:00:00 UTC | 16,348,442 | `b17ae65fd12067314f76392f9fd6a64d059f446a0f914d0450784c4fedeb4af3` | 2025-10-22 11:43:09 |
| 1787616000 | 2026-08-25 00:00:00 UTC | 16,359,610 | `80c0eb7cbb141ebe2c64fbbc5bc477d0cc48781fee9f754c032635f5e750e0a8` | 2025-10-22 14:19:07 |
| 1788480000 | 2026-09-04 00:00:00 UTC | 16,300,294 | `c2c7f8ec74d9f85e1f47306b26e2e2cbe64dcffe9c7464b5e44be951e8f7599f` | 2025-10-22 16:37:36 |

All three readable headers contain:

- Design name: `fpgaminer_top`
- `ENCRYPT=YES`
- `COMPRESS=TRUE`
- `UserID=0XFFFFFFFF`
- `Version=2018.3`
- Device: `7vx415tffg1157`

The epoch seeds differ by exactly 864,000 seconds. The changing compressed/encrypted payload sizes and independent full-payload ciphertext support the working assumption that a fresh epoch-specific design was generated and implemented for each 10-day period.
