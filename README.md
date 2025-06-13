# Portfolio---02.-SQL-Examples
This project analyzes state-level health expenditure and life expectancy data using MySQL, implementing stored procedures, outlier detection, and correlation calculations to uncover insights into healthcare trends. I have created this example using public data from government websites.


Introduction

This project is a hypothetical analysis of U.S. Census Bureau and Centers for Disease Control and Prevention (CDC) data, designed to demonstrate my proficiency in SQL rather than draw definitive conclusions. By examining state-level health spending and life expectancy, it showcases my ability to design, query, and analyze complex datasets. The approach is intentionally surface-level but can be expanded into a comprehensive report with additional data and visualizations.

The Question

The core objective is to explore how state health spending impacts life expectancy. I kept the analysis straightforward to focus on SQL techniques, but the framework is adaptable for deeper investigations, such as incorporating socioeconomic factors or time-series data.

The Data

The data, sourced from the U.S. Census Bureau (2023) and CDC (2020), represents the most recent available as of mid-May 2025. It includes state-level metrics on health expenditure, life expectancy, insured and uninsured populations, and demographic details, organized into five MySQL tables: state_abbreviations, state_life_expectancy, state_expenditure, insured_by_state, and uninsured_by_state.

Import & Organize

Importing and organizing the data was more challenging than anticipated, as I typically work with pre-existing databases in my professional experience. Starting from scratch provided a valuable learning opportunity. I downloaded raw data from the Census Bureau and CDC, cleaned it in Excel to include relevant fields, and used Power Query to convert CDC’s PDF data into a usable format. To import CSVs into MySQL via VS Code, I wrote Python scripts to convert Excel files into secure CSV uploads, overcoming several technical hurdles and resulting in five structured tables.

Manipulate & Analyze

The analysis leveraged SQL to uncover insights through multiple approaches:

Correlation Coefficient: Calculated the Pearson correlation between life expectancy and health expenditure per capita using AVG, STDDEV, and covariance formulas, revealing the strength of their relationship.

Outlier Detection: Identified states with extreme health expenditures using a row-number-based interquartile range (IQR) method, bypassing PERCENTILE_CONT due to compatibility issues, and flagged outliers.

Aggregation by Category: Developed a stored procedure (AggregateByCategory) to dynamically group metrics (life expectancy, health spending, insured percentage) by region or political affiliation, using dynamic SQL (CONCAT, PREPARE, EXECUTE) for flexibility.

Ranking and Pivoting: Ranked states by life expectancy and created a multidimensional pivot table to compare metrics across categories, enhancing comparative analysis. These queries produced outputs suitable for actionable insights, demonstrating advanced SQL techniques and robust error handling.

What’s Missing

Time Series Analysis: For simplicity, I used data from a single year (2023 for Census, 2020 for CDC). A multi-year dataset would enable year-over-year comparisons to identify trends.

Visualizations: To focus on SQL, I excluded visualizations, but these could be easily added using Python or Excel.

Broader Scope: Incorporating additional variables (e.g., education, income) or real-time data could deepen the analysis, adaptable with the existing SQL framework.

Access the Project

Key code files include Weigand_Portfolio_01_HSL_Create_Import.sql, Weigand_Portfolio_02_HSL_Analysis.sql, & Convert_Secure_CSV.py. These files showcase dynamic SQL, statistical analysis, and error handling.
