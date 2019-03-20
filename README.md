# IAQF
Machine Learning model implementation to predict credit spreads

The ML model selects features from a list compiled by the developers (Team Scarlett Quants - IAQF Academic Competition 2019) to predict spreads between IG Corporate Bonds (BofAML AAA US Corporate Bond Index) and Treasuries. The spreads are duration matched by directly using the OAS of the index for each time period.

Feature Selection Modules - Extensive runtime code that tries to select the best possible features for the model from the entire list. Trials are done and features are selected based on their out-of-sample performance.
