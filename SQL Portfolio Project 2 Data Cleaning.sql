SELECT *
FROM MyPortfolio..NashvilleHousing


SELECT 
	SaleDateConverted,
	CONVERT(date,saledate) AS SaleDate2
FROM MyPortfolio.dbo.NashvilleHousing

UPDATE MyPortfolio..NashvilleHousing
SET saledate = CONVERT(date,saledate)

ALTER TABLE MyPortfolio..NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE MyPortfolio..NashvilleHousing
SET SaleDateConverted = CONVERT(date,saledate)

-- Populating Property Address Information and Data

SELECT *
FROM MyPortfolio..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT 
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM MyPortfolio..NashvilleHousing a
JOIN MyPortfolio..NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM MyPortfolio..NashvilleHousing a
JOIN MyPortfolio..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

-- Breaking Address into Individual Columns (Address, City, State)

SELECT 
	PropertyAddress
FROM MyPortfolio..NashvilleHousing

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM MyPortfolio..NashvilleHousing

ALTER TABLE MyPortfolio..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE MyPortfolio..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE MyPortfolio..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE MyPortfolio..NashvilleHousing
SET PropertySplitCity = 	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT 
	PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM MyPortfolio..NashvilleHousing


ALTER TABLE MyPortfolio..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE MyPortfolio..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE MyPortfolio..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE MyPortfolio..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE MyPortfolio..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE MyPortfolio..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Changing Y and N to Yes and No in "Sold as Vacant" Column

SELECT 
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM MyPortfolio..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT 
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM MyPortfolio..NashvilleHousing


UPDATE MyPortfolio..NashvilleHousing
SET SoldAsVacant = 
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END


-- Remove Duplicates 

WITH RowNumCTE AS (
SELECT 
	*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID) Row_Num
FROM MyPortfolio..NashvilleHousing
-- ORDER BY ParcelID
) 
SELECT *
FROM RowNumCTE
WHERE Row_Num > 1
--ORDER BY PropertyAddress


--Delete Unused Columns

SELECT * 
FROM MyPortfolio..NashvilleHousing

ALTER TABLE MyPortfolio..NashvilleHousing
DROP COLUMN OwnerAddress, 
	TaxDistrict,
	PropertyAddress

ALTER TABLE MyPortfolio..NashvilleHousing
DROP COLUMN SaleDate

