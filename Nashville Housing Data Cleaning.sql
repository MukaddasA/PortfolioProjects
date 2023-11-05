-- This is a sql data cleaning project consisting of several steps denoted by the comments.




-- Data Cleaning

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing



-- Standardize date format


SELECT SaleDate
FROM PortfolioProject.dbo.NashvilleHousing


SELECT SaleDate, CAST(SaleDate AS DATE)
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CAST(SaleDate AS DATE)

-- The above did not modify the table as such we create a new column and add the data

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CAST(SaleDate AS DATE)

SELECT SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousing



-- Populate property address data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS a
JOIN PortfolioProject.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS a
JOIN PortfolioProject.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



-- Breaking out Address into individual columns

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address

FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


-- Modifying owners address

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
FROM PortfolioProject.dbo.NashvilleHousing


-- Because parsename identify delimiter backwards we will convert it to 3 2 1

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


-- Change Y and N to yes and no in 'sold as vacant' field


SELECT SoldAsVacant
FROM PortfolioProject.dbo.NashvilleHousing


SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END 
FROM PortfolioProject.dbo.NashvilleHousing 


UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END 


-- Confirmation
SELECT DISTINCT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing 


-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 Propertyaddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortfolioProject.dbo.NashvilleHousing 
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



-- DELETEING
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 Propertyaddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortfolioProject.dbo.NashvilleHousing 
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Delete Unused Column

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
DROP COLUMN SaleDate

