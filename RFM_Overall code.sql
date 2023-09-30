
SELECT * FROM sales;
SELECT * FROM Customer_Info;
SELECT * FROM segment_scores;

-- -- -- -- -- -- -- RFM Calculate -- -- -- -- -- -- -- 

select concat(FirstName,' ', LastName) as Customer_Name from Customer_Info
-- chọn cột gộp tên, not update
alter table Customer_Info add newcolumn varchar(50)
update Customer_Info set newcolumn = concat(FirstName,' ', LastName);
-- đổi thành Customer_Name trong design, hoặc xóa cột trong design


-- RFM Calculate 
WITH RFM_Base 
AS
(
  SELECT b.Customer_Name AS CustomerName,
    DATEDIFF(DAY, MAX(a.Order_Date), CONVERT(DATE,'2020/1/1')) AS Recency_Value, --đáng lẽ là base ngày 1/1/2020
    COUNT(DISTINCT a.Order_Date) AS Frequency_Value,
    ROUND(SUM(a.Sales), 2) AS Monetary_Value
  FROM sales AS a
  INNER JOIN Customer_Info AS b ON a.CustomerID = b.CustomerID
  GROUP BY b.Customer_Name
)
--SELECT * FROM RFM_Base -- nhớ chạy cùng dòng này
, RFM_Score 
AS
(
  SELECT *,
    NTILE(5) OVER (ORDER BY Recency_Value DESC) as R_Score, --R_Score tương quan nghịch, càng cao ~ mua càng xa, gt mang lại càng thấp
    NTILE(5) OVER (ORDER BY Frequency_Value ASC) as F_Score,  -- F_Score và M_Score tương quan thuận
    NTILE(5) OVER (ORDER BY Monetary_Value ASC) as M_Score		-- 1: thấp, 5: cao
  FROM RFM_Base
)
--SELECT * FROM RFM_Score
, RFM_Final
AS
(
SELECT *,
  CONCAT(R_Score, F_Score, M_Score) as RFM_Overall
  -- , (R_Score + F_Score + M_Score) as RFM_Overall1  --cách sai: tổng số 3 cột
  -- , CAST(R_Score AS char(1))+CAST(F_Score AS char(1))+CAST(M_Score AS char(1)) as RFM_Overall2
FROM RFM_Score
)
--SELECT * FROM RFM_Final
SELECT f.*, s.Segment
FROM RFM_Final f
JOIN [segment_scores] s ON f.RFM_Overall = s.Scores
; 

-- -- -- -- -- -- -- Done -- -- -- -- -- -- -- 
