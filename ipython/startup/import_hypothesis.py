from __future__ import annotations

from contextlib import suppress

with suppress(ModuleNotFoundError):
    import hypothesis
    import hypothesis.strategies  # noqa: F401
    from hypothesis import (  # noqa: F401
        HealthCheck,
        Phase,
        Verbosity,
        assume,
        currently_in_test_context,
        event,
        example,
        find,
        given,
        infer,
        note,
        register_random,
        reject,
        reproduce_failure,
        seed,
        settings,
        target,
    )
    from hypothesis.strategies import (  # noqa: F401
        DataObject,
        DrawFn,
        binary,
        booleans,
        builds,
        characters,
        complex_numbers,
        composite,
        dates,
        datetimes,
        decimals,
        deferred,
        dictionaries,
        emails,
        fixed_dictionaries,
        floats,
        fractions,
        from_regex,
        from_type,
        frozensets,
        functions,
        integers,
        ip_addresses,
        iterables,
        just,
        lists,
        none,
        nothing,
        one_of,
        permutations,
        random_module,
        randoms,
        recursive,
        register_type_strategy,
        runner,
        sampled_from,
        sets,
        shared,
        slices,
        text,
        timedeltas,
        times,
        timezone_keys,
        timezones,
        tuples,
        uuids,
    )

    with suppress(ModuleNotFoundError):
        from hypothesis.extra.numpy import (  # noqa: F401
            BroadcastableShapes,
            array_dtypes,
            array_shapes,
            arrays,
            basic_indices,
            boolean_dtypes,
            broadcastable_shapes,
            byte_string_dtypes,
            complex_number_dtypes,
            datetime64_dtypes,
            floating_dtypes,
            from_dtype,
            integer_array_indices,
            integer_dtypes,
            mutually_broadcastable_shapes,
            nested_dtypes,
            scalar_dtypes,
            timedelta64_dtypes,
            unicode_string_dtypes,
            unsigned_integer_dtypes,
            valid_tuple_axes,
        )
    with suppress(ModuleNotFoundError):
        from hypothesis.extra.pandas import (  # noqa: F401
            column,
            columns,
            data_frames,
            indexes,
            range_indexes,
            series,
        )
