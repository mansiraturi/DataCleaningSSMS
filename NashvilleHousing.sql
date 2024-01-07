select*from PortfolioProj.dbo.NashvilleHousing


-- Standadise Date Format

select SaleDate, CONVERT(Date, SaleDate)
from PortfolioProj.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
add SaleDateConverted Date

Update NashvilleHousing
set SaleDateConverted = CONVERT(Date, SaleDate)


--populate Property Address Data
select PropertyAddress
from PortfolioProj.dbo.NashvilleHousing
where PropertyAddress IS NULL

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProj.dbo.NashvilleHousing a
join PortfolioProj.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID 
AND a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress IS NULL


UPDATE a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProj.dbo.NashvilleHousing a
join PortfolioProj.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID 
AND a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress IS NULL

--Breaking out address into individual columns (Address, City, State)

select PropertyAddress
from PortfolioProj.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS State
from PortfolioProj.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropSplitAddr Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD PropSplitCity Nvarchar(255);

Update NashvilleHousing
SET PropSplitAddr = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Update NashvilleHousing
SET PropSplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select PropSplitAddr, PropSplitCity
from PortfolioProj.dbo.NashvilleHousing

--same for owner address
--PARSENAME WORKS BACKWARDS
select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address
from PortfolioProj.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddr Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddr = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

select OwnerSplitAddr, OwnerSplitCity, OwnerSplitState
from PortfolioProj.dbo.NashvilleHousing


--Change Y and N to Yes and No in "Sold as Vacant" field

select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProj.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE when SoldAsVacant = 'Y' THEN 'Yes'
when SoldAsVacant = 'N' THEN 'No'
else SoldAsVacant
end 
from PortfolioProj.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant =CASE when SoldAsVacant = 'Y' THEN 'Yes'
when SoldAsVacant = 'N' THEN 'No'
else SoldAsVacant
end 
from PortfolioProj.dbo.NashvilleHousing

--Remove Duplicates

WITH rownumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY uniqueID) AS row_num
    FROM PortfolioProj.dbo.NashvilleHousing
)
 
DELETE from rownumCTE
where row_num>1
order by PropertyAddress

SELECT* from rownumCTE
where row_num>1
order by PropertyAddress


 --Delete Unused Columns
 ALTER TABLE PortfolioProj.dbo.NashvilleHousing
 drop column PropertyAddress, OwnerAddress, TaxDistrict

  ALTER TABLE PortfolioProj.dbo.NashvilleHousing
 drop column SaleDate

 select*from PortfolioProj.dbo.NashvilleHousing