import { after, before, beforeEach, describe, test } from 'node:test';

import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  deleteDoc,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
} from 'firebase/firestore';

import {
  CUSTOMER,
  OWNER,
  RIVAL_OWNER,
  business,
  createTestEnv,
  dbAs,
  hoursFromNow,
  listing,
  seed,
  signedOutDb,
} from './helpers.js';

let env;

before(async () => {
  env = await createTestEnv('businesses');
});

beforeEach(async () => {
  await env.clearFirestore();
  await seed(env, {
    'businesses/biz1': business(OWNER),
    'businesses/biz2': business(RIVAL_OWNER),
    'listings/listing1': listing('biz1'),
  });
});

after(async () => {
  await env.cleanup();
});

describe('businesses', () => {
  test('signed-in users can see businesses, signed-out users cannot', async () => {
    await assertSucceeds(getDoc(doc(dbAs(env, CUSTOMER), 'businesses/biz1')));
    await assertFails(getDoc(doc(signedOutDb(env), 'businesses/biz1')));
  });

  test('a user sets up a business for themselves', async () => {
    const db = dbAs(env, CUSTOMER);
    await assertSucceeds(
      setDoc(
        doc(db, 'businesses/newBiz'),
        business(CUSTOMER, { createdAt: serverTimestamp() }),
      ),
    );
  });

  test('a business cannot be set up in someone else\'s name', async () => {
    const db = dbAs(env, CUSTOMER);
    await assertFails(
      setDoc(
        doc(db, 'businesses/newBiz'),
        business(OWNER, { createdAt: serverTimestamp() }),
      ),
    );
  });

  test('only the owner edits their business', async () => {
    await assertSucceeds(
      updateDoc(doc(dbAs(env, OWNER), 'businesses/biz1'), {
        acceptingOrders: false,
      }),
    );
    await assertFails(
      updateDoc(doc(dbAs(env, RIVAL_OWNER), 'businesses/biz1'), {
        acceptingOrders: false,
      }),
    );
  });

  test('a business cannot be handed to another owner', async () => {
    await assertFails(
      updateDoc(doc(dbAs(env, OWNER), 'businesses/biz1'), {
        ownerId: CUSTOMER,
      }),
    );
  });
});

describe('listings', () => {
  const newListing = (businessId, overrides = {}) =>
    listing(businessId, { createdAt: serverTimestamp(), ...overrides });

  test('the owner posts a listing for their business', async () => {
    const db = dbAs(env, OWNER);
    await assertSucceeds(setDoc(doc(db, 'listings/new'), newListing('biz1')));
  });

  test('nobody posts a listing for a business they do not own', async () => {
    const db = dbAs(env, RIVAL_OWNER);
    await assertFails(setDoc(doc(db, 'listings/new'), newListing('biz1')));
  });

  test('the discount price must be lower than the original', async () => {
    const db = dbAs(env, OWNER);
    await assertFails(
      setDoc(
        doc(db, 'listings/new'),
        newListing('biz1', { discountPrice: 3000 }),
      ),
    );
  });

  test('signed-out users cannot browse listings', async () => {
    await assertFails(getDoc(doc(signedOutDb(env), 'listings/listing1')));
  });

  test('a customer cannot change a listing\'s price', async () => {
    await assertFails(
      updateDoc(doc(dbAs(env, CUSTOMER), 'listings/listing1'), {
        discountPrice: 1,
      }),
    );
  });

  describe('stock changes from orders', () => {
    const asCustomer = (changes) =>
      updateDoc(doc(dbAs(env, CUSTOMER), 'listings/listing1'), changes);

    test('an order takes stock from a listing on sale', async () => {
      await assertSucceeds(asCustomer({ quantity: 3 }));
      await assertSucceeds(asCustomer({ quantity: 0, status: 'soldOut' }));
    });

    test('stock cannot be taken from an expired listing', async () => {
      await seed(env, {
        'listings/listing1': listing('biz1', { status: 'expired' }),
      });
      await assertFails(asCustomer({ quantity: 3, status: 'active' }));
    });

    test('stock cannot be taken after the pick-up time', async () => {
      await seed(env, {
        'listings/listing1': listing('biz1', { pickupBy: hoursFromNow(-1) }),
      });
      await assertFails(asCustomer({ quantity: 3 }));
    });

    test('a cancel puts a sold-out listing back on sale', async () => {
      await seed(env, {
        'listings/listing1': listing('biz1', {
          quantity: 0,
          status: 'soldOut',
        }),
      });
      await assertSucceeds(asCustomer({ quantity: 2, status: 'active' }));
    });

    // Mirrors cancelOrder after the pick-up time: stock goes back but the
    // status is left alone.
    test('a late cancel puts stock back without reviving the listing', async () => {
      await seed(env, {
        'listings/listing1': listing('biz1', {
          quantity: 0,
          status: 'soldOut',
          pickupBy: hoursFromNow(-1),
        }),
      });
      await assertSucceeds(asCustomer({ quantity: 2 }));
      await assertFails(asCustomer({ quantity: 4, status: 'active' }));
    });

    test('adding stock cannot revive an expired listing', async () => {
      await seed(env, {
        'listings/listing1': listing('biz1', { status: 'expired' }),
      });
      await assertFails(asCustomer({ quantity: 9, status: 'active' }));
    });

    test('the status cannot change without stock moving', async () => {
      await assertFails(asCustomer({ status: 'soldOut' }));
    });
  });

  test('only the owner deletes a listing', async () => {
    await assertFails(
      deleteDoc(doc(dbAs(env, RIVAL_OWNER), 'listings/listing1')),
    );
    await assertSucceeds(deleteDoc(doc(dbAs(env, OWNER), 'listings/listing1')));
  });
});
