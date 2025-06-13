import pandas as pd
import os
import shutil

# User inputs
excel_path = input(
    "Enter the Excel file path (e.g., C:\\Development\\02. SQL Examples\\Life Expectancy by State.xlsx): ")
excel_filename = os.path.basename(
    excel_path).strip('"')  # Remove quotes if any

# Paths
base_path = "C:\\Development\\TEMP\\"
secure_path = "C:\\ProgramData\\MySQL\\MySQL Server 9.3\\Uploads\\"
csv_filename = os.path.splitext(excel_filename)[0] + ".csv"
csv_path = os.path.join(base_path, csv_filename)
secure_csv_path = os.path.join(secure_path, csv_filename)

# Confirm Excel filename
print(f"Resolved Excel path: {excel_path}")
if input("Is this the correct Excel file path? (yes/no): ").lower() != 'yes':
    print("Please re-run the script with the correct file name.")
    exit()

# Check if Excel file exists
if not os.path.exists(excel_path):
    print(f"Error: {excel_path} does not exist.")
    exit()

print(f"Reading {excel_filename}...")
df = pd.read_excel(excel_path)

df.to_csv(csv_path, index=False, encoding='utf-8')
print(f"Saved temporary CSV to {csv_path}")

if not os.path.exists(secure_path):
    os.makedirs(secure_path)
shutil.copy2(csv_path, secure_csv_path)
print(f"Copied CSV to secure path: {secure_csv_path}")

# Clean up temporary CSV
os.remove(csv_path)
print(f"Cleaned up temporary CSV: {csv_path}")
print("Use the below link in 'Import' query of SQL code")
sql_ready_path = secure_csv_path.replace('\\', '/')
print(sql_ready_path)
