Select *
From Accidents;

Select * 
From Vehicles;


--Question 1: How many accidents have occurred in urban areas versus rural areas?

Select Area, COUNT(Area) DeathRatePerArea
From Accidents
Group By Area

--Question 2: Which day of the week has the highest number of accidents?

Select Day, COUNT(AccidentIndex) TotalAccident
From Accidents
Group By Day
Order By TotalAccident Desc 

With HighestAccidentOnDay (Day, TotalAccident) As(
Select Day, COUNT(AccidentIndex) TotalAccident
From Accidents
Group By Day)
Select * from HighestAccidentOnDay
where TotalAccident = (Select Max(TotalAccident) From HighestAccidentOnDay)

--Question 3: What is the average age of vehicles involved in accidents based on their type?

Select VehicleType, COUNT(AccidentIndex) TotalAccidents, AVG(Cast(AgeVehicle as int)) AverageAge
From Vehicles
Where AgeVehicle is not null
Group By VehicleType
Order By TotalAccidents Desc

--Question 4: Can we identify any trends in accidents based on the age of vehicles involved?

Select AgeGroupOfCar, COUNT(AccidentIndex) TotalAccidents, AVG(Cast(AgeVehicle as int)) AverageAge
From(
	Select AccidentIndex, AgeVehicle,
	Case
		When AgeVehicle Between 0 And 5 Then 'New'
		When AgeVehicle Between 6 And 10 Then 'Regular'
		Else 'Old'
	End As AgeGroupOfCar
	From Vehicles
)As SubQuery
Group By AgeGroupOfCar

--Question 5: Are there any specific weather conditions that contribute to severe accidents?

Select WeatherConditions ,Count(WeatherConditions) CountOfWeather
From Accidents
Where Severity = 'Fatal'
Group By WeatherConditions 
Order By CountOfWeather Desc

-- Alternate Query
Declare @Severity varchar(255)
Set @Severity = 'Fatal'

Select WeatherConditions ,Count(Severity) SeriousAccident
From Accidents
Where Severity = @Severity
Group By WeatherConditions 
Order By SeriousAccident Desc

-- Alternate Query using Temp Table
Declare @Severity varchar(255)
Set @Severity = 'Fatal'

Drop Table if exists #SeriouAcc
Create Table #SeriouAcc(
WeatherConditions Nvarchar(255),
SeriousAccident int
)

Insert Into #SeriouAcc
Select WeatherConditions ,Count(Severity) SeriousAccident
From Accidents
Where Severity = @Severity
Group By WeatherConditions 
Order By SeriousAccident Desc

Select * from #SeriouAcc
where SeriousAccident = (Select Max(SeriousAccident) From #SeriouAcc)

--Question 6: Do accidents often involve impacts on the left-hand side of vehicles?

Select LeftHand, COUNT(AccidentIndex) TotalAccident
From Vehicles
Where LeftHand is not null
Group By LeftHand

--Question 7: Are there any relationships between journey purposes and the severity of accidents?

Select Veh.JourneyPurpose, Count(Acc.Severity) TotalAccident,
Case
	When Count(Acc.Severity) Between 0 And 1000 Then 'Low'
	When Count(Acc.Severity) Between 1001 And 3000 Then 'Moderate'
	Else 'High'
End as Level
From Accidents Acc
Join Vehicles Veh
	On Acc.AccidentIndex = Veh.AccidentIndex
Group By Veh.JourneyPurpose
Order By TotalAccident Desc

--Question 8: Calculate the average age of vehicles involved in accidents , considering Day light and point of impact:
Declare @LightCon Varchar(255)
Set @LightCon = 'Daylight'

Select Acc.LightConditions, Veh.PointImpact, AVG(Cast(Veh.AgeVehicle as int)) AvgVehicleAge
From Accidents Acc
Join Vehicles Veh
	On Acc.AccidentIndex = Veh.AccidentIndex
Where Acc.LightConditions = @LightCon
Group By Veh.PointImpact, Acc.LightConditions
Order By AvgVehicleAge 