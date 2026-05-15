USE [No_show];

SELECT * FROM [dbo].[Appointments];

-----------------------------------
-- CHECK TOTAL RECORDS
SELECT COUNT(*) AS TotalRecords FROM Appointments;

CREATE VIEW vw_TotalAppointments
AS
SELECT COUNT(*) AS TotalRecords
FROM Appointments;


-----------------------------------
-- CHECK FOR INVALID AGES
SELECT COUNT(*) AS InvalidAge
FROM Appointments WHERE Age < 0;

------------------------------------
-- REMOVE INVALID ROWS
DELETE FROM Appointments WHERE Age<0;

------------------------------------
--CHECK DATE ISSUES(APPOINTMENT BEFORE SCHEDULED)
SELECT COUNT(*) AS InvalidDates
FROM Appointments
WHERE AppointmentDay < ScheduledDay;

------------------------------------
--Check actual invalid dates 
SELECT COUNT(*) AS ActualInvalidDates
FROM Appointments
WHERE CAST(AppointmentDay AS DATE) < CAST(ScheduledDay AS DATE);
------------------------------------
-- delete truely invalid rows
DELETE FROM Appointments
WHERE CAST(AppointmentDay AS DATE) < CAST(ScheduledDay AS DATE);
------------------------------------
-- test WaitDays calculation.
SELECT TOP 10
    AppointmentID,
    CAST(ScheduledDay AS DATE) AS ScheduledDate,
    CAST(AppointmentDay AS DATE) AS AppointmentDate,
    DATEDIFF(DAY, 
        CAST(ScheduledDay AS DATE), 
        CAST(AppointmentDay AS DATE)
    ) AS WaitDays
FROM Appointments;

-----------------------------------

-- Q1. What is the Overall no- show  rate ?

SELECT 
  No_show,
  COUNT(*) AS Count,
  ROUND(COUNT(*) * 100.0/SUM(COUNT(*))OVER(),2) AS Percentage
FROM Appointments
GROUP BY No_show;

===============
GO

CREATE OR ALTER VIEW vw_Gender_Analysis AS
SELECT 
    Gender,
    COUNT(*) AS TotalAppointments,
    SUM(CASE WHEN CAST(No_show AS VARCHAR(10)) IN ('1', 'True', 'Yes') THEN 1 ELSE 0 END) AS NoShows,
    ROUND(
        SUM(CASE WHEN CAST(No_show AS VARCHAR(10)) IN ('1', 'True', 'Yes') THEN 1.0 ELSE 0.0 END) * 100.0 
        / NULLIF(COUNT(*), 0), 2
    ) AS NoShowRate
FROM Appointments
GROUP BY Gender;

GO
-----------------------------------
-- Q2. HOW MANY UNIQUE PATIENTS VS APPOINTSMENTS?.
SELECT 
  COUNT(DISTINCT PatientId) AS UniquePatients,
  COUNT(AppointmentID) AS TotalAppointments,
  ROUND(COUNT(AppointmentID)*1.0/
     COUNT(DISTINCT PatientId),2) AS AvgAppointmentsPerPatient
FROM appointments;

---
CREATE VIEW vw_AppointmentStats
AS
SELECT 
  COUNT(DISTINCT PatientId) AS UniquePatients,
  COUNT(AppointmentID) AS TotalAppointments,
  ROUND(COUNT(AppointmentID)*1.0 /
        COUNT(DISTINCT PatientId), 2) AS AvgAppointmentsPerPatient
FROM appointments;

-----------------------------------
-- Q3.WHAT IS THE GENDER WISE NO-SHOW RATE?.
SELECT 
  Gender,
  COUNT(*) AS TotalAppointments,
  SUM(CASE WHEN No_show = 1 THEN 1 ELSE 0 END) AS NoShows,
  ROUND(SUM(CASE WHEN No_show = 1 Then 1 ELSE 0 END) * 100.0/COUNT(*),2) AS NoShowRate
FROM Appointments
GROUP BY Gender;

-----------------------------------
-- Q4. What is the Age Distribution of Patients?
SELECT 
    AgeGroup,
    COUNT(*) AS TotalAppointments,
    SUM(CASE WHEN No_show = 1 THEN 1 ELSE 0 END) AS NoShows,
    ROUND(SUM(CASE WHEN No_show = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS NoShowRate
FROM (
    SELECT *,
        CASE 
            WHEN Age BETWEEN 0 AND 17 THEN 'Child(0-17)'
            WHEN Age BETWEEN 18 AND 34 THEN 'Young Adult(18-34)'
            WHEN Age BETWEEN 35 AND 54 THEN 'Adult(35-54)'
            WHEN Age BETWEEN 55 AND 74 THEN 'Senior(55-74)'
            ELSE '75+' 
        END AS AgeGroup
    FROM Appointments
) AS SubQuery
GROUP BY AgeGroup
ORDER BY NoShowRate DESC;

-------------------------------------
-- Q5 Which Neighbourhoods have the heighest no-show count?.
select top 15
   Neighbourhood,
   count(*) as TotalAppointments,
   sum(case when No_show = 1 then 1 else 0 end) as NoShows,
   round(sum(case when No_show = 1 then 1 else 0 end)* 100.0
      /count(*),2) as NoShowRate
from Appointments
group by Neighbourhood
order by NoShows desc;

--------------------------------------
-- Q6.Does receiving an sms reminder reduce no-shows?.
select 
  SMS_received,
  count(*) as TotalAppointments,
  sum(case when No_show = 1 then 1 else 0 end) as NoShows,
  Round(sum(case when No_show = 1 then 1 else 0 end)*100.0
   /count(*),2)as NoShowRate
 from Appointments
 group by SMS_received;

 ---------------------------------------
 -- Q7. What day of the week has the most no-shows?.
 select 
   DATENAME(WEEKDAY, AppointmentDay) as DayOfWeek,
   Count(*) as TotalAppointments,
   sum(case when No_show = 1 then 1 else 0 end)as NoShows,
   round(sum(case when No_show = 1 then 1 else 0 end ) * 100.0
     /count(*),2) as NoShowRate
from Appointments
group by DATENAME(WEEKDAY,AppointmentDay)
order by NoShows desc;

-----------------------------------------
--Q8.How many patients have chronic conditions?.
select 
   sum(cast(Hipertension as int)) as HypertensionCourt,
   sum(cast(Diabetes as int)) as DiabetesCount,
   sum(cast(Alcoholism as int)) as AlcoholismCount,
   sum(cast(Handcap as int)) as HandicapCount,
   sum(cast(Scholarship as int)) as WelfareCount,
   count(*) as TotalPatients
from Appointments;

-----------------------------------------
-- Q9 Does Waiting time affect no-show rate?.
select 
   case 
     when DATEDIFF(day, scheduledDay, AppointmentDay) = 0 then 'Same Day'
     when DATEDIFF(day, scheduledDay, AppointmentDay) between 1 and 7 then '1-7 Days'
     when DATEDIFF(day, scheduledDay, AppointmentDay) between 8 and 30 then '8-30 Days'
     else 'More than 30 Days'
    end as WaitingPeriod,
    count(*) as TotalAppointments,
    sum(case when No_show = 1 then 1 else 0 end) as NoShows,
    round(sum(case when No_show = 1 then 1 else 0 end) * 100.0
     /count(*), 2) as NoShowRate
from Appointments
group by
  case 
   when DATEDIFF(DAY,ScheduledDay, AppointmentDay) = 0 then 'Same Day'
   when DATEDIFF(DAY,ScheduledDay, AppointmentDay) between 1 and 7 then '1-7 Days'
   when DATEDIFF(DAY,ScheduledDay, AppointmentDay) between 8 and 30 then '8-30 Days'
   else 'More than 30 Days'
  end
order by NoShowRate desc;

-------------------------------------------
-- Q10. D0 chronic disease patients show up more reliably?.
select 
  case 
    when Hipertension = 1 and Diabetes = 1 then 'Both Conditions'
    when Hipertension = 1 then 'Hypertension Only'
    when Diabetes = 1 then 'Diabetes Only'
    else 'No Conditions'
  end as ConditionGroup,
  count(*) as TotalAppointments,
  sum(case when No_show = 1 then 1 else 0 end) as NoShows,
  Round(sum(case when No_show = 1 then 1 else 0 end) * 100.0
   /count(*),2) as NoShowRate
from Appointments
group by
  case 
   when Hipertension = 1 and Diabetes = 1 then 'Both Conditions'
   when Hipertension = 1 then 'Hypertension Only'
   when Diabetes =1 then 'Diabetes Only'
   else 'No Conditions'
end
order by NoShowRate desc;


----------------------------------------
-- Q11. Monthly trend of appointments and no-show.
SELECT 
    FORMAT(CAST(AppointmentDay AS DATE), 'yyyy-MM') AS YearMonth,
    COUNT(*) AS TotalAppointments,
    SUM(CASE WHEN No_show = 1 THEN 1 ELSE 0 END) AS No_shows,
    ROUND(SUM(CASE WHEN No_show = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS NoShowRate
FROM Appointments
GROUP BY FORMAT(CAST(AppointmentDay AS DATE), 'yyyy-MM')
ORDER BY YearMonth;

-----------------------------------------
-- Q12. Which neighbourhood has worst no- show rate (Minimum 100 Appointments)?.
select top 10 
    [Neighbourhood],
    count(*) as TotaAppointments,
    sum(case when No_show = 1 then 1 else 0 end) as NoShows,
    round(sum(case when No_show = 1 then 1 else 0 end) * 100.0
      / count(*),2) as NoShowRate
from Appointments
group by [Neighbourhood]
having count(*) >= 100
order by NoShowRate desc;

------------------------------------------
--Q13. welfare patients (scholarship) vs regular -- who no-show more?.
select 
  case when Scholarship = 1 then 'Welfare Patient1' else 'Regular Patient' End as PatientType,
  count(*) as TotalAppointments,
  sum(case when No_show = 1 then 1 else 0 end) as NoShows,
  round(sum(case when No_show = 1 then 1 else 0 end) * 100.0
    / count(*),2) as NoShowRate
from Appointments
group by Scholarship;

-------------------------------------------
--Q14. Hour of scheduled booking vs no-show rate.
select
  DATEPART(HOUR, ScheduledDay) as BookingHour,
  count(*) as TotalAppointments,
  sum(case when No_show = 1 then 1 else 0 end) as NoShows,
  round(sum(case when No_show = 1 then 1 else 0 end) * 100.0
    /count(*),2) as NoShowRate
from Appointments
group by DATEPART(HOUR, ScheduledDay)
order by BookingHour;

--------------------------------------------
--Q15. How Many Patients are repeat no-shows?.

select
   NoShowCount,
   count(distinct PatientId) as PatientCount
 from(
   select
     patientId,
     sum(case when No_show = 1 then 1 else 0 end) as NoShowCount
  from Appointments
  group by PatientId
 ) as PatientNoShows
 group by NoShowCount
 order by NoShowCount;

 --------------------------------------------
 --Q16. Rank neighbourhoods by no-show rate using window function.?
select 
  Neighbourhood,
  TotalAppointments,
  NoShows,
  NoShowRate,
  rank()over(order by NoShowRate desc) as NoShowRank,
  rank()over(order by TotalAppointments desc) as VolumeRank
from(
  select 
     Neighbourhood,
     count(*) as TotalAppointments,
     sum(case when No_show = 1 then 1 else 0 end) as NoShows,
     round(sum(case when No_show = 1 then 1 else 0 end)* 100.0
       /count(*),2) as NoShowRate
from Appointments
where Neighbourhood is not null
group by Neighbourhood 
having count(*) >= 100
) as Neighbour4hoodStats
Order by NoShowRank;


-----------------------------------------------
--Q17. Running total of no -shows over time?.
with DailyNoShow as(
   select
     AppointmentDay,
     count(*) as DailyAppointments,
     sum(case when No_show = 1 then 1 else 0 end) as DailyNoShows
    from Appointments
    group by AppointmentDay
)
select 
  AppointmentDay,
  DailyAppointments,
  DailyNoShows,
  sum(DailyNoShows)over(order by AppointmentDay) as RunningTotalNoShows,
  sum(DailyAppointments)over(order by AppointmentDay) as RunningTotalAppointments
from DailyNoShow
order by AppointmentDay;

---------------------------------------------
--Q18. Month-over-month no-show rate change.
WITH MonthlyStats AS (
    SELECT 
        FORMAT(CAST(AppointmentDay AS DATE), 'yyyy-MM') AS YearMonth,
        COUNT(*) AS TotalAppointments,
        ROUND(SUM(CASE WHEN No_show = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS NoShowRate
    FROM Appointments
    GROUP BY FORMAT(CAST(AppointmentDay AS DATE), 'yyyy-MM')
)
SELECT 
    YearMonth,
    TotalAppointments,
    NoShowRate,
    LAG(NoShowRate) OVER(ORDER BY YearMonth) AS PrevMonthRate,
    ROUND(NoShowRate - LAG(NoShowRate) OVER(ORDER BY YearMonth), 2) AS RateChange
FROM MonthlyStats
ORDER BY YearMonth;


-----------------------------------------------------
--Q19.Patient risk score - identify highest risk patients.

WITH PatientRisk AS (
    SELECT
        PatientId,
        Gender,
        Age,
        COUNT(AppointmentID) AS TotalAppointments,
        SUM(CASE WHEN No_show = 1 THEN 1 ELSE 0 END) AS TotalNoShows,
        ROUND(SUM(CASE WHEN No_show = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(AppointmentID), 2) AS NoShowRate,
        MAX(CAST(Hipertension AS INT)) AS HasHypertension,
        MAX(CAST(Diabetes AS INT)) AS HasDiabetes,
        MAX(CAST(Scholarship AS INT)) AS IsWelfare,
        AVG(DATEDIFF(DAY, CAST(ScheduledDay AS DATE), CAST(AppointmentDay AS DATE))) AS AvgWaitDays
    FROM Appointments
    GROUP BY PatientId, Gender, Age
    HAVING COUNT(AppointmentID) >= 3
)
SELECT TOP 20
    PatientId,
    Age,
    TotalAppointments,
    TotalNoShows,
    NoShowRate,
    AvgWaitDays,
    RANK() OVER (ORDER BY NoShowRate DESC, TotalNoShows DESC) AS RiskRank
FROM PatientRisk
ORDER BY RiskRank;

-----------------------------------------------------------------
--Q20. Does SMS + Short Wait = best Attendance?

   WITH FactorAnalysis AS (
    SELECT 
        SMS_received,
        CASE 
            WHEN DATEDIFF(DAY, CAST(ScheduledDay AS DATE), CAST(AppointmentDay AS DATE)) <= 7 THEN 'Short Wait'
            ELSE 'Long Wait'
        END AS WaitCategory,
        COUNT(*) AS TotalAppointments,
        SUM(CASE WHEN No_show = 1 THEN 1 ELSE 0 END) AS NoShows,
        ROUND(SUM(CASE WHEN No_show = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS NoShowRate
    FROM appointments
    GROUP BY 
        SMS_received,
        CASE 
            WHEN DATEDIFF(DAY, CAST(ScheduledDay AS DATE), CAST(AppointmentDay AS DATE)) <= 7 THEN 'Short Wait'
            ELSE 'Long Wait'
        END
)
SELECT 
    CASE WHEN SMS_received = 1 THEN 'SMS Sent' ELSE 'No SMS' END AS SMSStatus,
    WaitCategory,
    TotalAppointments,
    NoShows,
    NoShowRate,
    RANK() OVER(ORDER BY NoShowRate ASC) AS BestCombinationRank
FROM FactorAnalysis
ORDER BY NoShowRate;

-----------------------------------------------------------------------
--Q21. Find patients who Always no-show(100% no-show rate , 3+ appointments).

WITH PatientHistory AS (
    SELECT
        PatientId,
        COUNT(AppointmentID) AS TotalAppointments,
        SUM(CASE WHEN No_show = 1 THEN 1 ELSE 0 END) AS TotalNoShows
    FROM appointments
    GROUP BY PatientId
    HAVING COUNT(AppointmentID) >= 3
)
SELECT 
    PatientId,
    TotalAppointments,
    TotalNoShows,
    ROUND(TotalNoShows * 100.0 / TotalAppointments, 2) AS NoShowRate
FROM PatientHistory
WHERE TotalNoShows = TotalAppointments
ORDER BY TotalAppointments DESC;

---------------------------------------------------------------------
--Q22. NTILE --Segment patient into 4 risk groups.

WITH PatientNoShowRate AS (
    SELECT
        PatientId,
        COUNT(AppointmentID) AS TotalAppointments,
        SUM(CASE WHEN No_show = 1 THEN 1 ELSE 0 END) AS TotalNoShows,
        ROUND(SUM(CASE WHEN No_show = 1 THEN 1 ELSE 0 END) * 100.0 
              / COUNT(AppointmentID), 2) AS NoShowRate
    FROM appointments
    GROUP BY PatientId
    HAVING COUNT(AppointmentID) >= 2
)
SELECT
    PatientId,
    TotalAppointments,
    TotalNoShows,
    NoShowRate,
    NTILE(4) OVER(ORDER BY NoShowRate DESC) AS RiskSegment,
    CASE NTILE(4) OVER(ORDER BY NoShowRate DESC)
        WHEN 1 THEN 'High Risk'
        WHEN 2 THEN 'Medium Risk'
        WHEN 3 THEN 'Low Risk'
        WHEN 4 THEN 'Very Low Risk'
    END AS RiskLabel
FROM PatientNoShowRate
ORDER BY NoShowRate DESC;

-----------------------------------------------------------
--Q23. Rolling 7- day no-show rate.
WITH DailyStats AS (
    SELECT
        CAST(AppointmentDay AS DATE) AS ApptDate, -- Cast to Date for proper sorting
        COUNT(*) AS DailyTotal,
        SUM(CASE WHEN No_show = 1 THEN 1 ELSE 0 END) AS DailyNoShows
    FROM appointments
    GROUP BY AppointmentDay
)
SELECT
    ApptDate,
    DailyTotal,
    DailyNoShows,
    SUM(DailyNoShows) OVER(
        ORDER BY ApptDate
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS Rolling7DayNoShows,
    SUM(DailyTotal) OVER(
        ORDER BY ApptDate
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS Rolling7DayTotal
FROM DailyStats
ORDER BY ApptDate;
