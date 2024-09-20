-- CREATE OR REPLACE function utc_now() RETURNS timestamp
-- LANGUAGE SQL
-- as $func$
-- 	select CURRENT_TIMESTAMP AT TIME ZONE 'UTC';
-- $func$;

-- PART 1 - table creation --

SELECT * FROM bitemporal_internal.ll_create_bitemporal_table(
    'public',
    'staff_bt',
	$$staff_id int, 
	  staff_name TEXT NOT NULL,
      staff_location TEXT NOT NULL
	$$,
   'staff_id');
   
 SELECT * FROM bitemporal_internal.ll_create_bitemporal_table(
    'public',
    'cust_bt',
	$$cust_id int NOT NULL, 
	  cust_name TEXT NOT NULL,
      phone TEXT
	$$,
   'cust_id');
   
   SELECT * FROM bitemporal_internal.ll_create_bitemporal_table(
    'public',
    'product_bt',
	$$product_id INT,
	  product_name text NOT NULL,
      weight INTEGER NOT NULL DEFAULT(0),
      price INTEGER NOT NULL DEFAULT(0)
	$$,
   'product_id');
   
 SELECT * FROM bitemporal_internal.ll_create_bitemporal_table(
    'public',
    'order_bt',
	$$order_id INT NOT NULL,
	  staff_id INT NOT NULL,
          cust_id INT NOT NULL,
	  order_created_at timestamptz
	$$,
   'order_id');
     
 SELECT * FROM bitemporal_internal.ll_create_bitemporal_table(
    'public',
    'order_line_bt',
	$$order_line_id INT NOT NULL,
	 order_id INT NOT NULL,
          product_id INT NOT NULL,
	 qty int NOT NULL,
           order_line_created_at timestamptz
	$$,
   'order_id,order_line_id');


-- PART 2 - sequences creation --

drop SEQUENCE if exists public.staff_id_seq;
CREATE SEQUENCE public.staff_id_seq;
drop SEQUENCE if exists public.cust_id_seq;
CREATE SEQUENCE public.cust_id_seq;
drop SEQUENCE if exists public.product_id_seq;
CREATE SEQUENCE public.product_id_seq;
drop SEQUENCE if exists public.order_id_seq;
CREATE SEQUENCE public.order_id_seq;
drop SEQUENCE if exists public.order_line_id_seq;
CREATE SEQUENCE public.order_line_id_seq;


-- PART 3 - initial insertions --

select * from bitemporal_internal.ll_bitemporal_insert('public.staff_bt'
,$$staff_id, staff_name, staff_location$$
,quote_literal(nextval('staff_id_seq'))||$$,
'mystaff', 'mylocation'$$
,temporal_relationships.timeperiod(now(), 'infinity') --effective
,temporal_relationships.timeperiod(now(), 'infinity') --asserted
);

select * from bitemporal_internal.ll_bitemporal_insert('public.cust_bt'
,$$cust_id, cust_name, phone$$
,quote_literal(nextval('cust_id_seq'))||$$,
'mycust', '+6281197889890'$$
,temporal_relationships.timeperiod(now(), 'infinity') --effective
,temporal_relationships.timeperiod(now(), 'infinity') --asserted
);

select * from bitemporal_internal.ll_bitemporal_insert('public.product_bt'
,$$product_id, product_name,weight,price$$
,quote_literal(nextval('product_id_seq'))||$$,
'myproduct', 100,200$$
,temporal_relationships.timeperiod(now(), 'infinity') --effective
,temporal_relationships.timeperiod(now(), 'infinity') --asserted
);

select * from bitemporal_internal.ll_bitemporal_insert('public.product_bt'
,$$product_id, product_name,weight,price$$
,quote_literal(nextval('product_id_seq'))||$$,
'myproduct2', 200,250$$
,temporal_relationships.timeperiod(now(), 'infinity') --effective
,temporal_relationships.timeperiod(now(), 'infinity') --asserted
);

select * from bitemporal_internal.ll_bitemporal_insert('public.order_bt'
,$$order_id, staff_id,cust_id,order_created_at$$
,quote_literal(nextval('order_id_seq'))||$$,
1,1,$$||quote_literal(now())
,temporal_relationships.timeperiod(now(), 'infinity') --effective
,temporal_relationships.timeperiod(now(), 'infinity') --asserted
);

select * from bitemporal_internal.ll_bitemporal_insert('public.order_line_bt'
,$$order_line_id,order_id, product_id,qty, order_line_created_at$$
,quote_literal(nextval('order_line_id_seq'))||$$,
1,1,10,$$||quote_literal(now())
,temporal_relationships.timeperiod(now(), 'infinity') --effective
,temporal_relationships.timeperiod(now(), 'infinity') --asserted
);

select * from bitemporal_internal.ll_bitemporal_insert('public.order_line_bt'
,$$order_line_id,order_id, product_id,qty, order_line_created_at$$
,quote_literal(nextval('order_line_id_seq'))||$$,
1,2,15,$$||quote_literal(now())
,temporal_relationships.timeperiod(now(), 'infinity') --effective
,temporal_relationships.timeperiod(now(), 'infinity') --asserted
);


-- PART 3* - check initial insertions --

select * from public.cust_bt;
select * from public.order_bt;
select * from public.order_line_bt;
select * from public.product_bt;
select * from public.staff_bt;

select
o.order_id, 
staff_name, 
staff_location, 
c.cust_name, 
c.phone AS cust_phone, 
p.product_name, 
p.price,
l.qty
    FROM order_line_bt l
    JOIN order_bt o ON o.order_id = l.order_id
    JOIN product_bt p ON p.product_id = l.product_id
    JOIN staff_bt s ON s.staff_id = o.staff_id
    JOIN cust_bt c ON c.cust_id = o.cust_id
WHERE l.order_id=1
AND order_line_created_at<@l.effective AND now()<@l.asserted
AND order_created_at<@o.effective AND now()<@o.asserted
AND order_created_at<@c.effective AND now()<@c.asserted
AND order_created_at<@p.effective AND now()<@p.asserted
AND order_created_at<@s.effective AND now()<@s.asserted;


-- PART 4 - updates --

SELECT * FROM  bitemporal_internal.ll_bitemporal_update('public'
,'staff_bt'
,'staff_location'-- fields to update'
,$$'newlocation'$$  -- values to update with
,'staff_id'  -- search fields
,'1' --  search values
,temporal_relationships.timeperiod(now(), 'infinity')
,temporal_relationships.timeperiod(now(), 'infinity')
) ;

SELECT * FROM  bitemporal_internal.ll_bitemporal_update('public'
,'product_bt'
,'price'
,$$300$$
,'product_id'
,'1'
,temporal_relationships.timeperiod(now(), 'infinity')
,temporal_relationships.timeperiod(now(), 'infinity') 
) ;

SELECT * FROM  bitemporal_internal.ll_bitemporal_update('public'
,'cust_bt'
,'phone'
,$$'+628111111111'$$
,'cust_id'  -- search fields
,$$1$$ --  search values
,temporal_relationships.timeperiod(now(), 'infinity')
,temporal_relationships.timeperiod(now(), 'infinity')
) ; 

-- PART 4* - check updates --

select * from public.cust_bt;
select * from public.product_bt;
select * from public.staff_bt;

select
o.order_id, 
staff_name, 
staff_location, 
c.cust_name, 
c.phone AS cust_phone, 
p.product_name, 
p.price,
l.qty
    FROM order_line_bt l
    JOIN order_bt o ON o.order_id = l.order_id
    JOIN product_bt p ON p.product_id = l.product_id
    JOIN staff_bt s ON s.staff_id = o.staff_id
    JOIN cust_bt c ON c.cust_id = o.cust_id
WHERE l.order_id=1
AND order_line_created_at<@l.effective AND now()<@l.asserted
AND order_created_at<@o.effective AND now()<@o.asserted
AND order_created_at<@c.effective AND now()<@c.asserted
AND order_created_at<@p.effective AND now()<@p.asserted
AND order_created_at<@s.effective AND now()<@s.asserted;


-- PART 5 - correction --

select * from public.product_bt;
select * from public.staff_bt;

SELECT * FROM bitemporal_internal.ll_bitemporal_correction(
	'product_bt',
    'price',
    '275',
    'product_id',
    '2',
    temporal_relationships.timeperiod ('2024-09-12 10:57:26.816311-05'::timestamptz,'infinity'), -- change the timestamp to the inserted one!
    now() );


SELECT * FROM bitemporal_internal.ll_bitemporal_correction(
	'staff_bt',
    'staff_location',
    $$'another_location'$$,
    'staff_id',
    '1',
    temporal_relationships.timeperiod ('2024-09-16 10:56:23.684724+00'::timestamptz,'infinity'), -- change the timestamp to the inserted one!
    now() );


-- PART 5* - check correction --

select * from public.product_bt;
select * from public.staff_bt;

---corrected price
select
o.order_id, 
staff_name, 
staff_location, 
c.cust_name, 
c.phone AS cust_phone, 
p.product_name, 
p.price,
l.qty
    FROM order_line_bt l
    JOIN order_bt o ON o.order_id = l.order_id
    JOIN product_bt p ON p.product_id = l.product_id
    JOIN staff_bt s ON s.staff_id = o.staff_id
    JOIN cust_bt c ON c.cust_id = o.cust_id
WHERE l.order_id=1
AND order_line_created_at<@l.effective AND now()<@l.asserted
AND order_created_at<@o.effective AND now()<@o.asserted
AND order_created_at<@c.effective AND now()<@c.asserted
AND order_created_at<@p.effective AND now()<@p.asserted
AND order_created_at<@s.effective AND now()<@s.asserted;

--original price
select
o.order_id, 
staff_name, 
staff_location, 
c.cust_name, 
c.phone AS cust_phone, 
p.product_name, 
p.price,
l.qty
    FROM order_line_bt l
    JOIN order_bt o ON o.order_id = l.order_id
    JOIN product_bt p ON p.product_id = l.product_id
    JOIN staff_bt s ON s.staff_id = o.staff_id
    JOIN cust_bt c ON c.cust_id = o.cust_id
WHERE l.order_id=1
AND order_line_created_at<@l.effective AND order_line_created_at<@l.asserted
AND order_created_at<@o.effective AND order_created_at<@o.asserted
AND order_created_at<@c.effective AND order_created_at<@c.asserted
AND order_created_at<@p.effective AND order_created_at<@p.asserted
AND order_created_at<@s.effective AND order_created_at<@s.asserted;


-- PART 6 - delete --

SELECT * FROM bitemporal_internal.ll_bitemporal_delete(
	'product_bt',
    'product_id',
    '2',
    -- temporal_relationships.timeperiod ('2024-09-16 11:25:52.408731+00'::timestamptz,'infinity'));
    temporal_relationships.timeperiod ('2024-09-16 11:25:52.408731+00'::timestamptz,'2024-09-16 11:27:16.020743+00'::timestamptz)); -- change the timestamp to the inserted one!


-- PART 7 - inactivate --

SELECT * FROM bitemporal_internal.ll_bitemporal_inactivate(
	'staff_bt',
    'staff_id',
    '1',
    temporal_relationships.timeperiod ('2024-09-18 11:28:16.758879+00"'::timestamptz,'infinity'), -- inactivation period
    temporal_relationships.timeperiod ('2024-09-16 11:28:16.758879+00"'::timestamptz,'infinity') ); -- change the timestamp to the inserted one!