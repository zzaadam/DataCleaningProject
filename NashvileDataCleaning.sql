SELECT * 
FROM Nashville_housing;



--- Populate Property Address Data

SELECT *
FROM Nashville_housing
--WHERE PropertyAddress is null;
ORDER BY ParcelID;


SELECT a.ParcelID , a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_housing a
JOIN Nashville_housing b
   ON a.ParcelID = b.ParcelID
   AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null;

UPDATE Nashville_housing AS a
SET PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_housing AS b
WHERE a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
  AND a.PropertyAddress IS NULL;



-- Breaking out Address into Individual Columns (Address, City, State)

-- ProprtyAddress


SELECT PropertyAddress
FROM Nashville_housing
--WHERE PropertyAddress is null
ORDER BY ParcelID;

SELECT 
SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress)+1, LENGTH(PropertyAddress)) AS Address
FROM Nashville_housing;

ALTER TABLE Nashville_housing
ADD PropertySplitAddress text;

UPDATE Nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress)-1)

ALTER TABLE Nashville_housing
ADD PropertySplitCity text;

UPDATE Nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress)+1, LENGTH(PropertyAddress))

SELECT *
FROM Nashville_housing
ORDER BY ParcelID;



-- OwnerAddress

SELECT 
  SPLIT_PART(REPLACE(OwnerAddress, ', ', '.'), '.', 1),
  SPLIT_PART(REPLACE(OwnerAddress, ', ', '.'), '.', 2), 
  SPLIT_PART(REPLACE(OwnerAddress, ', ', '.'), '.', 3) 
FROM Nashville_housing
ORDER BY PARCELID;

ALTER TABLE Nashville_housing
ADD OwnerSplitAddress text;

UPDATE Nashville_housing
SET OwnerSplitAddress = SPLIT_PART(REPLACE(OwnerAddress, ', ', '.'), '.', 1)

ALTER TABLE Nashville_housing
ADD OwnerSplitCity text;

UPDATE Nashville_housing
SET OwnerSplitCity = SPLIT_PART(REPLACE(OwnerAddress, ', ', '.'), '.', 2)

ALTER TABLE Nashville_housing
ADD OwnerSplitState text;

UPDATE Nashville_housing
SET OwnerSplitState = SPLIT_PART(REPLACE(OwnerAddress, ', ', '.'), '.', 3)



-- Change Y and N to Yes and NO in "Sold as Vacant" column 

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM Nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT 
 SoldAsVacant,
  CASE 
     WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldASVacant
  END AS VacantStatus
FROM Nashville_housing;

UPDATE Nashville_housing
SET SoldAsVacant = CASE 
     WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldASVacant
  END 
 
 
 
-- Remove Duplicates 

SELECT * 
FROM Nashville_housing
ORDER BY ParcelID
 

WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM Nashville_housing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1;


DELETE FROM Nashville_housing
WHERE (ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, UniqueID) IN (
    SELECT ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, UniqueID
    FROM RowNumCTE
    WHERE row_num > 1
);



-- Check CTE to see if duplicates have been removed

WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM Nashville_housing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1;



-- Delete unused columns 

SELECT *
FROM Nashville_housing
ORDER BY ParcelID;

ALTER TABLE Nashville_housing
DROP COLUMN OwnerAddress
DROP COLUMN TaxDistrict
DROP COLUMN PropertyAddress;

ALTER TABLE Nashville_housing
DROP COLUMN SaleDate;



