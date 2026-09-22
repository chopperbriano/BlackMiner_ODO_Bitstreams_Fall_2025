#!/usr/bin/env python3
"""OdoCrypt epoch helpers for the F2 rebuild."""
import argparse
from datetime import datetime, timezone

INTERVAL = 864000  # 10 days

def epoch_start(ts: int) -> int:
    return (ts // INTERVAL) * INTERVAL

def main():
    p = argparse.ArgumentParser()
    p.add_argument("timestamp", type=int)
    args = p.parse_args()
    start = epoch_start(args.timestamp)
    print(f"input={args.timestamp}")
    print(f"epoch_start={start}")
    print(f"epoch_utc={datetime.fromtimestamp(start, timezone.utc).isoformat()}")
    print(f"next_epoch={start + INTERVAL}")

if __name__ == "__main__":
    main()
