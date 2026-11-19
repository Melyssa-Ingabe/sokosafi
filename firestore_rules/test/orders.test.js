import { after, before, beforeEach, describe, test } from 'node:test';

import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  orderBy,
  query,
  serverTimestamp,
  updateDoc,
  where,
  writeBatch,
} from 'firebase/firestore';

import {
  CUSTOMER,
  OWNER,
  RIVAL_OWNER,
  STRANGER,
  createTestEnv,
  dbAs,
  hoursFromNow,
  listing,
  order,
  seed,
  seedMarketplace,
  signedOutDb,
} from './helpers.js';

let env;

before(async () => {
  env = await createTestEnv('orders');
});

beforeEach(async () => {
  await env.clearFirestore();
  await seedMarketplace(env);
});

after(async () => {
  await env.cleanup();
});

// Mirrors placeOrder in FirestoreOrdersRepository: the listing's stock goes
// down and the order is created in the same write.
function placeOrder(db, { quantity = 2, stockLeft = 3, ...fields } = {}) {
  const batch = writeBatch(db);
  batch.update(doc(db, 'listings/listing1'), {
    quantity: stockLeft,
    ...(stockLeft === 0 ? { status: 'soldOut' } : {}),
  });
  batch.set(
    doc(db, 'orders/newOrder'),
    order({
      quantity,
      total: 1500 * quantity,
      createdAt: serverTimestamp(),
      ...fields,
    }),
  );
  return batch.commit();
}

describe('placing an order', () => {
  test('a customer can order and take the items out of stock', async () => {
    await assertSucceeds(placeOrder(dbAs(env, CUSTOMER)));
  });

  test('buying the last items marks the listing sold out', async () => {
    await assertSucceeds(
      placeOrder(dbAs(env, CUSTOMER), { quantity: 5, stockLeft: 0 }),
    );
  });

  test('an order that leaves the stock unchanged is refused', async () => {
    await assertFails(placeOrder(dbAs(env, CUSTOMER), { stockLeft: 5 }));
  });

  test('an order with a made-up total is refused', async () => {
    await assertFails(placeOrder(dbAs(env, CUSTOMER), { total: 100 }));
  });

  test('an order cannot be placed in someone else\'s name', async () => {
    await assertFails(
      placeOrder(dbAs(env, CUSTOMER), { customerId: STRANGER }),
    );
  });

  test('an order cannot point at a different business', async () => {
    await assertFails(placeOrder(dbAs(env, CUSTOMER), { businessId: 'biz2' }));
  });

  test('an order cannot start as collected', async () => {
    await assertFails(
      placeOrder(dbAs(env, CUSTOMER), {
        status: 'collected',
        collectedAt: serverTimestamp(),
      }),
    );
  });

  test('an order with a badly formed pickup code is refused', async () => {
    await assertFails(
      placeOrder(dbAs(env, CUSTOMER), { pickupCode: 'SKS-000000' }),
    );
  });

  test('food past its pick-up time cannot be ordered', async () => {
    await seed(env, {
      'listings/listing1': listing('biz1', { pickupBy: hoursFromNow(-1) }),
    });
    await assertFails(placeOrder(dbAs(env, CUSTOMER)));
  });

  test('signed-out users cannot order', async () => {
    await assertFails(placeOrder(signedOutDb(env)));
  });
});

describe('reading orders', () => {
  test('the customer reads their own order', async () => {
    await assertSucceeds(getDoc(doc(dbAs(env, CUSTOMER), 'orders/order1')));
  });

  test('the business that received the order reads it', async () => {
    await assertSucceeds(getDoc(doc(dbAs(env, OWNER), 'orders/order1')));
  });

  test('another customer cannot read it', async () => {
    await assertFails(getDoc(doc(dbAs(env, STRANGER), 'orders/order1')));
  });

  test('another business cannot read it', async () => {
    await assertFails(getDoc(doc(dbAs(env, RIVAL_OWNER), 'orders/order1')));
  });

  test('signed-out users cannot read it', async () => {
    await assertFails(getDoc(doc(signedOutDb(env), 'orders/order1')));
  });
});

// Rules are not filters: a query is only allowed when every document it
// could return is readable. These are the queries the app runs.
describe('order queries used by the app', () => {
  test('My Orders: a customer lists their own orders', async () => {
    const db = dbAs(env, CUSTOMER);
    await assertSucceeds(
      getDocs(
        query(
          collection(db, 'orders'),
          where('customerId', '==', CUSTOMER),
          orderBy('createdAt', 'desc'),
        ),
      ),
    );
  });

  test('Business Orders: an owner lists their business\'s orders', async () => {
    const db = dbAs(env, OWNER);
    await assertSucceeds(
      getDocs(
        query(
          collection(db, 'orders'),
          where('businessId', '==', 'biz1'),
          orderBy('createdAt', 'desc'),
        ),
      ),
    );
  });

  test('a business cannot list another business\'s orders', async () => {
    const db = dbAs(env, RIVAL_OWNER);
    await assertFails(
      getDocs(query(collection(db, 'orders'), where('businessId', '==', 'biz1'))),
    );
  });

  test('nobody can list every order', async () => {
    await assertFails(getDocs(collection(dbAs(env, OWNER), 'orders')));
  });
});

describe('cancelling an order', () => {
  test('the customer cancels their own paid order', async () => {
    const db = dbAs(env, CUSTOMER);
    await assertSucceeds(
      updateDoc(doc(db, 'orders/order1'), { status: 'cancelled' }),
    );
  });

  // Mirrors cancelOrder in FirestoreOrdersRepository, which puts the items
  // back in the same transaction.
  test('cancelling puts the items back on the listing', async () => {
    const db = dbAs(env, CUSTOMER);
    const batch = writeBatch(db);
    batch.update(doc(db, 'orders/order1'), { status: 'cancelled' });
    batch.update(doc(db, 'listings/listing1'), { quantity: 7 });
    await assertSucceeds(batch.commit());
  });

  test('another customer cannot cancel it', async () => {
    const db = dbAs(env, STRANGER);
    await assertFails(
      updateDoc(doc(db, 'orders/order1'), { status: 'cancelled' }),
    );
  });

  test('a collected order cannot be cancelled', async () => {
    await seed(env, { 'orders/order1': order({ status: 'collected' }) });
    const db = dbAs(env, CUSTOMER);
    await assertFails(
      updateDoc(doc(db, 'orders/order1'), { status: 'cancelled' }),
    );
  });

  test('cancelling cannot also change the total', async () => {
    const db = dbAs(env, CUSTOMER);
    await assertFails(
      updateDoc(doc(db, 'orders/order1'), { status: 'cancelled', total: 1 }),
    );
  });
});

describe('confirming a pickup', () => {
  const collect = (db) =>
    updateDoc(doc(db, 'orders/order1'), {
      status: 'collected',
      collectedAt: serverTimestamp(),
    });

  test('the business that received the order marks it collected', async () => {
    await assertSucceeds(collect(dbAs(env, OWNER)));
  });

  test('a customer cannot mark an order collected', async () => {
    await assertFails(collect(dbAs(env, CUSTOMER)));
  });

  test('a signed-in stranger cannot mark an order collected', async () => {
    await assertFails(collect(dbAs(env, STRANGER)));
  });

  test('another business cannot mark it collected', async () => {
    await assertFails(collect(dbAs(env, RIVAL_OWNER)));
  });

  test('a cancelled order cannot be collected', async () => {
    await seed(env, { 'orders/order1': order({ status: 'cancelled' }) });
    await assertFails(collect(dbAs(env, OWNER)));
  });

  test('the pickup time must be the server\'s time', async () => {
    const db = dbAs(env, OWNER);
    await assertFails(
      updateDoc(doc(db, 'orders/order1'), {
        status: 'collected',
        collectedAt: hoursFromNow(-5),
      }),
    );
  });
});

test('nobody can delete an order', async () => {
  await assertFails(deleteDoc(doc(dbAs(env, CUSTOMER), 'orders/order1')));
  await assertFails(deleteDoc(doc(dbAs(env, OWNER), 'orders/order1')));
});
