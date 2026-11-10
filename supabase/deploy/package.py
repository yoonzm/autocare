"""Build the same backend artifact for a manual deployment and GitHub Actions."""
import io
import hashlib
import json
import re
import sys
import tarfile
from pathlib import Path


def package(revision: str, destination: Path) -> None:
    if not re.fullmatch(r"[0-9a-f]{40}", revision):
        raise ValueError("Expected a full Git commit SHA")
    root = Path(__file__).resolve().parents[2]
    files=[]
    digest=hashlib.sha256()
    for directory in ("supabase/migrations", "supabase/functions/merchant-v1", "supabase/functions/admin-v1", "supabase/functions/member-v1"):
        for path in sorted((root / directory).rglob("*")):
            if path.is_file() and not path.is_symlink() and path.suffix in {".sql", ".ts", ".json", ".jsonc", ".lock"}:
                name=path.relative_to(root).as_posix()
                content=path.read_bytes().replace(b'\r\n',b'\n')
                digest.update(name.encode()+b'\0'+content+b'\0')
                files.append((name,content))
    with tarfile.open(destination, "w:gz") as archive:
        metadata = json.dumps({"revision": revision,"source_sha256":digest.hexdigest()}).encode()
        info = tarfile.TarInfo("release.json")
        info.size = len(metadata)
        archive.addfile(info, io.BytesIO(metadata))
        for name,content in files:
            info = tarfile.TarInfo(name)
            info.size = len(content)
            info.mode = 0o644
            archive.addfile(info, io.BytesIO(content))


if __name__ == "__main__":
    package(sys.argv[1], Path(sys.argv[2]))
