
-- Data Cleaning
Select *
from SQLPortfolioProject..NashvilleHousing

-- date format
Select SaleDateOnly, CONVERT(Date, SaleDate)
from SQLPortfolioProject..NashvilleHousing

Alter table NashvilleHousing
Add
	SaleDateOnly Date;

Update NashvilleHousing
Set
	SaleDateOnly = CONVERT(Date, SaleDate)
	
-----------------------------------------------------------------------------------

-- property address
Select *
from SQLPortfolioProject..NashvilleHousing
order By ParcelID


Select nh1.ParcelID, nh1.PropertyAddress, nh2.ParcelID, nh2.PropertyAddress, ISNULL(nh1.PropertyAddress, nh2.PropertyAddress)
from SQLPortfolioProject..NashvilleHousing nh1
join SQLPortfolioProject..NashvilleHousing nh2
	On nh1.ParcelID = nh2.ParcelID
	And nh1.[UniqueID ] <> nh2.[UniqueID ]
	where nh1.PropertyAddress is null


Update nh1
Set PropertyAddress = ISNULL(nh1.PropertyAddress, nh2.PropertyAddress)
	from SQLPortfolioProject..NashvilleHousing nh1
	join SQLPortfolioProject..NashvilleHousing nh2
		On nh1.ParcelID = nh2.ParcelID
		And nh1.[UniqueID ] <> nh2.[UniqueID ]
		where nh1.PropertyAddress is null

Select Substring(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) as Address,
		Substring(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, Len(PropertyAddress)) as City
from SQLPortfolioProject..NashvilleHousing

Alter table NashvilleHousing
Add
	PropertyAddressOnly  nvarchar(500);

Update NashvilleHousing
Set
	PropertyAddressOnly = Substring(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) 


Alter table NashvilleHousing
Add
	PropertyCity nvarchar(500);

Update NashvilleHousing
Set
	PropertyCity = Substring(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, Len(PropertyAddress))

Select PropertyAddressOnly, PropertyCity
from SQLPortfolioProject..NashvilleHousing


Select * from SQLPortfolioProject..NashvilleHousing

------------------------------------------------------------------------------

Select OwnerAddress
from SQLPortfolioProject..NashvilleHousing

Select 
	Parsename(Replace(OwnerAddress, ',', '.'), 3),
	Parsename(Replace(OwnerAddress, ',', '.'), 2),
	Parsename(Replace(OwnerAddress, ',', '.'), 1)
from SQLPortfolioProject..NashvilleHousing


Alter table NashvilleHousing
Add
	OwnerAddressOnly nvarchar(500);

Update NashvilleHousing
Set
	OwnerAddressOnly = Parsename(Replace(OwnerAddress, ',', '.'), 3)


Alter table NashvilleHousing
Add
	OwnerAddressCity nvarchar(500);

Update NashvilleHousing
Set
	OwnerAddressCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)


Alter table NashvilleHousing
Add
	OwnerAddressState nvarchar(500);

Update NashvilleHousing
Set
	OwnerAddressState = Parsename(Replace(OwnerAddress, ',', '.'), 1)

------------------------------------------------------------------------------------

Select SoldAsVacant, COUNT(SoldAsVacant) as sold
from SQLPortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order By sold

Select SoldAsVacant, 
	Case When SoldAsVacant = 'y' Then 'Yes'
	     When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
	End
from SQLPortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant =
	Case When SoldAsVacant = 'y' Then 'Yes'
	     When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
	End

---------------------------------------------------------------------------------------

With RowNumCTE AS(
Select *,
	ROW_NUMBER() Over (
			Partition By ParcelId,
						 PropertyAddress,
						 SalePrice,
						 SaleDate,
						 LegalReference
						 Order BY
							UniqueID
							) row_num
from SQLPortfolioProject..NashvilleHousing
)

Select *
from RowNumCTE
Where row_num > 1
Order By PropertyAddress


--------------------------------------------------------------------------------------------

Select *
from SQLPortfolioProject..NashvilleHousing

Alter Table  SQLPortfolioProject..NashvilleHousing
	Drop Column OwnerAddress, PropertyAddress
