select * from public.cust_bt;

select * from public.order_bt;

select * from public.order_line_bt;

select * from public.product_bt;

select * from public.staff_bt;


SELECT * FROM bitemporal_internal.ll_bitemporal_correction(
	'product_bt',
    'price',
    '275',
    'product_id',
    '2',
    temporal_relationships.timeperiod ('2024-02-12 11:29:37.754162+00'::timestamptz,'infinity'),
    utc_now() );

	
===================
NOTICE:  1: p_tableproduct_bt
NOTICE:  1: v_now2024-09-12 12:20:17.768567+00
NOTICE:  1: p_search_fieldsproduct_id
NOTICE:  1: p_search_values2
NOTICE:  1: p_effective["2024-09-12 11:29:37.754162+00",infinity)

UPDATE product_bt SET asserted = temporal_relationships.timeperiod_range(lower(asserted), '2024-09-12 12:20:17.768567+00'::timestamptz, '[)')

-- select * from product_bt
WHERE ( product_id )=( 2 ) AND effective @> tstzrange('2024-09-12 11:29:37.754162+00'::timestamptz, 'infinity'::timestamptz)
	  AND upper(asserted)='infinity' 
	  AnD lower(asserted)< '2024-09-12 12:20:17.768567+00'
===================
NOTICE:  2: p_tableproduct_bt
NOTICE:  2: v_list_of_fields_to_insert product_id,product_name,weight,price
NOTICE:  2: p_search_fieldsproduct_id
NOTICE:  2: p_search_values2
NOTICE:  2: p_effective["2024-09-12 11:29:37.754162+00",infinity)
NOTICE:  2: v_now2024-09-12 12:20:17.768567+00

INSERT INTO product_bt ( product_id,product_name,weight,price, effective, asserted )

SELECT product_id,product_name,weight,price ,effective, temporal_relationships.timeperiod_range(upper(asserted), 'infinity', '[)')
  FROM product_bt WHERE ( product_id )=( 2 ) AND effective @> tstzrange('2024-09-12 11:29:37.754162+00'::timestamptz, 'infinity'::timestamptz)
		  AND upper(asserted)= '2024-09-12 12:20:17.768567+00'
======================

NOTICE:  3: p_tableproduct_bt
NOTICE:  3: p_list_of_fieldsprice
NOTICE:  3: p_list_of_values275
NOTICE:  3: p_search_fieldsproduct_id
NOTICE:  3: p_search_values2
NOTICE:  3: p_effective["2024-02-12 11:29:37.754162+00",infinity)

UPDATE product_bt SET ( price ) = ROW( 275 ) 
-- select * from product_bt
WHERE ( product_id ) = ( 2 )
                           AND effective @> tstzrange('2024-09-12 11:29:37.754162+00'::timestamptz, 'infinity'::timestamptz)
                           AND upper(asserted)='infinity'

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



=====
debug

SELECT * FROM staff_bt
WHERE staff_id = 1 
AND effective @> tstzrange('2024-09-04 10:15:04.341732+00'::timestamptz, 'infinity'::timestamptz);

=====
