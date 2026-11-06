"""Build the same backend artifact for a manual deployment and GitHub Actions."""
import io
import json
import re
import sys
import tarfile
from pathlib import Path


def package(revision: str, destination: Path) -> None:
    if not re.fullmatch(r"[0-9a-f]{40}", revision):
        raise ValueError("Expected a full Git commit SHA")
    root = Path(__file__).resolve().parents[2]
    with tarfile.open(destination, "w:gz") as archive:
        metadata = json.dumps({"revision": revision}).encode()
        info = tarfile.TarInfo("release.json")
        info.size = len(metadata)
        archive.addfile(info, io.BytesIO(metadata))
        for directory in ("supabase/migrations", "supabase/functions/merchant-v1"):
            for path in sorted((root / directory).rglob("*")):
                if path.is_file() and not path.is_symlink():
                    if path.suffix not in {".sql", ".ts", ".json", ".jsonc", ".lock"}:
                        continue
                    # Windows working trees use CRLF; runner checkouts use LF.
                    # Normalize artifacts so immutable migration checksums agree.
                    content = path.read_bytes().replace(b'\r\n', b'\n')
                    info = tarfile.TarInfo(path.relative_to(root).as_posix())
                    info.size = len(content)
                    info.mode = 0o644
                    archive.addfile(info, io.BytesIO(content))


if __name__ == "__main__":
    package(sys.argv[1], Path(sys.argv[2]))
