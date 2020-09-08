
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   Data_Set  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
The .csv files are the data set used in assignment anything mentioned as "output***.csv" files has predicted output.

The following are the input data that has been widely used.

*** "mealAmountData#.csv" contains calories consumed each day.
*** "mealData#.csv" consists of CGM time series data at every 5 mins gap in a day (when a person consumed food)
*** "noMealData#.csv" consists of CGM time series data at every 5 mins gap in a day (when a person didn't consume the food.

The data has not been disclosed due to copyrights, MAYO clinic has been primary data source

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ASSIGNMENT 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

1.	Extracted 4 different types of time series features from only the CGM data cell array and CGM timestamp cell array 
2.	Inutution behind the selection of these features has been validated
3.	Created a feature matrix where each row is a collection of features from each time series. 
For example: If there are 75 time series and your feature length after concatenation of the 4 types of featues is 17 then the feature matrix size will be 75 X 17
4.	Provided this feature matrix to PCA and derive the new feature matrix.
This helped to choose the top 5 features that could completely explain the data and plot them for each time series.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ASSIGNMENT 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


1.	Extracted the features from Meal and No Meal data
2.	Trained a separate machine to recognize Meal or No Meal data
3.	Used k fold cross validation on the training data to evaluate the recognition systems
4.	Wrote a function that takes one test sample as input and outputs 1 if it predicts the test sample as meal or 0 if it predicts test sample as No meal. 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ASSIGNMENT 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

"TrainingFile.m" is used to extract features, allocate bins based on cost matrix of relativity with ground truth
 and models have been trained using these features with class variables.

***Note: a new data cannot be trained effectively as the Minpoints and Epsilon values are only decided for this particular data.
  
		*There are several functions used in this script one such function for linear bin alignment
based on weightage matrix generated is present in "lapjv.m" matfile (Jonker-Volgenant Algorithm for Linear Assignment Problem)

		*"kmeansmodel.mat" is a matab model file for Kmeans - KNN classifier.
		*"kmeansfeat.mat" contains feature matrix used to train Kmeans - KNN classifier.

		*"dbscanmodel.mat" is a matab model file for DBSCAN - KNN classifier.
		*"dbscanfeat.mat" contains feature matrix used to train DBSCAN - KNN classifier.

"Testfile.m" is the script which is required to run to generate the output matrix.

		****** Column1 of Outputmatrix - Kmeans Classifier result******
		****** Column2 of Outputmatrix - DBSCAN Classifier result******