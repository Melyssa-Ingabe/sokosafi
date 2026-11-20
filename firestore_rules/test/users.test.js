import { after, before, beforeEach, describe, test } from 'node:test';

import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  serverTimestamp,
  setDoc,
  updateDoc,
} from 'firebase/firestore';

import {
  CUSTOMER,
  OWNER,
  STRANGER,
  business,
  createTestEnv,
  dbAs,
  hoursFromNow,
  seed,
  signedOutDb,
} from './helpers.js';

let env;

function profile(overrides = {}) {
  return {
    name: 'Alice',
    email: 'alice@example.com',
    phone: '0788000000',
    role: 'customer',
    foodPreferences: [],
    photoUrl: '',
    createdAt: hoursFromNow(-24),
    ...overrides,
  };
}

before(async () => {
  env = await createTestEnv('users');
});

beforeEach(async () => {
  await env.clearFirestore();
  await seed(env, {
    [`users/${CUSTOMER}`]: profile(),
    'businesses/biz1': business(OWNER),
    [`users/${CUSTOMER}/savedMerchants/biz1`]: { savedAt: hoursFromNow(-1) },
  });
});

after(async () => {
  await env.cleanup();
});

describe('user profiles', () => {
  test('a new user creates their own profile at registration', async () => {
    const db = dbAs(env, STRANGER);
    await assertSucceeds(
      setDoc(
        doc(db, `users/${STRANGER}`),
        profile({ email: 'bob@example.com', createdAt: serverTimestamp() }),
      ),
    );
  });

  test('nobody can create a profile for someone else', async () => {
    const db = dbAs(env, STRANGER);
    await assertFails(
      setDoc(doc(db, 'users/someone'), profile({ createdAt: serverTimestamp() })),
    );
  });

  test('users read their own profile only', async () => {
    await assertSucceeds(getDoc(doc(dbAs(env, CUSTOMER), `users/${CUSTOMER}`)));
    await assertFails(getDoc(doc(dbAs(env, STRANGER), `users/${CUSTOMER}`)));
    await assertFails(getDoc(doc(signedOutDb(env), `users/${CUSTOMER}`)));
  });

  test('the email cannot be changed from the app', async () => {
    const db = dbAs(env, CUSTOMER);
    await assertFails(
      updateDoc(doc(db, `users/${CUSTOMER}`), { email: 'new@example.com' }),
    );
  });
});

describe('food preferences', () => {
  test('a customer saves the categories they like', async () => {
    const db = dbAs(env, CUSTOMER);
    await assertSucceeds(
      updateDoc(doc(db, `users/${CUSTOMER}`), {
        foodPreferences: ['bakery', 'cafe'],
      }),
    );
  });

  test('a customer can clear their preferences', async () => {
    const db = dbAs(env, CUSTOMER);
    await assertSucceeds(
      updateDoc(doc(db, `users/${CUSTOMER}`), { foodPreferences: [] }),
    );
  });

  test('a category the app does not have is refused', async () => {
    const db = dbAs(env, CUSTOMER);
    await assertFails(
      updateDoc(doc(db, `users/${CUSTOMER}`), { foodPreferences: ['pizza'] }),
    );
  });

  test('preferences must be a list', async () => {
    const db = dbAs(env, CUSTOMER);
    await assertFails(
      updateDoc(doc(db, `users/${CUSTOMER}`), { foodPreferences: 'bakery' }),
    );
  });

  test('nobody edits another user\'s preferences', async () => {
    const db = dbAs(env, STRANGER);
    await assertFails(
      updateDoc(doc(db, `users/${CUSTOMER}`), { foodPreferences: ['meals'] }),
    );
  });
});

describe('saved merchants', () => {
  const savedPath = (uid, businessId) =>
    `users/${uid}/savedMerchants/${businessId}`;

  test('a customer saves a business that exists', async () => {
    await seed(env, { 'businesses/biz2': business(STRANGER) });
    const db = dbAs(env, CUSTOMER);
    await assertSucceeds(
      setDoc(doc(db, savedPath(CUSTOMER, 'biz2')), {
        savedAt: serverTimestamp(),
      }),
    );
  });

  test('a business that does not exist cannot be saved', async () => {
    const db = dbAs(env, CUSTOMER);
    await assertFails(
      setDoc(doc(db, savedPath(CUSTOMER, 'ghost')), {
        savedAt: serverTimestamp(),
      }),
    );
  });

  test('only the saved time is stored', async () => {
    await seed(env, { 'businesses/biz2': business(STRANGER) });
    const db = dbAs(env, CUSTOMER);
    await assertFails(
      setDoc(doc(db, savedPath(CUSTOMER, 'biz2')), {
        savedAt: serverTimestamp(),
        name: 'Copied business name',
      }),
    );
  });

  test('nobody adds to another customer\'s list', async () => {
    const db = dbAs(env, STRANGER);
    await assertFails(
      setDoc(doc(db, savedPath(CUSTOMER, 'biz1')), {
        savedAt: serverTimestamp(),
      }),
    );
  });

  test('a customer lists their own saved merchants only', async () => {
    const path = `users/${CUSTOMER}/savedMerchants`;
    await assertSucceeds(getDocs(collection(dbAs(env, CUSTOMER), path)));
    await assertFails(getDocs(collection(dbAs(env, STRANGER), path)));
    await assertFails(getDocs(collection(dbAs(env, OWNER), path)));
  });

  test('a customer removes a saved merchant', async () => {
    const db = dbAs(env, CUSTOMER);
    await assertSucceeds(deleteDoc(doc(db, savedPath(CUSTOMER, 'biz1'))));
  });

  test('nobody removes from another customer\'s list', async () => {
    const db = dbAs(env, STRANGER);
    await assertFails(deleteDoc(doc(db, savedPath(CUSTOMER, 'biz1'))));
  });
});
