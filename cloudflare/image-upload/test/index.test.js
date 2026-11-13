import assert from 'node:assert/strict';
import { test } from 'node:test';

import { MAX_BYTES, handleRequest } from '../src/index.js';

const JPEG = new Uint8Array([0xff, 0xd8, 0xff, 0xe0, 0x00, 0x10]);
const PNG = new Uint8Array([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00]);

function fakeEnv() {
  const saved = [];
  return {
    saved,
    PUBLIC_BASE_URL: 'https://pub-test.r2.dev',
    IMAGES: {
      put: async (key, bytes, options) => saved.push({ key, bytes, options }),
    },
  };
}

const acceptToken = async (token) => {
  if (token !== 'good-token') throw new Error('bad token');
  return 'user123';
};

function upload({
  folder = 'listings/biz1',
  token = 'good-token',
  type = 'image/jpeg',
  body = JPEG,
  method = 'POST',
  path = '/upload',
} = {}) {
  const headers = { 'content-type': type };
  if (token) headers.authorization = `Bearer ${token}`;
  return new Request(
    `https://worker.test${path}?folder=${encodeURIComponent(folder)}`,
    { method, headers, body: method === 'POST' ? body : undefined },
  );
}

test('saves a valid photo under the signed-in user folder', async () => {
  const env = fakeEnv();
  const response = await handleRequest(upload(), env, acceptToken);

  assert.equal(response.status, 201);
  assert.equal(env.saved.length, 1);
  const { key, options } = env.saved[0];
  assert.match(key, /^uploads\/user123\/listings\/biz1\/[0-9a-f-]{36}\.jpg$/);
  assert.equal(options.httpMetadata.contentType, 'image/jpeg');
  const { url } = await response.json();
  assert.equal(url, `https://pub-test.r2.dev/${key}`);
});

test('accepts png photos', async () => {
  const env = fakeEnv();
  const response = await handleRequest(
    upload({ type: 'image/png', body: PNG, folder: 'businesses' }),
    env,
    acceptToken,
  );
  assert.equal(response.status, 201);
  assert.match(env.saved[0].key, /^uploads\/user123\/businesses\/.+\.png$/);
});

test('refuses a missing or invalid token', async () => {
  for (const token of [null, 'forged']) {
    const env = fakeEnv();
    const response = await handleRequest(upload({ token }), env, acceptToken);
    assert.equal(response.status, 401);
    assert.equal(env.saved.length, 0);
  }
});

test('refuses folders that could escape the user folder', async () => {
  for (const folder of ['', '../other', 'listings/../../x', 'orders', 'listings/a/b']) {
    const env = fakeEnv();
    const response = await handleRequest(upload({ folder }), env, acceptToken);
    assert.equal(response.status, 400, folder);
    assert.equal(env.saved.length, 0);
  }
});

test('uses the real file type, not the declared one', async () => {
  const env = fakeEnv();
  const response = await handleRequest(
    upload({ type: 'image/webp', body: JPEG }),
    env,
    acceptToken,
  );
  assert.equal(response.status, 201);
  assert.match(env.saved[0].key, /\.jpg$/);
  assert.equal(env.saved[0].options.httpMetadata.contentType, 'image/jpeg');
});

test('refuses files that are not real photos', async () => {
  const env = fakeEnv();
  const html = new TextEncoder().encode('<html><script>x</script></html>');
  const response = await handleRequest(
    upload({ type: 'image/jpeg', body: html }),
    env,
    acceptToken,
  );
  assert.equal(response.status, 415);
  assert.equal(env.saved.length, 0);
});

test('refuses photos larger than 5 MB', async () => {
  const env = fakeEnv();
  const big = new Uint8Array(MAX_BYTES + 1);
  big.set(JPEG);
  const response = await handleRequest(upload({ body: big }), env, acceptToken);
  assert.equal(response.status, 413);
  assert.equal(env.saved.length, 0);
});

test('only answers POST /upload', async () => {
  const env = fakeEnv();
  assert.equal((await handleRequest(upload({ method: 'GET' }), env, acceptToken)).status, 405);
  assert.equal((await handleRequest(upload({ path: '/other' }), env, acceptToken)).status, 404);
});
