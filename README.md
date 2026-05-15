# 🏥 Healthcare Appointment No-Show Analytics

## 📌 Project Overview
This end-to-end Healthcare No-Show Analytics project analyzes *110,522 patient appointments* to identify patterns, risk factors, and operational inefficiencies driving a *20.19% no-show rate*. Built using SQL for data modeling and Power BI for visualization, the project delivers actionable insights for healthcare administrators across 4 interactive dashboard pages.

---

## 📊 Dashboard Pages

### 📄 Page 1 — Operation Overview
| KPI | Value |
| :--- | :--- |
| *Total Appointments* | 110,522 |
| *Total No-Shows* | 22,314 |
| *No-Show Rate* | 20.19% |
| *SMS Reminders Sent* | 35,482 |
| *Unique Patients* | 61,744 |

* *Key Visuals:* Appointments by SMS Status, Appointments by Weekday, Attendance Breakdown (Donut Chart), Monthly Booking Trend (April–June 2016, peak at 80,836 in May).
* *Operational Note:* Wednesday is the busiest day with 25,866 appointments. Saturday has near-zero volume (39).

### 📄 Page 2 — Patient Demographics
* *Age vs Absenteeism:*
  * *Young Adult (18–34):* 29.65% — Highest risk
  * *Child (0–17):* 26.30%
  * *Senior (55–74):* 21.30%
  * *Adult (35–54):* 19.90%
  * *75+:* 12.80% — Most reliable
* *Gender Risk:* Males at 23.99% vs. Females at 20.27%
* *Medical Impact:* No Conditions: 87K | Hypertension Only: 15K | Both Conditions: 6K | Diabetes Only: 1K
* *Welfare vs Regular:* Regular patients show a higher attendance score of 21.35.

### 📄 Page 3 — Location & Time
* *Top Locations by No-Show Rate:*
  * Ilha Das Caieiras: 33.21% | Santos Reis: 32.52% | Santos Dumont: 31.08%
* *Wait Time vs No-Show Rate:*
  * *Same Day:* 4.56%
  * *1–7 Days:* 23.43%
  * *8–30 Days:* 31.55%
  * *30+ Days:* 32.30%

### 📄 Page 4 — Risk Analysis
| Risk Level | Appointments | Patients |
| :--- | :--- | :--- |
| *Very Low Risk* | 43,000 | 14,600 |
| *Medium Risk* | 13,000 | 5,300 |
| *Low Risk* | 12,000 | 3,000 |
| *High Risk* | 3,000 | 1,200 |

---

## 🛠️ Tools & Technologies
| Layer | Technology |
| :--- | :--- |
| *Data Storage* | SQL Server / MySQL |
| *Data Transformation* | SQL (Views, CTEs, Window Functions) |
| *Visualization* | Microsoft Power BI |
| *Calculations* | DAX (Measures & Calculated Columns) |
| *Risk Scoring* | SQL-based rule logic |

---

## ⚙️ Key SQL Techniques Used
* *CTEs* for multi-step transformations
* *Window Functions* (ROW_NUMBER, RANK) for patient segmentation
* *CASE WHEN* for wait-time bucketing and risk label assignment
* *Aggregations* with GROUP BY for KPI computation
* *Views* (vw_Dashboard_*) to serve each dashboard page cleanly

---

## 💡 Key Insights
* *Wait time is the strongest predictor:* Same-day appointments have only a 4.56% no-show rate, but 30+ day wait times jump to 32.30%.
* *SMS reminders are underused:* Only 32% (35,482) of appointments received a reminder. Expanding this is the highest-impact fix.
* *Young Adults (18–34) are high risk:* This group has the highest no-show rate (29.65%) and should be the primary target for reminders.
* *Geographic Clusters:* Three neighborhoods (Ilha Das Caieiras, Santos Reis, Santos Dumont) exceed a 31% no-show rate.
* *Efficient Targeting:* Most patients are Low Risk; clinic staff can focus outreach specifically on the 3K "High Risk" appointments to save time.

---

## 📈 Business Recommendations
1. *Prioritize SMS reminders* for all patients with a wait time of 8+ days.
2. *Target Young Adults (18–34)* and Male patients with personalized follow-up calls.
3. *Deploy outreach programs* in high-risk zones like Ilha Das Caieiras and Santos Reis.
4. *Flag High-Risk patients* in the system for proactive verification calls 24 hours before the appointment.
5. *Optimize Scheduling:* Introduce more same-day slots for chronic condition patients to bypass long wait times.

---

## 🗃️ Dataset Information
* *Source:* Kaggle — Medical Appointment No-Shows
* *Time Period:* April 2016 – June 2016
* *Total Records:* 110,522
* *Geography:* Vitória, Espírito Santo, Brazil

---

## 🚀 How to Run
1. Clone this repository.
2. Run SQL scripts: data_cleaning.sql → feature_engineering.sql → views.sql.
3. Open Healthcare_NoShow.pbix in Power BI Desktop.
4. Refresh data and explore the dashboards.

---

## 👤 Author
*Arpit*
Aspiring Data Analyst 
 

*LinkedIn: https://www.linkedin.com/in/arpit-amale-89796a27b?utm_source=share_via&utm_content=profile&utm_medium=member_android

*GitHub: https://github.com/ArpitAmale 

*Email: arpitamale100@gmail.com

