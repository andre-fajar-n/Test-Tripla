# Test Tripla
Skill test for Ruby on Rails Engineer at Tripla

# Technical Design - Scalability & Performance Strategies

To ensure the system can efficiently handle a growing user base, large datasets, and high volumes of concurrent requests, several strategies are implemented. Each strategy is chosen to balance performance, scalability, and maintainability.

---

## 1. Database Indexing

**Description:**  
Indexes are added to frequently queried columns such as:
- `sleep_records.user_id`
- `sleep_records.sleep_at`
- `follows.follower_id` and `follows.followed_id`
- Composite index `(user_id, sleep_at)` for feed queries

**Impact:**  
Significantly improves query speed for filtering and joins.

**Trade-offs:**

| Pros                          | Cons                                           |
|-------------------------------|------------------------------------------------|
| Fast SELECT/JOIN operations   | Slightly slower INSERT/UPDATE due to index overhead |
| Efficient filtering and lookup | Additional storage space for index data       |

---

## 2. Query Optimization

**Description:**  
- Use `SELECT` only necessary columns.
- Avoid N+1 queries by using `includes` or `joins`.
- Analyze queries with `EXPLAIN` to optimize performance.

**Impact:**  
Improves database throughput and response time.

**Trade-offs:**

| Pros                                      | Cons                                      |
|-------------------------------------------|-------------------------------------------|
| Reduced DB load and response time         | Requires careful tuning and ongoing analysis |
| Prevents performance degradation at scale | Extra code review discipline              |

---

## 3. Caching

**Description:**  
Use caching (e.g. Rails cache, Redis) for:
- User feed results (weekly)
- Followers/following lists

**Impact:**  
Reduces repeated DB queries and improves read performance.

**Trade-offs:**

| Pros                                   | Cons                                    |
|----------------------------------------|-----------------------------------------|
| Faster response for repeated requests  | Potential stale data if cache invalidation fails |
| Scales well under high read traffic    | Requires extra infrastructure (e.g., Redis) |

---

## 4. Pagination & Limit

**Description:**  
Implement pagination and default limits on endpoints like:
- `/feed`
- `/followers`
- `/following`

**Impact:**  
Prevents large responses, reduces memory and DB usage.

**Trade-offs:**

| Pros                             | Cons                          |
|----------------------------------|-------------------------------|
| Efficient resource usage         | Client must manage pagination |
| Reduces API latency              | Cannot fetch entire dataset in one call |

---

## 5. Read-Replica Databases

**Description:**  
Distribute read operations to read-replica databases, especially for endpoints like `/feed`.

**Impact:**  
Reduces load on the primary database.

**Trade-offs:**

| Pros                                 | Cons                                |
|--------------------------------------|-------------------------------------|
| Horizontal read scalability          | Replication lag may cause stale data |
| Protects primary from read bottlenecks | Requires replica infrastructure     |

---

## Summary Table

| Strategy              | Purpose                                         | Pros                                         | Cons                                   |
|-----------------------|-------------------------------------------------|----------------------------------------------|----------------------------------------|
| **Database Indexing** | Speed up queries                                | Fast lookups and joins                       | Slower writes; more storage            |
| **Query Optimization**| Reduce DB load                                  | Faster response; less CPU/IO                 | Needs continuous tuning                |
| **Caching**           | Reduce repeated queries                         | Handles high read traffic efficiently        | Stale data risk; cache infra needed    |
| **Pagination & Limit**| Reduce data processed/transferred               | Lower memory usage; faster responses         | Client handles pagination              |
| **Read-Replica DB**   | Distribute read load                            | Scales horizontally for reads                | Replication lag; infra complexity      |

---

> ✅ These strategies ensure the system can scale horizontally and remain performant even under heavy load, high user concurrency, and large volumes of data over time.
