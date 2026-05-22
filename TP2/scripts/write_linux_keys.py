#!/usr/bin/env python3
import json
import os
import stat
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: write_linux_keys.py <output-dir>", file=sys.stderr)
        return 2

    raw_keys = os.environ.get("TP2_LINUX_SSH_KEYS_JSON", "{}")
    try:
        keys = json.loads(raw_keys)
    except json.JSONDecodeError as error:
        print(f"TP2_LINUX_SSH_KEYS_JSON is not valid JSON: {error}", file=sys.stderr)
        return 1

    if not isinstance(keys, dict):
        print("TP2_LINUX_SSH_KEYS_JSON must be a JSON object.", file=sys.stderr)
        return 1

    output_dir = Path(sys.argv[1])
    output_dir.mkdir(parents=True, exist_ok=True)

    for auth_ref, private_key in keys.items():
        if not isinstance(private_key, str) or not private_key.strip():
            print(f"SSH key for {auth_ref} must be a non-empty string.", file=sys.stderr)
            return 1

        key_path = output_dir / f"{auth_ref}.pem"
        key_path.write_text(private_key.rstrip() + "\n", encoding="utf-8")
        key_path.chmod(stat.S_IRUSR | stat.S_IWUSR)

    print(f"Wrote {len(keys)} Linux SSH key file(s) to {output_dir}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
