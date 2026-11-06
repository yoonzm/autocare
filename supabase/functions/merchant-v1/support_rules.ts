/** Decode only supported screenshot formats; filenames/MIME supplied by clients are untrusted. */
export function screenshot(
  data: unknown,
): { bytes: Uint8Array; extension: string; mime: string } | null {
  if (typeof data !== "string" || data.length > 6990508) return null;
  let bytes: Uint8Array;
  try {
    bytes = Uint8Array.from(atob(data), (c) => c.charCodeAt(0));
  } catch {
    return null;
  }
  if (bytes.length > 5242880) return null;
  const png = bytes.length >= 24 &&
    [137, 80, 78, 71, 13, 10, 26, 10].every((n, i) => bytes[i] === n) &&
    String.fromCharCode(...bytes.slice(12, 16)) === "IHDR";
  const jpg = bytes.length >= 4 && bytes[0] === 255 && bytes[1] === 216 &&
    bytes[2] === 255;
  return png || jpg
    ? {
      bytes,
      extension: png ? "png" : "jpg",
      mime: png ? "image/png" : "image/jpeg",
    }
    : null;
}
