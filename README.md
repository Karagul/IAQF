# IAQF
Machine Learning model implementation to predict credit spreads

The ML model selects features from a list compiled by the developers (Team Scarlett Quants - IAQF Academic Competition 2019) to predict spreads between IG Corporate Bonds (BofAML AAA US Corporate Bond Index) and Treasuries. The spreads are duration matched by directly using the OAS of the index for each time period.

Feature Selection Modules - Extensive runtime code that tries to select the best possible features for the model from the entire list. Trials are done and features are selected based on their out-of-sample performance.

The random forest model finally settled for is a 5 predictor model, with 3 variables used at each node of the decision trees and a total of 500 decision trees in the random forest. The predictors used are:
- CDX.IG - 5Y : CDS index for IG corporates for 5 year duration CDS swaps.
- HYOAS_Spreads : OAS Spreads of the HY corporates index (
- Ind_Production : Industrial Production index data (obtained from FRED)
- Price_Ratio : Price ratio of the LQD to TLT ETFs. LQD is the IG corporates ETF, while TLT is the long term treasuries ETF. The ratio of their prices is sometimes used as a forward indicator of market movement between treasuries and corporates.
- Original_Spreads : Lagged IG corporate spreads (OAS) of the same index we are using as the output of the model.

Output and importance plots are available under Plots/
