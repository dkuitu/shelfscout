-- ShelfScout Mock Data Seed (Kelowna)
-- Run AFTER knex seed:run so region/store rows exist
-- Usage: psql "postgres://shelfscout:shelfscout_dev@localhost:5433/shelfscout" -f server/seed_mock_data.sql

-- Clean existing data (order matters for FK constraints)
DELETE FROM crown_transfers;
DELETE FROM crowns;
DELETE FROM validations;
DELETE FROM submissions;
DELETE FROM user_badges;
DELETE FROM weekly_items;

BEGIN;

-- ============================================================
-- LOOKUP HELPERS (populated by knex seeds)
-- ============================================================
CREATE TEMP TABLE _s AS SELECT id, name FROM stores;
CREATE TEMP TABLE _c AS SELECT id FROM weekly_cycles WHERE active = true LIMIT 1;
CREATE TEMP TABLE _i AS SELECT id, name FROM items;
CREATE TEMP TABLE _b AS SELECT id, name FROM badges;

-- Shorthand aliases for items (used as subqueries throughout)
-- _i lookups:  (SELECT id FROM _i WHERE name='Milk (2L)')
-- _s lookups:  (SELECT id FROM _s WHERE name='Save-On-Foods (Orchard Park)')
-- _c lookup:   (SELECT id FROM _c)

-- ============================================================
-- EXTRA ITEMS
-- ============================================================
INSERT INTO items (id, name, category, unit) VALUES
('b2c3d4e5-2222-4000-a000-000000000001', 'Avocados (3pk)', 'Produce', '3pk'),
('b2c3d4e5-2222-4000-a000-000000000002', 'Greek Yogurt', 'Dairy', '500g'),
('b2c3d4e5-2222-4000-a000-000000000003', 'Pasta', 'Pantry', '500g'),
('b2c3d4e5-2222-4000-a000-000000000004', 'Salmon Fillet', 'Seafood', 'lb'),
('b2c3d4e5-2222-4000-a000-000000000005', 'Ground Beef', 'Meat', 'lb'),
('b2c3d4e5-2222-4000-a000-000000000006', 'Apples (Gala)', 'Produce', 'lb'),
('b2c3d4e5-2222-4000-a000-000000000007', 'Cheddar Cheese', 'Dairy', '300g'),
('b2c3d4e5-2222-4000-a000-000000000008', 'Orange Juice', 'Beverages', '1.89L'),
('b2c3d4e5-2222-4000-a000-000000000009', 'Coffee (Ground)', 'Beverages', '340g'),
('b2c3d4e5-2222-4000-a000-000000000010', 'Olive Oil', 'Pantry', '500ml'),
('b2c3d4e5-2222-4000-a000-000000000011', 'Peanut Butter', 'Pantry', '500g'),
('b2c3d4e5-2222-4000-a000-000000000012', 'Oat Milk', 'Dairy', '1L')
ON CONFLICT DO NOTHING;

-- Refresh item lookup to include new items
DROP TABLE _i;
CREATE TEMP TABLE _i AS SELECT id, name FROM items;

-- Link original items to weekly cycle
INSERT INTO weekly_items (id, cycle_id, item_id)
SELECT gen_random_uuid(), (SELECT id FROM _c), id FROM _i
ON CONFLICT DO NOTHING;

-- ============================================================
-- USERS (use same bcrypt hash as testuser = "password123")
-- ============================================================
INSERT INTO users (id, email, username, password_hash, trust_score, region_id) VALUES
('c3d4e5f6-3333-4000-a000-000000000001', 'maya@example.com', 'maya_deals',
 '$2b$12$grqQVCOD8ZJ9ZtvBHpxuquKLQd/ptf7xjyEApz0bNUiRwlQAVJL96', 4.20,
 (SELECT id FROM regions WHERE name='Kelowna')),
('c3d4e5f6-3333-4000-a000-000000000002', 'josh@example.com', 'josh_scout',
 '$2b$12$grqQVCOD8ZJ9ZtvBHpxuquKLQd/ptf7xjyEApz0bNUiRwlQAVJL96', 3.75,
 (SELECT id FROM regions WHERE name='Kelowna')),
('c3d4e5f6-3333-4000-a000-000000000003', 'sarah@example.com', 'sarah_saves',
 '$2b$12$grqQVCOD8ZJ9ZtvBHpxuquKLQd/ptf7xjyEApz0bNUiRwlQAVJL96', 4.85,
 (SELECT id FROM regions WHERE name='Kelowna')),
('c3d4e5f6-3333-4000-a000-000000000004', 'kevin@example.com', 'kev_hunter',
 '$2b$12$grqQVCOD8ZJ9ZtvBHpxuquKLQd/ptf7xjyEApz0bNUiRwlQAVJL96', 2.90,
 (SELECT id FROM regions WHERE name='Kelowna')),
('c3d4e5f6-3333-4000-a000-000000000005', 'priya@example.com', 'priya_prices',
 '$2b$12$grqQVCOD8ZJ9ZtvBHpxuquKLQd/ptf7xjyEApz0bNUiRwlQAVJL96', 4.50,
 (SELECT id FROM regions WHERE name='Kelowna')),
('c3d4e5f6-3333-4000-a000-000000000006', 'alex@example.com', 'alex_frugal',
 '$2b$12$grqQVCOD8ZJ9ZtvBHpxuquKLQd/ptf7xjyEApz0bNUiRwlQAVJL96', 3.10,
 (SELECT id FROM regions WHERE name='Kelowna')),
('c3d4e5f6-3333-4000-a000-000000000007', 'lin@example.com', 'lin_bargains',
 '$2b$12$grqQVCOD8ZJ9ZtvBHpxuquKLQd/ptf7xjyEApz0bNUiRwlQAVJL96', 4.65,
 (SELECT id FROM regions WHERE name='Kelowna')),
('c3d4e5f6-3333-4000-a000-000000000008', 'emma@example.com', 'emma_shops',
 '$2b$12$grqQVCOD8ZJ9ZtvBHpxuquKLQd/ptf7xjyEApz0bNUiRwlQAVJL96', 3.55,
 (SELECT id FROM regions WHERE name='Kelowna'))
ON CONFLICT DO NOTHING;

-- Update existing testuser with Kelowna region
UPDATE users SET region_id = (SELECT id FROM regions WHERE name='Kelowna'), trust_score = 3.25
WHERE email = 'test@example.com';

-- ============================================================
-- SUBMISSIONS (Kelowna GPS coords, all IDs looked up dynamically)
-- ============================================================
INSERT INTO submissions (id, user_id, store_id, item_id, cycle_id, price, photo_url, status, gps_lat, gps_lng, submitted_at, verified_at) VALUES
-- Maya's submissions
('d4e5f6a7-4444-4000-a000-000000000001', 'c3d4e5f6-3333-4000-a000-000000000001',
 (SELECT id FROM _s WHERE name='Save-On-Foods (Orchard Park)'),
 (SELECT id FROM _i WHERE name='Milk (2L)'), (SELECT id FROM _c), 4.49,
 'https://picsum.photos/seed/milk1/400/300', 'verified', 49.8626, -119.4521,
 NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days'),
('d4e5f6a7-4444-4000-a000-000000000002', 'c3d4e5f6-3333-4000-a000-000000000001',
 (SELECT id FROM _s WHERE name='No Frills (Rutland)'),
 (SELECT id FROM _i WHERE name='Milk (2L)'), (SELECT id FROM _c), 3.99,
 'https://picsum.photos/seed/milk2/400/300', 'verified', 49.8876, -119.4081,
 NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day'),
('d4e5f6a7-4444-4000-a000-000000000003', 'c3d4e5f6-3333-4000-a000-000000000001',
 (SELECT id FROM _s WHERE name='Safeway (Harvey Ave)'),
 (SELECT id FROM _i WHERE name='Eggs (12pk)'), (SELECT id FROM _c), 7.99,
 'https://picsum.photos/seed/eggs1/400/300', 'verified', 49.8871, -119.4961,
 NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day'),
('d4e5f6a7-4444-4000-a000-000000000004', 'c3d4e5f6-3333-4000-a000-000000000001',
 (SELECT id FROM _s WHERE name='Costco Kelowna'),
 (SELECT id FROM _i WHERE name='Salmon Fillet'), (SELECT id FROM _c), 12.99,
 'https://picsum.photos/seed/salmon1/400/300', 'verified', 49.8841, -119.4271,
 NOW() - INTERVAL '1 day', NOW() - INTERVAL '12 hours'),
('d4e5f6a7-4444-4000-a000-000000000005', 'c3d4e5f6-3333-4000-a000-000000000001',
 (SELECT id FROM _s WHERE name='FreshCo'),
 (SELECT id FROM _i WHERE name='Coffee (Ground)'), (SELECT id FROM _c), 11.49,
 'https://picsum.photos/seed/coffee1/400/300', 'pending', 49.8921, -119.4951,
 NOW() - INTERVAL '6 hours', NULL),

-- Josh's submissions
('d4e5f6a7-4444-4000-a000-000000000006', 'c3d4e5f6-3333-4000-a000-000000000002',
 (SELECT id FROM _s WHERE name='Save-On-Foods (Orchard Park)'),
 (SELECT id FROM _i WHERE name='Bread (White)'), (SELECT id FROM _c), 3.29,
 'https://picsum.photos/seed/bread1/400/300', 'verified', 49.8624, -119.4519,
 NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days'),
('d4e5f6a7-4444-4000-a000-000000000007', 'c3d4e5f6-3333-4000-a000-000000000002',
 (SELECT id FROM _s WHERE name='Real Canadian Superstore'),
 (SELECT id FROM _i WHERE name='Chicken Breast'), (SELECT id FROM _c), 11.99,
 'https://picsum.photos/seed/chicken1/400/300', 'verified', 49.8701, -119.4351,
 NOW() - INTERVAL '2 days', NOW() - INTERVAL '36 hours'),
('d4e5f6a7-4444-4000-a000-000000000008', 'c3d4e5f6-3333-4000-a000-000000000002',
 (SELECT id FROM _s WHERE name='No Frills (Rutland)'),
 (SELECT id FROM _i WHERE name='Ground Beef'), (SELECT id FROM _c), 6.49,
 'https://picsum.photos/seed/beef1/400/300', 'pending', 49.8874, -119.4082,
 NOW() - INTERVAL '8 hours', NULL),

-- Sarah's submissions (top user)
('d4e5f6a7-4444-4000-a000-000000000009', 'c3d4e5f6-3333-4000-a000-000000000003',
 (SELECT id FROM _s WHERE name='No Frills (Rutland)'),
 (SELECT id FROM _i WHERE name='Milk (2L)'), (SELECT id FROM _c), 3.79,
 'https://picsum.photos/seed/milk3/400/300', 'verified', 49.8877, -119.4079,
 NOW() - INTERVAL '4 days', NOW() - INTERVAL '3 days'),
('d4e5f6a7-4444-4000-a000-000000000010', 'c3d4e5f6-3333-4000-a000-000000000003',
 (SELECT id FROM _s WHERE name='Real Canadian Superstore'),
 (SELECT id FROM _i WHERE name='Eggs (12pk)'), (SELECT id FROM _c), 5.99,
 'https://picsum.photos/seed/eggs2/400/300', 'verified', 49.8699, -119.4352,
 NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days'),
('d4e5f6a7-4444-4000-a000-000000000011', 'c3d4e5f6-3333-4000-a000-000000000003',
 (SELECT id FROM _s WHERE name='FreshCo'),
 (SELECT id FROM _i WHERE name='Bananas'), (SELECT id FROM _c), 0.69,
 'https://picsum.photos/seed/bananas1/400/300', 'verified', 49.8919, -119.4952,
 NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day'),
('d4e5f6a7-4444-4000-a000-000000000012', 'c3d4e5f6-3333-4000-a000-000000000003',
 (SELECT id FROM _s WHERE name='Walmart Supercentre'),
 (SELECT id FROM _i WHERE name='Avocados (3pk)'), (SELECT id FROM _c), 4.99,
 'https://picsum.photos/seed/avocado1/400/300', 'verified', 49.8781, -119.4311,
 NOW() - INTERVAL '1 day', NOW() - INTERVAL '12 hours'),
('d4e5f6a7-4444-4000-a000-000000000013', 'c3d4e5f6-3333-4000-a000-000000000003',
 (SELECT id FROM _s WHERE name='Safeway (Harvey Ave)'),
 (SELECT id FROM _i WHERE name='Olive Oil'), (SELECT id FROM _c), 8.49,
 'https://picsum.photos/seed/olive1/400/300', 'verified', 49.8872, -119.4959,
 NOW() - INTERVAL '1 day', NOW() - INTERVAL '6 hours'),
('d4e5f6a7-4444-4000-a000-000000000014', 'c3d4e5f6-3333-4000-a000-000000000003',
 (SELECT id FROM _s WHERE name='Save-On-Foods (Glenmore)'),
 (SELECT id FROM _i WHERE name='Greek Yogurt'), (SELECT id FROM _c), 5.49,
 'https://picsum.photos/seed/yogurt1/400/300', 'pending', 49.9031, -119.4841,
 NOW() - INTERVAL '4 hours', NULL),

-- Kevin's submissions (some rejected)
('d4e5f6a7-4444-4000-a000-000000000015', 'c3d4e5f6-3333-4000-a000-000000000004',
 (SELECT id FROM _s WHERE name='Save-On-Foods (Orchard Park)'),
 (SELECT id FROM _i WHERE name='Rice (2kg)'), (SELECT id FROM _c), 5.99,
 'https://picsum.photos/seed/rice1/400/300', 'verified', 49.8623, -119.4522,
 NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days'),
('d4e5f6a7-4444-4000-a000-000000000016', 'c3d4e5f6-3333-4000-a000-000000000004',
 (SELECT id FROM _s WHERE name='Costco Kelowna'),
 (SELECT id FROM _i WHERE name='Butter'), (SELECT id FROM _c), 4.99,
 'https://picsum.photos/seed/butter1/400/300', 'rejected', 49.8842, -119.4269,
 NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day'),
('d4e5f6a7-4444-4000-a000-000000000017', 'c3d4e5f6-3333-4000-a000-000000000004',
 (SELECT id FROM _s WHERE name='No Frills (Rutland)'),
 (SELECT id FROM _i WHERE name='Canned Tomatoes'), (SELECT id FROM _c), 1.49,
 'https://picsum.photos/seed/tomatoes1/400/300', 'rejected', 49.8873, -119.4083,
 NOW() - INTERVAL '1 day', NOW() - INTERVAL '12 hours'),

-- Priya's submissions
('d4e5f6a7-4444-4000-a000-000000000018', 'c3d4e5f6-3333-4000-a000-000000000005',
 (SELECT id FROM _s WHERE name='Safeway (Harvey Ave)'),
 (SELECT id FROM _i WHERE name='Milk (2L)'), (SELECT id FROM _c), 5.99,
 'https://picsum.photos/seed/milk4/400/300', 'verified', 49.8869, -119.4962,
 NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days'),
('d4e5f6a7-4444-4000-a000-000000000019', 'c3d4e5f6-3333-4000-a000-000000000005',
 (SELECT id FROM _s WHERE name='Walmart Supercentre'),
 (SELECT id FROM _i WHERE name='Bread (White)'), (SELECT id FROM _c), 4.29,
 'https://picsum.photos/seed/bread2/400/300', 'verified', 49.8779, -119.4312,
 NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day'),
('d4e5f6a7-4444-4000-a000-000000000020', 'c3d4e5f6-3333-4000-a000-000000000005',
 (SELECT id FROM _s WHERE name='FreshCo'),
 (SELECT id FROM _i WHERE name='Pasta'), (SELECT id FROM _c), 1.99,
 'https://picsum.photos/seed/pasta1/400/300', 'verified', 49.8918, -119.4953,
 NOW() - INTERVAL '1 day', NOW() - INTERVAL '6 hours'),
('d4e5f6a7-4444-4000-a000-000000000021', 'c3d4e5f6-3333-4000-a000-000000000005',
 (SELECT id FROM _s WHERE name='Real Canadian Superstore'),
 (SELECT id FROM _i WHERE name='Apples (Gala)'), (SELECT id FROM _c), 1.69,
 'https://picsum.photos/seed/apples1/400/300', 'pending', 49.8702, -119.4349,
 NOW() - INTERVAL '5 hours', NULL),

-- Alex's submissions
('d4e5f6a7-4444-4000-a000-000000000022', 'c3d4e5f6-3333-4000-a000-000000000006',
 (SELECT id FROM _s WHERE name='No Frills (Rutland)'),
 (SELECT id FROM _i WHERE name='Eggs (12pk)'), (SELECT id FROM _c), 6.49,
 'https://picsum.photos/seed/eggs3/400/300', 'verified', 49.8878, -119.4078,
 NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day'),
('d4e5f6a7-4444-4000-a000-000000000023', 'c3d4e5f6-3333-4000-a000-000000000006',
 (SELECT id FROM _s WHERE name='Save-On-Foods (Glenmore)'),
 (SELECT id FROM _i WHERE name='Cheddar Cheese'), (SELECT id FROM _c), 6.99,
 'https://picsum.photos/seed/cheese1/400/300', 'pending', 49.9032, -119.4839,
 NOW() - INTERVAL '3 hours', NULL),

-- Lin's submissions (many verified)
('d4e5f6a7-4444-4000-a000-000000000024', 'c3d4e5f6-3333-4000-a000-000000000007',
 (SELECT id FROM _s WHERE name='Costco Kelowna'),
 (SELECT id FROM _i WHERE name='Bananas'), (SELECT id FROM _c), 0.59,
 'https://picsum.photos/seed/bananas2/400/300', 'verified', 49.8843, -119.4268,
 NOW() - INTERVAL '4 days', NOW() - INTERVAL '3 days'),
('d4e5f6a7-4444-4000-a000-000000000025', 'c3d4e5f6-3333-4000-a000-000000000007',
 (SELECT id FROM _s WHERE name='Real Canadian Superstore'),
 (SELECT id FROM _i WHERE name='Orange Juice'), (SELECT id FROM _c), 3.49,
 'https://picsum.photos/seed/oj1/400/300', 'verified', 49.8698, -119.4353,
 NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days'),
('d4e5f6a7-4444-4000-a000-000000000026', 'c3d4e5f6-3333-4000-a000-000000000007',
 (SELECT id FROM _s WHERE name='Save-On-Foods (Orchard Park)'),
 (SELECT id FROM _i WHERE name='Peanut Butter'), (SELECT id FROM _c), 4.49,
 'https://picsum.photos/seed/pb1/400/300', 'verified', 49.8627, -119.4518,
 NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day'),
('d4e5f6a7-4444-4000-a000-000000000027', 'c3d4e5f6-3333-4000-a000-000000000007',
 (SELECT id FROM _s WHERE name='Walmart Supercentre'),
 (SELECT id FROM _i WHERE name='Oat Milk'), (SELECT id FROM _c), 4.99,
 'https://picsum.photos/seed/oatmilk1/400/300', 'verified', 49.8782, -119.4309,
 NOW() - INTERVAL '1 day', NOW() - INTERVAL '6 hours'),

-- Emma's submissions
('d4e5f6a7-4444-4000-a000-000000000028', 'c3d4e5f6-3333-4000-a000-000000000008',
 (SELECT id FROM _s WHERE name='FreshCo'),
 (SELECT id FROM _i WHERE name='Chicken Breast'), (SELECT id FROM _c), 10.99,
 'https://picsum.photos/seed/chicken2/400/300', 'verified', 49.8922, -119.4948,
 NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day'),
('d4e5f6a7-4444-4000-a000-000000000029', 'c3d4e5f6-3333-4000-a000-000000000008',
 (SELECT id FROM _s WHERE name='Safeway (Harvey Ave)'),
 (SELECT id FROM _i WHERE name='Avocados (3pk)'), (SELECT id FROM _c), 5.99,
 'https://picsum.photos/seed/avocado2/400/300', 'pending', 49.8868, -119.4963,
 NOW() - INTERVAL '7 hours', NULL),

-- Testuser submissions
('d4e5f6a7-4444-4000-a000-000000000030', '60b2b84e-b330-4ddd-9a23-463c3f76bdcc',
 (SELECT id FROM _s WHERE name='Save-On-Foods (Orchard Park)'),
 (SELECT id FROM _i WHERE name='Eggs (12pk)'), (SELECT id FROM _c), 6.29,
 'https://picsum.photos/seed/eggs4/400/300', 'verified', 49.8628, -119.4517,
 NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day'),
('d4e5f6a7-4444-4000-a000-000000000031', '60b2b84e-b330-4ddd-9a23-463c3f76bdcc',
 (SELECT id FROM _s WHERE name='Costco Kelowna'),
 (SELECT id FROM _i WHERE name='Salmon Fillet'), (SELECT id FROM _c), 14.99,
 'https://picsum.photos/seed/salmon2/400/300', 'verified', 49.8844, -119.4267,
 NOW() - INTERVAL '1 day', NOW() - INTERVAL '12 hours'),
('d4e5f6a7-4444-4000-a000-000000000032', '60b2b84e-b330-4ddd-9a23-463c3f76bdcc',
 (SELECT id FROM _s WHERE name='FreshCo'),
 (SELECT id FROM _i WHERE name='Apples (Gala)'), (SELECT id FROM _c), 1.49,
 'https://picsum.photos/seed/apples2/400/300', 'pending', 49.8917, -119.4954,
 NOW() - INTERVAL '4 hours', NULL)
ON CONFLICT DO NOTHING;

-- ============================================================
-- VALIDATIONS
-- ============================================================
INSERT INTO validations (id, submission_id, validator_id, vote, reason) VALUES
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000001', 'c3d4e5f6-3333-4000-a000-000000000002', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000001', 'c3d4e5f6-3333-4000-a000-000000000003', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000001', '60b2b84e-b330-4ddd-9a23-463c3f76bdcc', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000002', 'c3d4e5f6-3333-4000-a000-000000000005', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000002', 'c3d4e5f6-3333-4000-a000-000000000007', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000003', 'c3d4e5f6-3333-4000-a000-000000000006', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000004', 'c3d4e5f6-3333-4000-a000-000000000003', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000004', 'c3d4e5f6-3333-4000-a000-000000000008', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000006', 'c3d4e5f6-3333-4000-a000-000000000001', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000006', 'c3d4e5f6-3333-4000-a000-000000000005', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000007', 'c3d4e5f6-3333-4000-a000-000000000003', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000007', 'c3d4e5f6-3333-4000-a000-000000000007', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000009', 'c3d4e5f6-3333-4000-a000-000000000001', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000009', 'c3d4e5f6-3333-4000-a000-000000000002', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000009', '60b2b84e-b330-4ddd-9a23-463c3f76bdcc', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000010', 'c3d4e5f6-3333-4000-a000-000000000001', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000010', 'c3d4e5f6-3333-4000-a000-000000000007', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000011', 'c3d4e5f6-3333-4000-a000-000000000005', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000012', 'c3d4e5f6-3333-4000-a000-000000000004', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000013', 'c3d4e5f6-3333-4000-a000-000000000008', 'confirm', NULL),
-- Kevin's rejected
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000016', 'c3d4e5f6-3333-4000-a000-000000000003', 'flag', 'Price tag not visible in photo'),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000016', 'c3d4e5f6-3333-4000-a000-000000000005', 'flag', 'Wrong store location'),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000017', 'c3d4e5f6-3333-4000-a000-000000000001', 'flag', 'Blurry photo, cannot verify'),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000017', 'c3d4e5f6-3333-4000-a000-000000000007', 'flag', 'Price seems incorrect'),
-- Others
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000015', 'c3d4e5f6-3333-4000-a000-000000000001', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000018', 'c3d4e5f6-3333-4000-a000-000000000002', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000019', 'c3d4e5f6-3333-4000-a000-000000000004', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000020', 'c3d4e5f6-3333-4000-a000-000000000006', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000022', 'c3d4e5f6-3333-4000-a000-000000000003', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000024', 'c3d4e5f6-3333-4000-a000-000000000001', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000024', 'c3d4e5f6-3333-4000-a000-000000000005', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000025', 'c3d4e5f6-3333-4000-a000-000000000008', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000026', 'c3d4e5f6-3333-4000-a000-000000000004', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000027', 'c3d4e5f6-3333-4000-a000-000000000002', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000028', 'c3d4e5f6-3333-4000-a000-000000000001', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000028', 'c3d4e5f6-3333-4000-a000-000000000005', 'confirm', NULL),
-- Testuser's
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000030', 'c3d4e5f6-3333-4000-a000-000000000003', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000030', 'c3d4e5f6-3333-4000-a000-000000000007', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000031', 'c3d4e5f6-3333-4000-a000-000000000001', 'confirm', NULL),
(gen_random_uuid(), 'd4e5f6a7-4444-4000-a000-000000000031', 'c3d4e5f6-3333-4000-a000-000000000005', 'confirm', NULL)
ON CONFLICT DO NOTHING;

-- ============================================================
-- CROWNS
-- ============================================================
INSERT INTO crowns (id, item_id, region_id, cycle_id, holder_id, submission_id, lowest_price, status, claimed_at) VALUES
-- Milk crown: Sarah $3.79
('e5f6a7b8-5555-4000-a000-000000000001', (SELECT id FROM _i WHERE name='Milk (2L)'),
 (SELECT id FROM regions WHERE name='Kelowna'), (SELECT id FROM _c),
 'c3d4e5f6-3333-4000-a000-000000000003', 'd4e5f6a7-4444-4000-a000-000000000009', 3.79, 'active', NOW() - INTERVAL '3 days'),
-- Bread crown: Josh $3.29
('e5f6a7b8-5555-4000-a000-000000000002', (SELECT id FROM _i WHERE name='Bread (White)'),
 (SELECT id FROM regions WHERE name='Kelowna'), (SELECT id FROM _c),
 'c3d4e5f6-3333-4000-a000-000000000002', 'd4e5f6a7-4444-4000-a000-000000000006', 3.29, 'active', NOW() - INTERVAL '2 days'),
-- Bananas crown: Lin $0.59
('e5f6a7b8-5555-4000-a000-000000000003', (SELECT id FROM _i WHERE name='Bananas'),
 (SELECT id FROM regions WHERE name='Kelowna'), (SELECT id FROM _c),
 'c3d4e5f6-3333-4000-a000-000000000007', 'd4e5f6a7-4444-4000-a000-000000000024', 0.59, 'active', NOW() - INTERVAL '3 days'),
-- Eggs crown: Sarah $5.99
('e5f6a7b8-5555-4000-a000-000000000004', (SELECT id FROM _i WHERE name='Eggs (12pk)'),
 (SELECT id FROM regions WHERE name='Kelowna'), (SELECT id FROM _c),
 'c3d4e5f6-3333-4000-a000-000000000003', 'd4e5f6a7-4444-4000-a000-000000000010', 5.99, 'active', NOW() - INTERVAL '2 days'),
-- Chicken crown: Emma $10.99
('e5f6a7b8-5555-4000-a000-000000000005', (SELECT id FROM _i WHERE name='Chicken Breast'),
 (SELECT id FROM regions WHERE name='Kelowna'), (SELECT id FROM _c),
 'c3d4e5f6-3333-4000-a000-000000000008', 'd4e5f6a7-4444-4000-a000-000000000028', 10.99, 'active', NOW() - INTERVAL '1 day'),
-- Rice crown: Kevin $5.99
('e5f6a7b8-5555-4000-a000-000000000006', (SELECT id FROM _i WHERE name='Rice (2kg)'),
 (SELECT id FROM regions WHERE name='Kelowna'), (SELECT id FROM _c),
 'c3d4e5f6-3333-4000-a000-000000000004', 'd4e5f6a7-4444-4000-a000-000000000015', 5.99, 'active', NOW() - INTERVAL '2 days'),
-- Avocados crown: Sarah $4.99
('e5f6a7b8-5555-4000-a000-000000000007', (SELECT id FROM _i WHERE name='Avocados (3pk)'),
 (SELECT id FROM regions WHERE name='Kelowna'), (SELECT id FROM _c),
 'c3d4e5f6-3333-4000-a000-000000000003', 'd4e5f6a7-4444-4000-a000-000000000012', 4.99, 'active', NOW() - INTERVAL '1 day'),
-- Salmon crown: Maya $12.99
('e5f6a7b8-5555-4000-a000-000000000008', (SELECT id FROM _i WHERE name='Salmon Fillet'),
 (SELECT id FROM regions WHERE name='Kelowna'), (SELECT id FROM _c),
 'c3d4e5f6-3333-4000-a000-000000000001', 'd4e5f6a7-4444-4000-a000-000000000004', 12.99, 'active', NOW() - INTERVAL '12 hours'),
-- OJ crown: Lin $3.49
('e5f6a7b8-5555-4000-a000-000000000009', (SELECT id FROM _i WHERE name='Orange Juice'),
 (SELECT id FROM regions WHERE name='Kelowna'), (SELECT id FROM _c),
 'c3d4e5f6-3333-4000-a000-000000000007', 'd4e5f6a7-4444-4000-a000-000000000025', 3.49, 'active', NOW() - INTERVAL '2 days'),
-- Pasta crown: Priya $1.99
('e5f6a7b8-5555-4000-a000-000000000010', (SELECT id FROM _i WHERE name='Pasta'),
 (SELECT id FROM regions WHERE name='Kelowna'), (SELECT id FROM _c),
 'c3d4e5f6-3333-4000-a000-000000000005', 'd4e5f6a7-4444-4000-a000-000000000020', 1.99, 'active', NOW() - INTERVAL '6 hours'),
-- Olive Oil crown: Sarah $8.49
('e5f6a7b8-5555-4000-a000-000000000011', (SELECT id FROM _i WHERE name='Olive Oil'),
 (SELECT id FROM regions WHERE name='Kelowna'), (SELECT id FROM _c),
 'c3d4e5f6-3333-4000-a000-000000000003', 'd4e5f6a7-4444-4000-a000-000000000013', 8.49, 'active', NOW() - INTERVAL '6 hours'),
-- PB crown: Lin $4.49
('e5f6a7b8-5555-4000-a000-000000000012', (SELECT id FROM _i WHERE name='Peanut Butter'),
 (SELECT id FROM regions WHERE name='Kelowna'), (SELECT id FROM _c),
 'c3d4e5f6-3333-4000-a000-000000000007', 'd4e5f6a7-4444-4000-a000-000000000026', 4.49, 'active', NOW() - INTERVAL '1 day')
ON CONFLICT DO NOTHING;

-- ============================================================
-- CROWN TRANSFERS
-- ============================================================
INSERT INTO crown_transfers (id, crown_id, from_user_id, to_user_id, price, transferred_at) VALUES
(gen_random_uuid(), 'e5f6a7b8-5555-4000-a000-000000000001', NULL,
 'c3d4e5f6-3333-4000-a000-000000000001', 4.49, NOW() - INTERVAL '3 days 2 hours'),
(gen_random_uuid(), 'e5f6a7b8-5555-4000-a000-000000000001', 'c3d4e5f6-3333-4000-a000-000000000001',
 'c3d4e5f6-3333-4000-a000-000000000003', 3.79, NOW() - INTERVAL '3 days'),
(gen_random_uuid(), 'e5f6a7b8-5555-4000-a000-000000000003', NULL,
 'c3d4e5f6-3333-4000-a000-000000000003', 0.69, NOW() - INTERVAL '2 days'),
(gen_random_uuid(), 'e5f6a7b8-5555-4000-a000-000000000003', 'c3d4e5f6-3333-4000-a000-000000000003',
 'c3d4e5f6-3333-4000-a000-000000000007', 0.59, NOW() - INTERVAL '3 days'),
(gen_random_uuid(), 'e5f6a7b8-5555-4000-a000-000000000002', NULL,
 'c3d4e5f6-3333-4000-a000-000000000002', 3.29, NOW() - INTERVAL '2 days'),
(gen_random_uuid(), 'e5f6a7b8-5555-4000-a000-000000000004', NULL,
 'c3d4e5f6-3333-4000-a000-000000000003', 5.99, NOW() - INTERVAL '2 days'),
(gen_random_uuid(), 'e5f6a7b8-5555-4000-a000-000000000005', NULL,
 'c3d4e5f6-3333-4000-a000-000000000008', 10.99, NOW() - INTERVAL '1 day'),
(gen_random_uuid(), 'e5f6a7b8-5555-4000-a000-000000000008', NULL,
 'c3d4e5f6-3333-4000-a000-000000000001', 12.99, NOW() - INTERVAL '12 hours')
ON CONFLICT DO NOTHING;

-- ============================================================
-- BADGES + AWARDS
-- ============================================================
INSERT INTO badges (id, name, description, criteria, rarity, icon_url) VALUES
('f6a7b8c9-6666-4000-a000-000000000001', 'Price Sniper', 'Submit 10 verified prices', 'verified_submissions >= 10', 'uncommon', '/badges/price-sniper.png'),
('f6a7b8c9-6666-4000-a000-000000000002', 'Store Explorer', 'Submit prices at 5 different stores', 'unique_stores >= 5', 'uncommon', '/badges/store-explorer.png'),
('f6a7b8c9-6666-4000-a000-000000000003', 'Early Bird', 'Be the first to submit in a weekly cycle', 'first_in_cycle = true', 'rare', '/badges/early-bird.png'),
('f6a7b8c9-6666-4000-a000-000000000004', 'Bargain Boss', 'Hold 3 crowns simultaneously', 'active_crowns >= 3', 'epic', '/badges/bargain-boss.png'),
('f6a7b8c9-6666-4000-a000-000000000005', 'Community Hero', 'Validate 25 submissions', 'total_validations >= 25', 'rare', '/badges/community-hero.png')
ON CONFLICT DO NOTHING;

-- Refresh badge lookup
DROP TABLE _b;
CREATE TEMP TABLE _b AS SELECT id, name FROM badges;

INSERT INTO user_badges (id, user_id, badge_id, earned_at) VALUES
-- Sarah
(gen_random_uuid(), 'c3d4e5f6-3333-4000-a000-000000000003', (SELECT id FROM _b WHERE name='First Submission'), NOW() - INTERVAL '5 days'),
(gen_random_uuid(), 'c3d4e5f6-3333-4000-a000-000000000003', (SELECT id FROM _b WHERE name='Crown Hunter'), NOW() - INTERVAL '3 days'),
(gen_random_uuid(), 'c3d4e5f6-3333-4000-a000-000000000003', (SELECT id FROM _b WHERE name='Price Sniper'), NOW() - INTERVAL '2 days'),
(gen_random_uuid(), 'c3d4e5f6-3333-4000-a000-000000000003', (SELECT id FROM _b WHERE name='Bargain Boss'), NOW() - INTERVAL '1 day'),
-- Maya
(gen_random_uuid(), 'c3d4e5f6-3333-4000-a000-000000000001', (SELECT id FROM _b WHERE name='First Submission'), NOW() - INTERVAL '4 days'),
(gen_random_uuid(), 'c3d4e5f6-3333-4000-a000-000000000001', (SELECT id FROM _b WHERE name='Crown Hunter'), NOW() - INTERVAL '12 hours'),
-- Lin
(gen_random_uuid(), 'c3d4e5f6-3333-4000-a000-000000000007', (SELECT id FROM _b WHERE name='First Submission'), NOW() - INTERVAL '5 days'),
(gen_random_uuid(), 'c3d4e5f6-3333-4000-a000-000000000007', (SELECT id FROM _b WHERE name='Crown Hunter'), NOW() - INTERVAL '3 days'),
(gen_random_uuid(), 'c3d4e5f6-3333-4000-a000-000000000007', (SELECT id FROM _b WHERE name='Early Bird'), NOW() - INTERVAL '4 days'),
-- Josh
(gen_random_uuid(), 'c3d4e5f6-3333-4000-a000-000000000002', (SELECT id FROM _b WHERE name='First Submission'), NOW() - INTERVAL '4 days'),
(gen_random_uuid(), 'c3d4e5f6-3333-4000-a000-000000000002', (SELECT id FROM _b WHERE name='Crown Hunter'), NOW() - INTERVAL '2 days'),
-- Priya
(gen_random_uuid(), 'c3d4e5f6-3333-4000-a000-000000000005', (SELECT id FROM _b WHERE name='First Submission'), NOW() - INTERVAL '4 days'),
(gen_random_uuid(), 'c3d4e5f6-3333-4000-a000-000000000005', (SELECT id FROM _b WHERE name='Crown Hunter'), NOW() - INTERVAL '6 hours'),
(gen_random_uuid(), 'c3d4e5f6-3333-4000-a000-000000000005', (SELECT id FROM _b WHERE name='Store Explorer'), NOW() - INTERVAL '1 day'),
-- Emma
(gen_random_uuid(), 'c3d4e5f6-3333-4000-a000-000000000008', (SELECT id FROM _b WHERE name='First Submission'), NOW() - INTERVAL '3 days'),
(gen_random_uuid(), 'c3d4e5f6-3333-4000-a000-000000000008', (SELECT id FROM _b WHERE name='Crown Hunter'), NOW() - INTERVAL '1 day'),
-- Kevin
(gen_random_uuid(), 'c3d4e5f6-3333-4000-a000-000000000004', (SELECT id FROM _b WHERE name='First Submission'), NOW() - INTERVAL '3 days'),
-- Alex
(gen_random_uuid(), 'c3d4e5f6-3333-4000-a000-000000000006', (SELECT id FROM _b WHERE name='First Submission'), NOW() - INTERVAL '3 days'),
-- Testuser
(gen_random_uuid(), '60b2b84e-b330-4ddd-9a23-463c3f76bdcc', (SELECT id FROM _b WHERE name='First Submission'), NOW() - INTERVAL '2 days')
ON CONFLICT DO NOTHING;

-- Cleanup temp tables
DROP TABLE IF EXISTS _s;
DROP TABLE IF EXISTS _c;
DROP TABLE IF EXISTS _i;
DROP TABLE IF EXISTS _b;

COMMIT;

-- Summary
SELECT 'Seed complete!' AS status;
SELECT COUNT(*) AS total_users FROM users;
SELECT COUNT(*) AS total_stores FROM stores;
SELECT COUNT(*) AS total_items FROM items;
SELECT COUNT(*) AS total_submissions FROM submissions;
SELECT COUNT(*) AS total_validations FROM validations;
SELECT COUNT(*) AS total_crowns FROM crowns;
SELECT COUNT(*) AS total_badges FROM badges;
SELECT COUNT(*) AS total_user_badges FROM user_badges;
