Feature Selection

The code runs a simple random forest model using different combinations from the list of features and selects the combination with the best out-of-sample prediction rate. This is done both based on the number of features (i.e. best combination for 1 feature model, 2 feature model ... n feature model), as well as on all possible combinations (i.e. best combination among all 2^19 feature selections).

The code generates 20 CSV files - 19 for combinations of different cardinalities + 1 for the best combination out of all possible cardinalities.
