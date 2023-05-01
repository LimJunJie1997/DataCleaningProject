-- Cleaning Data in SQL queries

Select *
From DataCleaningSQLproject.dbo.Nashville

--Standardize Date Format

Select SaleDate, CONVERT (Date, SaleDate)
From DataCleaningSQLproject.dbo.Nashville

Update Nashville
SET SaleDate = CONVERT (Date, SaleDate)

-- or

ALTER TABLE Nashville
Add SaleDateConverted Date;

Update Nashville
SET SaleDateConverted = CONVERT (Date, SaleDate) 



-- Populate Property Address Data

Select PropertyAddress
From DataCleaningSQLproject.dbo.Nashville

-- to check whether the property address is null, then we need to check pattern so we can know where to populate the address

Select *
From DataCleaningSQLproject.dbo.Nashville
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaningSQLproject.dbo.Nashville a
JOIN DataCleaningSQLproject.dbo.Nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaningSQLproject.dbo.Nashville a
JOIN DataCleaningSQLproject.dbo.Nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



-- Breaking out Address into Individual Colums (Address, City, State)

Select PropertyAddress
From DataCleaningSQLproject.dbo.Nashville

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address

From DataCleaningSQLproject.dbo.Nashville

ALTER TABLE Nashville
Add PropertySplitAddress Nvarchar(255);

Update Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) 

ALTER TABLE Nashville
Add PropertySplitCity Nvarchar(255);

Update Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) 




Select OwnerAddress
From DataCleaningSQLproject.dbo.Nashville

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From DataCleaningSQLproject.dbo.Nashville

ALTER TABLE Nashville
Add OwnerSplitAddress Nvarchar(255);

Update Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashville
Add OwnerSplitCity Nvarchar(255);

Update Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nashville
Add OwnerSplitState Nvarchar(255);

Update Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-- Change Y and N to Yes and No in 'Sold as Vacan' fields

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From DataCleaningSQLproject.dbo.Nashville
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE	When SoldAsVacant = 'Y' THEN 'YES'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		End
From DataCleaningSQLproject.dbo.Nashville

Update Nashville
SET SoldAsVacant = CASE	When SoldAsVacant = 'Y' THEN 'YES'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		End


-- Remove Duplicates, but usually remove duplicates in temp table

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) row_num
From DataCleaningSQLproject.dbo.Nashville
--order by ParcelID
)
--DELETE
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


-- Delete Unused Columns, usually will not do under raw data

ALTER TABLE DataCleaningSQLproject.dbo.Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From DataCleaningSQLproject.dbo.Nashville



