import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

"""
Dieses Skript exportiert die Winkelgeschwindigkeitsdaten aus einer Excel-Datei und erstellt eine Häufigkeitsverteilung.
"""

# Pfad zur Excel-Datei angeben
excel_file = r'C:\Users\Johan\OneDrive - beuthhs\Dokumente\Studium\Bachelorarbeit\Logs\105208_AngularVelocity.xlsx'

# Blattname
#sheet_name = "Gesamt" #'143120', 153846

# Die zu importierenden Spaltennamen angeben
column_names = [4,5,6]

# Die Excel-Datei lesen und die angegebenen Spalten extrahieren
df = pd.read_excel(excel_file, names=column_names, header=None, skiprows=1, usecols=column_names)

# Spalten umbenennen
df.columns = ['X', 'Y', 'Z']

# Daten filtern, um nur Werte zwischen -π und π zu behalten
df = df[(df['X'] >= -np.pi) & (df['X'] <= np.pi) &
        (df['Y'] >= -np.pi) & (df['Y'] <= np.pi) &
        (df['Z'] >= -np.pi) & (df['Z'] <= np.pi)]

# Radiant in Grad umrechnen
df = df.apply(lambda x: x * (180 / np.pi))

# Den absoluten Wert jeder Zahl berechnen
filtered_data = df.apply(lambda x: abs(x))

# Daten absteigend sortieren
sorted_data = filtered_data.apply(lambda x: sorted(x, reverse=True))

# Alle 3 Spalten in einem Diagramm plotten
plt.plot(sorted_data['X'].values.flatten(), label='X (phi)', color='r')
plt.plot(sorted_data['Y'].values.flatten(), label='Y (theta)', color='g')
plt.plot(sorted_data['Z'].values.flatten(), label='Z (psi)', color='b')

# Die obersten 5% jeder Grafik markieren
top_5_percent = int(len(sorted_data) * 0.05)
plt.axhline(sorted_data['X'].iloc[top_5_percent], color='r', linestyle='--', label='Top 5% X')
plt.axhline(sorted_data['Y'].iloc[top_5_percent], color='g', linestyle='--', label='Top 5% Y')
plt.axhline(sorted_data['Z'].iloc[top_5_percent], color='b', linestyle='--', label='Top 5% Z')

# Den letzten Wert vor der Grenze der obersten 5% für jede Grafik ausgeben
print("Letzter Wert vor der 5%-Grenze für X:", sorted_data['X'].iloc[top_5_percent - 1], "Grad")
print("Letzter Wert vor der 5%-Grenze für Y:", sorted_data['Y'].iloc[top_5_percent - 1], "Grad")
print("Letzter Wert vor der 5%-Grenze für Z:", sorted_data['Z'].iloc[top_5_percent - 1], "Grad")

# Beschriftungen und Legende hinzufügen
plt.xlabel('Datenpunkt')
plt.ylabel('Grad/Sekunde')
plt.title('Häufigkeitsverteilung der absoluten Winkelgeschwindigkeit Mission 105208')
plt.legend()
plt.grid(True)
plt.show()
