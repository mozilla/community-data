# Mozilla Community Data

This repository is the canonical source of the following Mozilla community information:

* `credits/names.csv`: The comprehensive contributor list for [about:credits](https://www.mozilla.org/credits/)
* `forums/raw-ng-list.txt`: The current forum list for [mozilla.org/about/forums](https://www.mozilla.org/en-US/about/forums/)

## Running the Python Script

The following steps helps you in executing the python script in credits/python-script

* For Mac Install Python and Virtualenv along with Pip from [here](http://sourabhbajaj.com/mac-setup/Python/)
* For linux, it is simple:
```
sudo apt-get install python3-dev
sudo apt-get install python3-virtualenv
```
* Once installed, create virtual environment inside the project folder and do not forget to add that name in .gitignore(We never commit virtual environment files)
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
python script.py <lower bound in integer> <upper bound in integer>
```
