#!/usr/bin/env python3
"""Collect supported providers independently, without model calls."""
import json
from providers import codex

# Add another provider's collector here when its integration is implemented.
PROVIDERS = (codex,)

if __name__ == "__main__":
    results = []
    for provider in PROVIDERS:
        try:
            results.append(provider.collect())
        except Exception:
            results.append({"id": provider.__name__.split(".")[-1],
                            "status": "error", "error": "Usage reader failed"})
    print(json.dumps({"providers": results}))
