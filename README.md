# Census Voter Data

The [US Census Bureau](http://www.census.gov/) collects statistics related to voter turnout during election years.
It's in [Excel](http://www.census.gov/data/tables/time-series/demo/voting-and-registration/voting-historical-time-series.html).
This dataset is the same data cleaned, rearranged, and put into plaintext csv.

## Columns

Each row in the dataset represents a single state's voter statistics for a given election year.

| column                 | type    | description                                                  |
| ---------------------- | ------- | ------------------------------------------------------------ |
| `state`                | `str`   | The state.                                                   |
| `year`                 | `int`   | The year of the election.                                    |
| `voter_pct_of_total`   | `float` | The percentage of the state's population who voted.          |
| `voter_pct_of_citizen` | `float` | The percentage of the state's citizens who voted.            |
| `reg_pct_of_total`     | `float` | The percentage of the state's population registered to vote. |
| `reg_pct_of_citizen`   | `float` | The percentage of the state's citizens registered to vote.   |

## Building the Dataset

The dataset can be rebuilt from the source data if desired.
The source data is located in `assembly/raw_data/`.
The spreadsheets that were used to create the raw data are as follows:

* A-3 (Congressional year voter and registration data by state).
* A-5a (Presidential year voter data by state).
* A-5b (Presidential year registration data by state).

You can take a look at them [here](http://www.census.gov/data/tables/time-series/demo/voting-and-registration/voting-historical-time-series.html).
If you do, you'll notice those aren't nice spreadsheets.
I did do some rearranging to make them useful:

1. Delete any rows that were blank or that contained notes.
2. For the presidential year data cut and pasted the "wrapped" entries onto the end of the first set of years so they're all on the same row.
3. Put the year number in front of the `Total` and `Citizen` sub-headers and deleted the row that contains just the year. This basically flattens the hierarchical header onto one row.

That's really it. 
The rest of the building is done in an R script, `assembly/build.R`. 
To run it you need the [tidyverse](http://tidyverse.org/) library.
From the `assembly/` directory,

```
Rscript build.R
```

will place the completed dataset in the root directory of the repo (one level up from where it was executed).