import jpeg from "npm:jpeg-js@0.4";

/**
 * Decodes a JPEG to raw pixels and encodes it again, so EXIF, GPS and every
 * other metadata segment are gone, whatever the client sent.
 */
export function sanitizePhoto(input: Uint8Array): Uint8Array {
  if (input.length < 3 || input[0] !== 0xff || input[1] !== 0xd8) {
    throw new Error("not a jpeg");
  }
  const decoded = jpeg.decode(input, {
    useTArray: true,
    maxResolutionInMP: 4,
    maxMemoryUsageInMB: 128,
  });
  // Only the pixels: jpeg-js writes back any exifBuffer or comments it is given.
  const { data, width, height } = decoded;
  return new Uint8Array(jpeg.encode({ data, width, height }, 75).data);
}
