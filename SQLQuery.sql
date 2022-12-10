SELECT  * FROM NashvilleHousing

-- Standardising Date format
SELECT SaleDate
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE

-- Populate Property Address Data

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL


-- 29 NULL values present : we can populate them if we have some point of reference

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID

-- we can observe for parcelId 015 14 0 060.00, we have 2 records having exactly same address

-- so we can find respective parcelIds and if they have address, we can copy them with NULLs

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) NullUpdatedAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] -- to avoid getting the same row
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] -- to avoid getting the same row
WHERE a.PropertyAddress IS NULL
--
SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL 


-- no more nulls present


-- Breaking our address into individual columns (address, city)

-- in PropertyAddress, address and city are separated by , as a delimiter

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress))
FROM NashvilleHousing
-- this is returning , as well

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing

-- Adding Desired Column
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

-- Adding Desired Column
ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT * FROM NashvilleHousing

-- Breaking our owner address into individual columns (address, city, state)

-- parsename only works with periods, but since we have , , we will replace them

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS address
FROM NashvilleHousing

-- Adding desired columns 
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 


ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 


SELECT * FROM NashvilleHousing

-- change y and n to yes and no in 'sold as vacant'

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS Count
FROM NashvilleHousing
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END AS UpdatedValues
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END 


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS Count
FROM NashvilleHousing
GROUP BY SoldAsVacant

-- Remove Duplicates
WITH RowNum_CTE AS
(
	SELECT  *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
								 ORDER BY UniqueID	) Rn
	FROM NashvilleHousing
)
SELECT * FROM RowNum_CTE
WHERE Rn > 1
ORDER BY PropertyAddress


-- Deleting these duplicates
WITH RowNum_CTE AS
(
	SELECT  *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
								 ORDER BY UniqueID	) Rn
	FROM NashvilleHousing
)
DELETE FROM RowNum_CTE
WHERE Rn > 1
