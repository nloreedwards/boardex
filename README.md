# BoardEx Project

[Summary]

## Data collection/source
All data is extracted from the Wharton Research Data Services. 
- The data on board positions is downloaded from the "BoardEx - Organization - Composition of Officers, Directors and Senior Managers" section of the database and was last performed on Jun 14, 2022. We extracted all variables across the entire database, from Jan 2000 to June 2022.
- The Compustat data is downloaded from the "Compustat Daily Updates - Fundamentals Annual" section of the database. We selected consolidation level "C", both industry formats, "STD" data format, "D" population source, "USD" currency, and both company statuses when performing the extraction. We extracted a selection of variables across the entire database, from Jan 2000 to June 2022.
- A key between the Compustat and BoardEx data is also used, and is downloaded from the "CRSP/Compustat Merged - Fundamentals Annual" section of the database. The merge is performed using the companyid and year of the BoardEx data.

This data is too large to be stored on GitHub and requires a license to use, so we do not have it publicly available here.

## Data cleaning
One challenge with the BoardEx data is the variation in the titles of the board positions. While there is some standardization, many of the full titles contain multiple positions. For example, one person may have the title "CEO/Chief Intelligence Officer", while another may simply have "CEO" or "Cheif Executive Officer" as their title. Further complicating matters are instances where two roles are combined into one, like "Chief Investment & Information Officer" rather that "Chief Investment Officer" or "Chief Information OFficer". Finally, the data did not only include C-Suite positions, making it hard to track the rise of unconventional C-Suite positions, which was a goal of the project. For example, roles like "VP of Sales" or "Senior Director of Operations" were also present in the data.

To address these issues, we first tried a strategy that looked for key position titles like CEO, CFO, COO, etc. and permutations of those titles. We also removed titles that contained non-executive phrases like "VP" and "Senior Director". While this was quick to implement, we realized that we were missing a lot of the variation in titles that we were most interested in for this project, as it was difficult to construct a unique and exhaustive keyword list for each position. Therefore, we ended up using a more labor-intensive, but more accurate, strategy of hiring two research assistants to manually code the title permutations that arose in the data. To reduce the number of classifications that needed to be performed, we first extracted individual title names from longer titles, like the "CEO/Chief Intelligence Officer" case, which were always separated with a "/". We then had the RAs classify titles with up to three position codes (for instances like "Chief Investment & Information Officer"), from a more exhaustive list of relevant position titles. We also had RAs fill in an indicator for whether the position was a C-Suite position at all, which allowed use to distinguish between C-Suite roles and other roles. In total, there were about 6,500 unique titles that the RAs classified. The detailed explanation of this task and the materials given to the RAs can be found in the "classification-task" folder.

## Data merging

## Analysis
Now that the data was cleaned and merged, we could start deriving some insights from the data. We were interested in 3 main things in this data:
1. How have the composition and size of the C-Suite changed with time?
2. 
3. Which firms are expanding/changing their C-Suite positions the most?

To answer these questions, we use a combination of exploratory data analysis and linear models.

### Exploratory Analysis
To get a sense of how the C-Suite has changed over time, we first aggregate the data to the company-level to look at the average number of C-Suite positions over time. A simple timeseries shows that the number of C-Suite positions in the data has increased over time.
![num_positions_over_time_compu](https://user-images.githubusercontent.com/87092030/214356626-f212ab49-09a1-47e4-bd94-92a848dab691.png)

One explanation for this increase could be that the composition of companies is changing with time, so we also check the timeseries on a balanced sample:
![num_positions_over_time_compu_bal](https://user-images.githubusercontent.com/87092030/214356674-d3e92c89-b979-45f2-829b-08ce2170b74f.png)

To understand if outliers are dirivng these changes, we look at the distributions of the number of C-Suite positions, by company, in 2000 and 2020:
![hist_num-positions](https://user-images.githubusercontent.com/87092030/214354340-d12c750c-1b79-4d7c-9078-4254275cd222.png)

From these figures, we see that the C-Suite, on average, is growing in size over time and that this growth is not driven by the composition of companies changing or the presence of outliers. Instead, the 2020 histogram appears flatter than the 2000 histogram, representing greater variation in the number of positions in the later year.

Now that we know the size of the C-Suite is changing, we can evaluate which positions specifically are driving these changes. This is the benefit of having the positions classified. To get a sense of the general trends, we produce Table 1 in the attached file.

