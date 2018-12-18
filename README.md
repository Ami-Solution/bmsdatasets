# Buildings Management System Datasets

[Github.com/ami-solution/bmsdatasets](https://github.com/Ami-Solution/bmsdatasets/edit/gh-pages/README.md)

[ami-solution.Github.io/bmsdatasets](https://Ami-Solution.github.io/bmsdatasets/)

This site provides a listing of datasets related to building energy use and building operations that might be useful to the  U.S. Department of Energy Building Technologies Office (BTO) research and development community.

## Issues

If an API or dataset included on this site is no longer available or is using an outdated URL, please [open a new issue](https://github.com/Ami-Solution/bmsdatasets/issues) and provide a detailed description of the problem.

## Contributions

If you have a dataset you would like to see added, please fork this repository, update the database, and open a pull request. If you are unfamiliar with this process, there are many explanations and tutorails available online, such as [this one](https://git-scm.com/book/en/v2/GitHub-Contributing-to-a-Project). 

If you are not comfortable contributing changes directly, you may also [open a new issue](https://github.com/Ami-Solution/bmsdatasets/issues) and provide the URL and details of the dataset you'd like to have added.

### How to Update the List of Data Resources

To update the list of data resources on the site, begin by opening the file data/datasets.csv. In that file, each row corresponds to a data set shown on the site. To add your data, add a new row below the existing rows and populate the columns as indicated below. 

- **status**: Populate this field with the value "1"
- **sources**: Populate this field with the string "sunshot"
- **category**: One of the three categories of data represented in the file (carefully observe the capitalization)
- **title**: A short descriptive name for the data
- **summary**: A description of the resource or available dataset(s)
- **tags**: Include one or more *lowercase* strings separated by commas that describe the data format or formats available, e.g., "xlsx", "api", or "csv, xml"
- **link**: The URL for the dataset or resource
- **contact** (optional): If you would like to be associated with the data, add your full name to this field

The remaining columns should be left blank.

Once the CSV has been updated, the JSON database used to generate the website content must be updated to match. At a command prompt, navigate to the buildingsdatasets folder and use the following command:

```
    ruby bin/csv_to_json.rb data/datasets.csv >data/datasets.json
    
    import pandas as pd
    data = pd.read_csv('energydata_complete.csv', index_col='date', parse_dates=True)
    data.head ()
 ```

Commit and push the modified CSV and JSON files and then follow the standard process, as described in the tutorial linked above, for opening a new pull request.
