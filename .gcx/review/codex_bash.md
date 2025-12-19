Issues found (ordered by risk):
- `factorial` accepts any type; annotations aren’t enforced. Floats/Decimals trigger a `TypeError` in `range`, and `True`/`False` (subclasses of `int`) return `1`, which may be surprising if booleans shouldn’t be accepted (`.gcx/02_implementation/factorial.py:1-13`).
- No upper bound or time/size guard. Very large `n` will allocate and compute unbounded big integers in O(n) time and can be abused for denial-of-service in request/CLI contexts (`.gcx/02_implementation/factorial.py:5-13`).
- Uses custom loop instead of `math.factorial`, forfeiting CPython’s optimized C implementation and its clearer exceptions for bad types/values (`.gcx/02_implementation/factorial.py:5-13`).

Testing gaps to add:
- Negative input raises `ValueError`.
- Non-integer types (float, Decimal, string, bool) produce the intended error path.
- Large `n` guard (if added) enforces the limit.
