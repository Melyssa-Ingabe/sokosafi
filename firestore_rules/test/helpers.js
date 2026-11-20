import { readFileSync } from 'node:fs';

import { initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { Timestamp, doc, setDoc } from 'firebase/firestore';

const rules = readFileSync(
  new URL('../../firestore.rules', import.meta.url),
  'utf8',
);

const HOUR_MS = 60 * 60 * 1000;

export const CUSTOMER = 'alice';
export const STRANGER = 'bob';
export const OWNER = 'owner';
export const RIVAL_OWNER = 'rival';

// Node runs each test file in its own process at the same time, so every
// file gets its own emulator project and never sees another file's data.
export function createTestEnv(name) {
  return initializeTestEnvironment({
    projectId: `demo-sokosafi-${name}`,
    firestore: { rules },
  });
}

export function hoursFromNow(hours) {
  return Timestamp.fromMillis(Date.now() + hours * HOUR_MS);
}

export function business(ownerId, overrides = {}) {
  return {
    ownerId,
    name: 'Kigali Bakes',
    type: 'bakery',
    address: 'KG 11 Ave',
    lat: -1.95,
    lng: 30.06,
    photoUrl: '',
    acceptingOrders: true,
    pickupStart: '17:00',
    pickupEnd: '20:00',
    autoClose: true,
    createdAt: hoursFromNow(-48),
    ...overrides,
  };
}

export function listing(businessId, overrides = {}) {
  return {
    businessId,
    title: 'Day-old croissants',
    description: 'Six butter croissants',
    category: 'bakery',
    originalPrice: 3000,
    discountPrice: 1500,
    quantity: 5,
    madeAt: hoursFromNow(-3),
    pickupBy: hoursFromNow(3),
    imageUrl: '',
    instructions: 'Ask at the counter',
    status: 'active',
    createdAt: hoursFromNow(-3),
    ...overrides,
  };
}

export function order(overrides = {}) {
  return {
    customerId: CUSTOMER,
    businessId: 'biz1',
    listingId: 'listing1',
    quantity: 2,
    total: 3000,
    pickupCode: 'SKS-4A7F2B',
    paymentMethod: 'mtnMomo',
    status: 'paid',
    createdAt: hoursFromNow(-1),
    collectedAt: null,
    ...overrides,
  };
}

// Writes test data with the rules switched off, the way the Firebase
// console would.
export async function seed(env, documents) {
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    for (const [path, data] of Object.entries(documents)) {
      await setDoc(doc(db, path), data);
    }
  });
}

// The two businesses, one listing and one paid order most tests start from.
export function seedMarketplace(env) {
  return seed(env, {
    'businesses/biz1': business(OWNER),
    'businesses/biz2': business(RIVAL_OWNER, { name: 'Rival Cafe' }),
    'listings/listing1': listing('biz1'),
    'orders/order1': order(),
  });
}

export function dbAs(env, uid) {
  return env.authenticatedContext(uid).firestore();
}

export function signedOutDb(env) {
  return env.unauthenticatedContext().firestore();
}
