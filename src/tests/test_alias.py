from __future__ import annotations

import json
from collections import Counter, defaultdict

from utilities.pathlib import get_repo_root


class TestPythonJSON:
    def test_main(self) -> None:
        path = get_repo_root() / "nvim/snippets/python.json"

        def hook[K, V](pairs: list[tuple[K, V]]) -> dict[K, list[V]]:
            d: defaultdict[K, list[V]] = defaultdict(list)
            for k, v in pairs:
                d[k].append(v)
            return dict(d)

        data = json.loads(path.read_text(), object_pairs_hook=hook)
        # check keys
        counter_keys = {k: len(v) for k, v in data.items()}
        duplicated_keys = {k: v for k, v in counter_keys.items() if v >= 2}
        assert duplicated_keys == {}, list(duplicated_keys)
        # check prefixes
        counter_prefixes: Counter[str] = Counter()
        for value in data.values():
            for value_i in value:
                (prefix,) = value_i["prefix"]
                counter_prefixes[prefix] += 1
        duplicated_prefixes = {k: v for k, v in counter_prefixes.items() if v >= 2}
        assert duplicated_prefixes == {}, list(duplicated_prefixes)
