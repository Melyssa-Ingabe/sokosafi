import { createRemoteJWKSet, jwtVerify } from 'jose';

// Google's public keys for Firebase ID tokens. jose caches them and only
// refetches when a token uses a key it has not seen.
const firebaseKeys = createRemoteJWKSet(
  new URL(
    'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com',
  ),
);

export const MAX_BYTES = 5 * 1024 * 1024;

const EXTENSIONS = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
};

// businesses, listings or profile, optionally followed by one id segment.
const FOLDER_PATTERN = /^(businesses|listings|profile)(\/[A-Za-z0-9_-]{1,128})?$/;

export default {
  fetch: (request, env) =>
    handleRequest(request, env, (token) => verifyFirebaseToken(token, env)),
};

/**
 * The app never holds R2 keys. It sends the photo with the user's Firebase
 * ID token, and the photo is saved under uploads/{uid}/, so a user can only
 * ever add files to their own folder and never overwrite or delete anyone's.
 */
export async function handleRequest(request, env, verifyToken) {
  const url = new URL(request.url);
  if (url.pathname !== '/upload') {
    return json({ error: 'Not found' }, 404);
  }
  if (request.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405);
  }

  const uid = await uidFrom(request, verifyToken);
  if (!uid) {
    return json({ error: 'Please sign in again' }, 401);
  }

  const folder = url.searchParams.get('folder') ?? '';
  if (!FOLDER_PATTERN.test(folder)) {
    return json({ error: 'Unknown folder' }, 400);
  }

  if (Number(request.headers.get('content-length') ?? 0) > MAX_BYTES) {
    return json({ error: 'Photo is larger than 5 MB' }, 413);
  }
  const bytes = new Uint8Array(await request.arrayBuffer());
  if (bytes.length === 0 || bytes.length > MAX_BYTES) {
    return json({ error: 'Photo is empty or larger than 5 MB' }, 413);
  }
  // The type comes from the file's own first bytes, never from its name or
  // the client's header: phones often keep a .webp name on a file they
  // re-saved as JPG.
  const contentType = detectImageType(bytes);
  if (!contentType) {
    return json({ error: 'Only JPG, PNG and WebP photos are allowed' }, 415);
  }
  const extension = EXTENSIONS[contentType];

  const key = `uploads/${uid}/${folder}/${crypto.randomUUID()}.${extension}`;
  await env.IMAGES.put(key, bytes, {
    httpMetadata: {
      contentType,
      // Every upload gets a new name, so a cached copy never goes stale.
      cacheControl: 'public, max-age=31536000, immutable',
    },
  });
  return json({ url: `${env.PUBLIC_BASE_URL}/${key}` }, 201);
}

async function uidFrom(request, verifyToken) {
  const header = request.headers.get('authorization') ?? '';
  if (!header.startsWith('Bearer ')) return null;
  try {
    const uid = await verifyToken(header.slice('Bearer '.length));
    return typeof uid === 'string' && /^[A-Za-z0-9_-]{1,128}$/.test(uid)
      ? uid
      : null;
  } catch {
    return null;
  }
}

async function verifyFirebaseToken(token, env) {
  const projectId = env.FIREBASE_PROJECT_ID;
  const { payload } = await jwtVerify(token, firebaseKeys, {
    issuer: `https://securetoken.google.com/${projectId}`,
    audience: projectId,
    algorithms: ['RS256'],
  });
  return payload.sub;
}

export function detectImageType(bytes) {
  const startsWith = (signature, offset = 0) =>
    signature.every((byte, index) => bytes[offset + index] === byte);
  if (startsWith([0xff, 0xd8, 0xff])) return 'image/jpeg';
  if (startsWith([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])) {
    return 'image/png';
  }
  // "RIFF", four size bytes, then "WEBP".
  if (
    startsWith([0x52, 0x49, 0x46, 0x46]) &&
    startsWith([0x57, 0x45, 0x42, 0x50], 8)
  ) {
    return 'image/webp';
  }
  return null;
}

function json(body, status) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json' },
  });
}
