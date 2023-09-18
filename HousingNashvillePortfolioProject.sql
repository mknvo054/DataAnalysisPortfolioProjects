--DATA Cleaning in SQL
Select * 
FROM PortfolioProject..NashvilleHousing

--Standardize Date Format
Select SaleDate, CONVERT(Date, SaleDate) As ConvertedDate
FROM PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate) 

Select SaleDateConverted
FROM PortfolioProject..NashvilleHousing


---------------------------------------------------
--Populate Property Address Data
SELECT *
FROM PortfolioProject..NashVilleHousing
WHERE PropertyAddress is null

SELECT Origin.ParcelID, Origin.PropertyAddress, Ref.ParcelID, Ref.PropertyAddress, 
ISNULL(Origin.PropertyAddress, Ref.PropertyAddress)
FROM PortfolioProject..NashvilleHousing Origin
JOIN PortfolioProject..NashvilleHousing Ref
	ON Origin.ParcelID = Ref.ParcelID
	AND Origin.[UniqueID ] <> Ref.[UniqueID ]
WHERE Origin.PropertyAddress is null

UPDATE Origin
SET Origin.PropertyAddress = ISNULL(Origin.PropertyAddress, Ref.PropertyAddress)
FROM PortfolioProject..NashvilleHousing Origin
JOIN PortfolioProject..NashvilleHousing Ref
	ON Origin.ParcelID = Ref.ParcelID
	AND Origin.[UniqueID ] <> Ref.[UniqueID ]
WHERE Origin.PropertyAddress is null

---------------------------------
--Break Out Address into individual Columns	(Address, City, State)

Select *
From PortfolioProject..NashvilleHousing

Select PropertyAddress, SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertyAddressSplitAddress nvarchar(255)

Update NashvilleHousing
SET PropertyAddressSplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1) 

ALTER TABLE NashvilleHousing
ADD PropertyAddressSplitCity nvarchar(255)

Update NashvilleHousing
SET PropertyAddressSplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

Select OwnerAddress, PARSENAME(Replace(OwnerAddress,',','.'), 3), 
PARSENAME(Replace(OwnerAddress,',','.'), 2),
PARSENAME(Replace(OwnerAddress,',','.'), 1)
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerAddressSplitAddress nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerAddressSplitCity nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerAddressSplitState nvarchar(255)

Update NashvilleHousing
SET OwnerAddressSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3)

Update NashvilleHousing
SET OwnerAddressSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)

Update NashvilleHousing
SET OwnerAddressSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)

---------------------------
--Change Y and N to Yes and No in "Sold As Vacant" Field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant END
From PortfolioProject..NashvilleHousing
WHERE SoldAsVacant = 'Y' OR SoldAsVacant = 'N'

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant END
------------------------------
--Remove Duplicates

WITH RowTable As (
Select *,
ROW_NUMBER() Over (Partition By ParcelID, PropertyAddress, SaleDate, SalePrice, Legalreference Order By ParcelID) as RowNumber
From PortfolioProject..NashvilleHousing
)

Select *
From RowTable
Where RowNumber > 1
--Order By PropertyAddress

Select * 
From PortfolioProject..NashvilleHousing

-------------------------
---Delete Unused Columns

Select * 
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict