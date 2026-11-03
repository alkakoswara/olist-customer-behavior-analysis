select count(*)
from olist_order_reviews_dataset  

select review_score, count(*)
from olist_order_reviews_dataset 
where review_comment_message is null
group by review_score

select review_id, review_score, review_comment_message
from olist_order_reviews_dataset
where review_id = 'ceef71ec8c12263b2435a71d581b4716'

select count(distinct review_id)
from olist_order_reviews_dataset

select count(distinct order_id)
from olist_order_reviews_dataset

select count(distinct (review_id, order_id))
from olist_order_reviews_dataset

select count(*)
from olist_order_reviews_dataset 
where review_id is null or order_id is null

select count(*)
from olist_order_reviews_dataset as r
left join olist_orders_dataset as o
on r.order_id = o.order_id 
where o.order_id is null

select count(*)
from olist_orders_dataset as o
left join olist_order_reviews_dataset as r
on o.order_id = r.order_id 
where r.order_id is null














