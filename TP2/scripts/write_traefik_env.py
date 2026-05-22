#!/usr/bin/env python3
import json
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "usage: write_traefik_env.py <targets.auto.tfvars.json> <output.env>",
            file=sys.stderr,
        )
        return 2

    config_path = Path(sys.argv[1])
    output_path = Path(sys.argv[2])

    config = json.loads(config_path.read_text(encoding="utf-8"))
    load_balancer = config.get("load_balancer", {})

    http_port = load_balancer.get("http_port", 80)
    dashboard_port = load_balancer.get("dashboard_port", 8088)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        "\n".join(
            [
                f"TP2_TRAEFIK_HTTP_PORT={http_port}",
                f"TP2_TRAEFIK_DASHBOARD_PORT={dashboard_port}",
                "",
            ]
        ),
        encoding="utf-8",
    )

    print(f"Wrote Traefik environment to {output_path}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
