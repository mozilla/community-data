## Running the Python Script

Steps helpful to execute the check-names.py script in credits/script (move to community-data parent directory and follow instructions given below)

* For Mac Install Python and Virtualenv along with Pip from [here](http://sourabhbajaj.com/mac-setup/Python/)
* For linux:
```
sudo apt-get install python3-dev
sudo apt-get install python3-virtualenv
```
* Once installed, create virtual environment inside the project folder and do not forget to add that name in .gitignore(this will never commit virtual environment files)
```
virtualenv -p python3 <virtual environment name>
source <virtual environment name>/bin/activate
```
* Congrats, you are in virtual environment, to deactivate just write
```
(virtual-environment)$: deactivate
```
* Install the packages:
```
pip install -r requirements.txt
```
* Now run the script,
```
cd credits/scripts
python script.py <lower bound in integer> <upper bound in integer>
# lower bound & upper bound are the row numbers, data between them (both inclusive) will be processed from the sheet
# It takes all Y entries from sheet and adds them to names.csv
# Dont forget to update sheet to mark Y entries to DONE entries after this is done
```
* Mac Commands Gist:
```
cd community-data
brew install python3
// brew update-reset (if you have issues installing python, do this and retry above command)
// brew upgrade python (if required)
brew install virtualenv
virtualenv -p python3 venv
source venv/bin/activate
cd credits/scripts/
pip install -r py-requirements.txt
python check-names.py lower-bound upper-bound
```
