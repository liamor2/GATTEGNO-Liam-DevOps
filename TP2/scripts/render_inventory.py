#!/usr/bin/env python3
import json
import sys
from pathlib import Path

from jinja2 import Environment, FileSystemLoader, StrictUndefined


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "usage: render_inventory.py <targets.json> <inventory.yml.j2> <output.yml>",
            file=sys.stderr,
        )
        return 2

    targets_path = Path(sys.argv[1])
    template_path = Path(sys.argv[2])
    output_path = Path(sys.argv[3])

    metadata = json.loads(targets_path.read_text(encoding="utf-8"))
    env = Environment(
        loader=FileSystemLoader(str(template_path.parent)),
        undefined=StrictUndefined,
        trim_blocks=True,
        lstrip_blocks=True,
    )
    template = env.get_template(template_path.name)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(template.render(**metadata), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
