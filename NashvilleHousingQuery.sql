--take a look at the data
SELECT *
FROM NashvilleHousing

--- 

--use count to find out if there are duplicate UniqueID
SELECT COUNT (*), COUNT(DISTINCT UniqueID)
FROM NashvilleHousing
--there is none

---

--explore the property address column
SELECT * 
FROM NashvilleHousing
WHERE PropertyAddress IS NULL
--there are null values
--find out why by exploring the parcelID column

SELECT UniqueID, ParcelID, PropertyAddress
FROM NashvilleHousing
ORDER BY ParcelID
--its observed that some duplicate values for ParcelID and PropertyAddress column collectively are assigned to different UniqueID values

--populate the null values in propertyaddress column with corresponding values from same column where the parcelID is thesame but UniqueID is different
--to do this, join the table with itself 

SELECT a.UniqueID, b.UniqueID, a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress
FROM NashvilleHousing a JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE b.PropertyAddress IS NULL

--update the null columns using ISNULL functions
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.parcelID
	AND a.UniqueID  <> b.UniqueID
WHERE a.PropertyAddress is null

--check that there are no more nulls in propertyaddress column
SELECT * 
FROM NashvilleHousing
WHERE PropertyAddress IS NULL


----

-- use CTE to find out total number of sales for each year
WITH CountOfYearSales AS (
SELECT SaleDate, YEAR(SaleDate) As Sale_Year
FROM NashvilleHousing
 )
 SELECT Sale_Year, COUNT(Sale_Year) SaleCountByYear
 FROM CountOfYearSales
 GROUP BY Sale_Year
 ORDER BY SaleCountByYear DESC
 --2015 had the most amount of sales and 2019 had the least

 --find out why 2019 had only 2 sales
 SELECT *
 FROM NashvilleHousing
 WHERE SaleDate LIKE '%2019%'
 --the sales occured once in May and once in December of 2019. These are outliers and should be reported to superiors

 --find the total sum of sale price for each year to see which year sold more in terms of Saleprice
 WITH TotalPriceByYear AS (
 SELECT YEAR(SaleDate) As Sale_Year, SalePrice
FROM NashvilleHousing
)
SELECT Sale_Year, SUM(SalePrice) SumOfSalePrice	
FROM TotalPriceByYear
GROUP BY Sale_Year
ORDER BY SumOfSalePrice DESC
--the order of total sum of sales per year corresponds to the order of total count of sales per year


----


--find the highest and lowest profit made on a property
--to do this, sum up the sale price and total value made several times towards one property, and the subtract the saleprice from the total house value

WITH TotalProfit AS
(SELECT  PropertyAddress, SUM(SalePrice) TotalSalePrice, SUM(TotalValue) TotalHouseValue
FROM NashvilleHousing
WHERE TotalValue IS NOT NULL
GROUP BY PropertyAddress, SalePrice, TotalValue)
SELECT PropertyAddress, TotalSalePrice -TotalHouseValue AS Profit
FROM TotalProfit
ORDER BY Profit 
-- lowest profit on a sale

WITH TotalProfit AS
(SELECT  PropertyAddress, SUM(SalePrice) TotalSalePrice, SUM(TotalValue) TotalHouseValue
FROM NashvilleHousing
WHERE TotalValue IS NOT NULL
GROUP BY PropertyAddress, SalePrice, TotalValue)
SELECT PropertyAddress, TotalSalePrice -TotalHouseValue AS Profit
FROM TotalProfit
ORDER BY Profit DESC
--highest profit on a sale