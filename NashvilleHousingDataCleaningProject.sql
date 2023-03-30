/*
Cleaning Data in SQL queries
*/

USE PortfolioProject
SELECT *
FROM NashvilleHousing;
---------------------------------------------------------------------------------------

--Standardize Data Format
--convert saledate(datetime) to saledate(date) rename as SaleDateConverted

SELECT saledate, CONVERT(Date, SaleDate) AS SaleDateConverted
FROM nashvillehousing
----------------------------------------------------------------------------------------

-- add a new column SaleDateConverted to dataset, to include new saledate format
-- convert with UPDATE function

ALTER TABLE nashvillehousing
ADD SaleDateConverted DATE;

UPDATE nashvillehousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)
-----------------------------------------------------------------------------------------

-- Populate Property Address data
-- Locate data with NULL in PropertyAddress, to determine if it can be populated with available reference

USE PortfolioProject
SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL
----------------------------------------------------------------------------------------------

-- search with ParcelID to locate reference
-- search result: identical parcelID will have identical PropertyAddress, can populate with join table

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID
------------------------------------------------------------------------------------------------

-- join table to fill in the NULL for propertyAddress, join condition using ParcelID and UniqueID
-- Display which PropertyAddress is null

USE PortfolioProject
SELECT ori.ParcelID, ori.PropertyAddress, new.ParcelID, new.PropertyAddress
FROM NashvilleHousing ori
JOIN NashvilleHousing new
	ON ori.ParcelID = new.ParcelID
	AND ori.UniqueID <> new.UniqueID
WHERE ori.PropertyAddress IS NULL
-------------------------------------------------------------------------------------------------

-- Populate ori.PropertyAddress with new.PropertyAddress to fill up the null
-- use ISNULL function, will create a new column

USE PortfolioProject
SELECT ori.ParcelID, ori.PropertyAddress, new.ParcelID, new.PropertyAddress, ISNULL(ori.PropertyAddress, new.PropertyAddress) 
FROM NashvilleHousing ori
JOIN NashvilleHousing new
	ON ori.ParcelID = new.ParcelID
	AND ori.UniqueID <> new.UniqueID
WHERE ori.PropertyAddress IS NULL
--------------------------------------------------------------------------------------------------

-- UPDATE dataset with new PropertyAddress

UPDATE ori
SET PropertyAddress = ISNULL(ori.PropertyAddress, new.PropertyAddress)
FROM NashvilleHousing ori
JOIN NashvilleHousing new
	ON ori.ParcelID = new.ParcelID
	AND ori.UniqueID <> new.UniqueID
WHERE ori.PropertyAddress IS NULL
---------------------------------------------------------------------------------------------------

-- double check if there are any nulls in PropertyAddress

USE PortfolioProject
SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

----------------------------------------------------------------------------------------------------

-- Separate PropertyAddress into individual columns(Address, City, State)

USE PortfolioProject
SELECT Propertyaddress
FROM NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing
----------------------------------------------------------------------------------------------------

-- add two new column, PropertySplitAddress and PropertySplitCity to ori dataset

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------
-- separate address, city, state for column OwnerAddress
-- View OwnerAddress data format

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing
--------------------------------------------------------------------------------------------

-- separate OwnerAddress into separate column: Address, City and State

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM PortfolioProject.dbo.NashvilleHousing
---------------------------------------------------------------------------------------------

-- add new column for address, city and state into ori dataset

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "SoldAsVacant" field
-- get the attributes in SoldAsVacant column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS  qty
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY qty

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--------------------------------------------------------------------------------

-- Remove Duplicate, view how many duplicates there are. 

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num

FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
----------------------------------------------------------------------------

--Delete duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num

FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1

-------------------------------------------------------------------------------

--Delete unused columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate