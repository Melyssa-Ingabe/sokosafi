# SokoSafi database (ERD)


Cloud Firestore, six collections. Field names below are exactly the names
stored in Firestore. Every primary key is the document id, not a field.

```mermaid
erDiagram
    USERS ||--o| BUSINESSES : "owns"
    BUSINESSES ||--o{ LISTINGS : "offers"
    LISTINGS ||--o{ ORDERS : "is ordered in"
    USERS ||--o{ ORDERS : "places"
    BUSINESSES ||--o{ ORDERS : "receives"
    ORDERS ||--o| REVIEWS : "is reviewed in"
    USERS ||--o{ REVIEWS : "writes"
    BUSINESSES ||--o{ REVIEWS : "receives"
    USERS ||--o{ SAVED_MERCHANTS : "saves"
    BUSINESSES ||--o{ SAVED_MERCHANTS : "is saved as"

    USERS {
        string uid PK "Firebase Auth uid"
        string name
        string email
        string phone
        string role "customer or business"
        array foodPreferences "list of category names"
        string photoUrl
        timestamp createdAt
    }

    BUSINESSES {
        string businessId PK
        string ownerId FK "users.uid"
        string name
        string type "bakery, restaurant, cafe, supermarket, hotel, cafeteria, grocery, catering"
        string address
        number lat
        number lng
        string photoUrl
        boolean acceptingOrders
        string pickupStart "HH:mm"
        string pickupEnd "HH:mm"
        boolean autoClose
        string landmark "optional pickup guide, max 120 chars"
        timestamp createdAt
    }

    LISTINGS {
        string listingId PK
        string businessId FK "businesses.businessId"
        string title
        string description
        string category "bakery, meals, cafe, grocery"
        int originalPrice "RWF"
        int discountPrice "RWF, lower than originalPrice"
        int quantity "items left"
        timestamp madeAt
        timestamp pickupBy
        string imageUrl
        string instructions
        string status "active, soldOut, expired; soldOut set by the order transaction at 0"
        timestamp createdAt
    }

    ORDERS {
        string orderId PK
        string customerId FK "users.uid"
        string businessId FK "businesses.businessId"
        string listingId FK "listings.listingId"
        int quantity
        int total "RWF, discountPrice x quantity"
        string pickupCode
        string paymentMethod "mtnMomo or airtelMoney"
        string status "paid, collected, cancelled"
        timestamp createdAt
        timestamp collectedAt "null until picked up"
    }

    REVIEWS {
        string reviewId PK
        string orderId FK "orders.orderId"
        string customerId FK "users.uid"
        string businessId FK "businesses.businessId"
        int rating "1 to 5"
        string comment
        timestamp createdAt
    }

    SAVED_MERCHANTS {
        string businessId PK "and FK to businesses; doc id"
        timestamp savedAt
    }
```

`SAVED_MERCHANTS` is the subcollection `users/{uid}/savedMerchants`, so each
saved merchant belongs to the user whose document it sits under.

## Relationships

| From | To | Cardinality | Stored as |
|---|---|---|---|
| users | businesses | one user owns zero or one business | `businesses.ownerId` |
| businesses | listings | one business has many listings | `listings.businessId` |
| listings | orders | one listing has many orders | `orders.listingId` |
| users | orders | one customer places many orders | `orders.customerId` |
| businesses | orders | one business receives many orders | `orders.businessId` |
| orders | reviews | one order has zero or one review | `reviews.orderId` |
| users | reviews | one customer writes many reviews | `reviews.customerId` |
| businesses | reviews | one business receives many reviews | `reviews.businessId` |
| users | savedMerchants | one user saves many businesses | subcollection path |

## No duplicated data

- A listing stores only `businessId`; the business name, address and photo
  are read from `businesses`.
- Dashboard numbers, analytics and profile stats (orders today, revenue,
  food rescued, average rating) are calculated from `orders` and `reviews`
  when shown, never stored as totals.
- `orders.businessId` is the one deliberate exception to "only store what
  you cannot look up": it is a foreign key (an id, not a copy of business
  data) so a business can query its orders without reading every listing,
  and so security rules can check ownership directly.
- The users `role` only decides which screens open. Ownership of a business
  is always checked against `businesses.ownerId`.

## Indexes

Listed in `firestore.indexes.json`.

| Collection | Fields | Used by |
|---|---|---|
| listings | businessId asc, createdAt desc | My listings |
