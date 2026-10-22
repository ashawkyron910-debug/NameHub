#!/usr/bin/env python3
"""Pack NameHub Lua sources for public release (not readable plain source)."""

from __future__ import annotations

import base64
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source"
OUTPUTS: tuple[tuple[str, str], ...] = (
    ("script.lua", "script.lua"),
    ("dahood/script.lua", "dahood/script.lua"),
    ("dinosim/script.lua", "dinosim/script.lua"),
    ("rivals/script.lua", "rivals/script.lua"),
    ("animeastral/commandments.lua", "animeastral/commandments.lua"),
    ("premium/script.lua", "premium/script.lua"),
)

DEFAULT_KEY = "NameHub-2026"


def pack_key() -> str:
    return os.environ.get("NAMEHUB_PACK_KEY", DEFAULT_KEY).strip() or DEFAULT_KEY


def xor_bytes(data: bytes, key: str) -> bytes:
    kb = key.encode("utf-8")
    if not kb:
        raise ValueError("pack key is empty")
    return bytes(b ^ kb[i % len(kb)] for i, b in enumerate(data))


def chunk_string(text: str, size: int = 4000) -> list[str]:
    return [text[i : i + size] for i in range(0, len(text), size)]


def lua_string_literal(text: str) -> str:
    return '"' + text.replace("\\", "\\\\").replace('"', '\\"') + '"'


def build_stub(encoded: str, key: str) -> str:
    parts = chunk_string(encoded)
    part_literals = ",\n  ".join(lua_string_literal(p) for p in parts)
    key_lit = lua_string_literal(key)
    return f"""-- NameHub protected build (do not edit)
warn("[NameHub] starting")
return (function(K)
  local bxor = (bit32 and bit32.bxor) or (bit and bit.bxor)
  if not bxor then
    function bxor(a, b)
      local r, p = 0, 1
      for _ = 1, 8 do
        if a % 2 ~= b % 2 then
          r = r + p
        end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        p = p * 2
      end
      return r
    end
  end
  local function xor_bytes(data, key)
    local out = {{}}
    local klen = #key
    for i = 1, #data do
      local b = string.byte(data, i)
      local kb = string.byte(key, ((i - 1) % klen) + 1)
      out[i] = string.char(bxor(b, kb))
    end
    return table.concat(out)
  end
  local function b64decode(data)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local map = {{}}
    for i = 1, #chars do
      map[string.sub(chars, i, i)] = i - 1
    end
    data = string.gsub(data, "%s", "")
    local out = {{}}
    local n = 1
    for i = 1, #data, 4 do
      local a = map[string.sub(data, i, i)] or 0
      local b = map[string.sub(data, i + 1, i + 1)] or 0
      local cch = string.sub(data, i + 2, i + 2)
      local dch = string.sub(data, i + 3, i + 3)
      local c = map[cch]
      local d = map[dch]
      local triple = a * 262144 + b * 4096 + (c or 0) * 64 + (d or 0)
      out[n] = string.char(math.floor(triple / 65536) % 256)
      n = n + 1
      if cch ~= "=" and c ~= nil then
        out[n] = string.char(math.floor(triple / 256) % 256)
        n = n + 1
      end
      if dch ~= "=" and d ~= nil then
        out[n] = string.char(triple % 256)
        n = n + 1
      end
    end
    return table.concat(out)
  end
  local b64 = table.concat({{
  {part_literals}
  }})
  local ok, err = pcall(function()
    local raw = b64decode(b64)
    local src = xor_bytes(raw, K)
    local loader = loadstring or load
    if type(loader) ~= "function" then
      error("loadstring is missing")
    end
    local fn, loadErr = loader(src)
    if not fn then
      error(tostring(loadErr))
    end
    fn()
  end)
  if not ok then
    warn("[NameHub] load failed: " .. tostring(err))
  end
end)({key_lit})
"""


def pack_file(source_path: Path, dest_path: Path, key: str) -> None:
    source = source_path.read_text(encoding="utf-8")
    payload = xor_bytes(source.encode("utf-8"), key)
    encoded = base64.b64encode(payload).decode("ascii")
    stub = build_stub(encoded, key)
    dest_path.parent.mkdir(parents=True, exist_ok=True)
    dest_path.write_text(stub, encoding="utf-8")
    print(
        f"packed {source_path.relative_to(ROOT)} -> {dest_path.relative_to(ROOT)} "
        f"({len(source.encode('utf-8'))} -> {len(stub.encode('utf-8'))} bytes)",
        flush=True,
    )


def main() -> int:
    key = pack_key()
    missing: list[str] = []
    packed = 0
    for rel_src, rel_out in OUTPUTS:
        src = SOURCE / rel_src
        if not src.is_file():
            missing.append(rel_src)
            continue
        pack_file(src, ROOT / rel_out, key)
        packed += 1
    if missing:
        print("Skipping missing source files:", ", ".join(missing), file=sys.stderr)
    if packed == 0:
        print("No source files to pack", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
