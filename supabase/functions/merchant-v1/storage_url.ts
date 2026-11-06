/** Storage signs the path; replacing the internal gateway origin preserves it. */
export function publicStorageUrl(signedUrl: string, internalUrl: string, publicUrl: string): string {
  const result = new URL(signedUrl);
  if (result.origin === new URL(internalUrl).origin) {
    const external = new URL(publicUrl);
    result.protocol = external.protocol;
    result.hostname = external.hostname;
    result.port = external.port;
  }
  return result.toString();
}
