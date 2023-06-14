-- Viewing the data
SELECT * 
FROM dbo.NashvilleHousing;

-- We are going to standarize the date format of SaleDate column
SELECT SaleDate, CONVERT(date, SaleDate)
FROM ProyectoPortfolio..NashvilleHousing;


UPDATE NashvilleHousing --Este update no hace nada por alguna razón
SET SaleDate = CONVERT(date, SaleDate);

-- We can use ALTER TABLE instead of UPDATE and create a new column
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate);


-- Let's populate the property address column
-- Si UniqueID son distintos pero el ParcelID es exactamente el mismo entonces podemos ocupar la PropertyAddress y poblar 
-- los valores que contienen nulos de la columna PropertyAddress
-- Para ello usamos un self join.
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProyectoPortfolio..NashvilleHousing as a
JOIN ProyectoPortfolio..NashvilleHousing as b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL;

-- actualizamos la columna PropertyAddress
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProyectoPortfolio..NashvilleHousing as a
JOIN ProyectoPortfolio..NashvilleHousing as b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL;

-- Separamos los datos de la columna Address en 3 columnas (Address, City, State)
SELECT PropertyAddress
FROM ProyectoPortfolio.dbo.NashvilleHousing;

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM ProyectoPortfolio.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

SELECT * from dbo.NashvilleHousing;

-- Separamos los campos de la columna OwnerAddress (Address, City, State)
-- PARSENAME solo funciona con puntos, pero tenemos comas, asíque vamos a reemplazar las comas por puntos.
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
FROM ProyectoPortfolio..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select * from dbo.NashvilleHousing;


-- Cambiemos los valores Y y N de la columna SoldAsVacant por Yes y No
SELECT SoldAsVacant, COUNT(SoldAsVacant) FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
END
FROM dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
END;

-- Remove Duplicates
WITH RowNumCTE AS (
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) as row_num
	FROM dbo.NashvilleHousing
)

SELECT * FROM RowNumCTE
WHERE row_num > 1;

DELETE
FROM RowNumCTE
WHERE row_num > 1


--ORDER BY PropertyAddress;

-- Borramos ahora las columnas que no vamos a usar.
select * from dbo.NashvilleHousing;

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress 

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN SaleDate
