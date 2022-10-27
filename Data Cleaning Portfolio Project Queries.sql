/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject..Housing

----------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..Housing

UPDATE Housing
SET SaleDate = CONVERT(Date, SaleDate)

-- *if it doesn't update properly 

ALTER TABLE Housing
ADD SaleDateConverted Date;

UPDATE Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)

----------------------------------------------------------------------------------------------------------

--Populate Property Address Data

SELECT *
FROM PortfolioProject..Housing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Housing a
JOIN PortfolioProject..Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Housing a
JOIN PortfolioProject..Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

----------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..Housing
--WHERE PropertyAddress is NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS PAddress
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS PAddress
FROM PortfolioProject..Housing


ALTER TABLE Housing
ADD Address nvarchar(255);

UPDATE Housing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Housing
ADD City nvarchar(255);

UPDATE Housing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT OwnerAddress
FROM PortfolioProject..Housing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..Housing

ALTER TABLE Housing
ADD AddressOfTheOwner nvarchar(255);

UPDATE Housing
SET AddressOfTheOwner = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Housing
ADD CityOfTheOwner nvarchar(255);

UPDATE Housing
SET CityOfTheOwner  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Housing
ADD StateOfTheOwner nvarchar(255);

UPDATE Housing
SET StateOfTheOwner = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject..Housing

----------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..Housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..Housing

UPDATE Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

 ----------------------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
						UniqueID
						) row_num
FROM PortfolioProject..Housing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM PortfolioProject..Housing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

----------------------------------------------------------------------------------------------------------

--Delete Unused Columns


SELECT *
FROM PortfolioProject..Housing

ALTER TABLE PortfolioProject..Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

----------------------------------------------------------------------------------------------------------