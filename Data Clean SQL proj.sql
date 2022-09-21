-- Data cleaning project

-- Standarise Date format
SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY 1,2

Select Saledate, (CONVERT(Date, saledate))
FROM PortfolioProject..NashvilleHousing

-- Following didn't seem to work
UPDATE NashvilleHousing
SET SaleDate = CONVERT(date,saledate)

-- Trying different approach

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY 1,2

-- seemed to work ok!

-- Now populate property address data for nulls, as some are already present within the data, will look at a self join

SELECT a.parcelID, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
  FROM PortfolioProject..NashvilleHousing AS a
LEFT JOIN PortfolioProject..NashvilleHousing AS b
	ON a.parcelID = b.parcelID
   AND a.uniqueID <> b.uniqueID
WHERE a.propertyaddress is NULL

-- the above showed those will Nulls, will below use the ISNULL function to change value

UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
  FROM PortfolioProject..NashvilleHousing AS a
LEFT JOIN PortfolioProject..NashvilleHousing AS b
	ON a.parcelID = b.parcelID
   AND a.uniqueID <> b.uniqueID
WHERE a.propertyaddress is NULL

-- Split out address into individual columns (address, city, state)

SELECT propertyaddress
FROM PortfolioProject..NashvilleHousing

SELECT 
SUBSTRING(Propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(Propertyaddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(Propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(Propertyaddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY 1

-- Splitting out owner address

SELECT owneraddress
  FROM PortfolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(owneraddress,',','.'),3),
PARSENAME(REPLACE(owneraddress,',','.'),2),
PARSENAME(REPLACE(owneraddress,',','.'),1)
  FROM PortfolioProject..NashvilleHousing
ORDER BY uniqueID

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwneerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress,',','.'),3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress,',','.'),2)

UPDATE NashvilleHousing
SET OwneerSplitState = PARSENAME(REPLACE(owneraddress,',','.'),1)

-- Tidy up the soldasvacant column

SELECT DISTINCT soldasvacant, COUNT(soldasvacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant =

CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-- Remove duplicates, partition on items that should be unique

SELECT *, 
ROW_NUMBER() OVER (PARTITION BY 
							ParcelID, 
							PropertyAddress, 
							SaleDate, 
							SalePrice, 
							LegalReference
							ORDER BY UniqueID) AS row_num
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelId

-- Need to put above into CTE so can filter on row_num

WITH rowcte AS (
SELECT *, 
ROW_NUMBER() OVER (PARTITION BY 
							ParcelID, 
							PropertyAddress, 
							SaleDate, 
							SalePrice, 
							LegalReference
							ORDER BY UniqueID) AS row_num
FROM PortfolioProject..NashvilleHousing
)




DELETE
FROM rowcte
WHERE row_num > 1


-- test and there are no duplicates left, could also just filter to have row_num not > 1
WITH rowcte AS (
SELECT *, 
ROW_NUMBER() OVER (PARTITION BY 
							ParcelID, 
							PropertyAddress, 
							SaleDate, 
							SalePrice, 
							LegalReference
							ORDER BY UniqueID) AS row_num
FROM PortfolioProject..NashvilleHousing
)

SELECT *
FROM rowcte
WHERE row_num >1
ORDER BY 1,2,3

-- Delete Unused Columns, usually used for views, not raw data
-- Now we've split addresses, will delete the combo address

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY 1

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate
