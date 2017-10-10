import csv
import requests
import sys

def process_credits(lower_bound, upper_bound, names_to_be_added, names_added, emails):
	
	response_data_url  = "https://docs.google.com/spreadsheet/ccc?key=0AtLNtYDDyKsudFNTSFR2WlFuOFpUQ2N2bXpPLUFTUnc&output=csv"

	with requests.Session() as s:
		download = s.get(response_data_url)
		decoded_content = download.content.decode('utf-8')
		data = csv.reader(decoded_content.splitlines(), delimiter=',')
		for row in (r for i, r in enumerate(data) if lower_bound<=i<=upper_bound):
			if row[-1] == 'Y':
				data = "{name},{sortkey},{email}".format(name=row[1], sortkey=row[2], email=row[3])
				names_to_be_added.append(data)

	with open('names.csv', 'r') as names:
		data_name = csv.reader(names)
		for to_add_name in names_to_be_added:
			flag = False
			for data in data_name:
				if data[0] == to_add_name.split(',')[0]:
					flag = True
					break
			if flag == False:
				emails.append(to_add_name.split(',')[2])
				names_added.append((',').join(to_add_name.split(',')[0:2]))
			else:
				# If one entry is found to be existing in names.csv, it will simply ignore this and proceed with next one after printing this.
				print("Found duplicate name - {name}".format(name=to_add_name.split(',')[0]), " - Skipping this entry and proceeding.")

	with open('names.csv', 'a') as names:
		for name in names_added:
			names.write(name+'\n')
		# Printing count and email ids at the end.
		print("Total number of names added: ", len(emails))
		print("Email IDs to send mails to: ", emails)

if __name__ == "__main__":
	lower_bound = sys.argv[1]
	upper_bound = sys.argv[2]
	names_to_be_added = []
	names_added = []
	emails = []
	# lower_boud and upper_bound are substracted by 1 to ignore first heading row from excel file. 
	# Providing 2 & 3 as inputs to this script will process first & second entry of excel sheet as they are the ones in row 2 & 3 of excel sheet.
	process_credits(int(lower_bound)-1, int(upper_bound)-1, names_to_be_added, names_added, emails)
