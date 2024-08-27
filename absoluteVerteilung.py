import math

import matplotlib.pyplot as plt
import pandas as pd

# Read the Excel file
data = pd.read_excel(r'C:\Users\Johan\OneDrive - beuthhs\Dokumente\Studium\Bachelorarbeit\Logs\105208_Euler.xlsx', usecols=[0])
data.columns = ['value']
# Delete numbers bigger than pi and smaller than -pi
filtered_data = data[(data.iloc[:, 0] <= math.pi) & (data.iloc[:, 0] >= -math.pi)]
# Convert radians to degrees
filtered_data = filtered_data.iloc[:, 0].apply(lambda x: math.degrees(x))
# Round data to 2 decimal places
filtered_data = filtered_data.round(2)
# Convert data to absolute values
filtered_data = filtered_data.apply(lambda x: abs(x))
# Sort the data in descending order
sorted_data = sorted(filtered_data, reverse=True)
#print(sorted_data)

top_5_percent = filtered_data.quantile(0.95)
# Mark the top 5% values on the plot
plt.axhline(top_5_percent, color='r', linestyle='--', label='Top 5%')
# Find the last number before the top and bottom 5%
last_number_before_top_5 = filtered_data[filtered_data < top_5_percent].max()
print("Letzer Wert vor top 5%:", last_number_before_top_5, "Grad")

plt.legend()
plt.grid(True)
plt.plot(sorted_data)
plt.xlabel('Datenpunkt')
plt.ylabel('Grad/Sekunde')
plt.title('Häufigkeitsverteilung der absoluten Winkel')
plt.show()