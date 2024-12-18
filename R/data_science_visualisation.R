# Install the tidyverse package which contains multiple useful packages for data manipulation and visualization
install.packages('tidyverse')
# Load the tidyverse package into the current R session
library(tidyverse)

# Read historical season data from CSV file into all_season dataframe
all_season=read.csv('/Users/tranduc/Documents/Data Science/Data/all_seasons.csv')
# Display all_season dataframe in a separate viewer window
View(all_season)
# Read 2023 season data from CSV file into season_23 dataframe
season_23=read.csv('/Users/tranduc/Documents/Data Science/Data/season_23.csv')
# Display season_23 dataframe in a separate viewer window
View(season_23)
# Read 2024 transfer fee data from CSV file into transfer_fee_24 dataframe
transfer_fee_24=read.csv('/Users/tranduc/Documents/Data Science/Data/transfer_fee_24.csv')
# Display transfer_fee_24 dataframe in a separate viewer window
View(transfer_fee_24)

# Create scatter plot showing relationship between wins and transfer fees in 2023
ggplot(season_23, 
       aes(transfer_fee, win, colour=win))+ # Map wins to x-axis, transfer fee to y-axis, and color points by win count
  geom_point(position=position_jitter(w=0.5, h=0))+ # Add jittered points to reduce overplotting
  geom_smooth(method='lm', se=FALSE)+ # Add linear regression line without confidence interval
  geom_text(aes(x=448.10, y=18, label='Chelsea Football Club'), vjust=-1, hjust=0.6)+ # Add text
  geom_text(aes(x=241.10, y=28, label='Manchester City Football Club'), vjust=1, hjust=-0.05)+ # Add text
  geom_text(aes(x=231.60, y=28, label='Arsenal Football Club'), hjust=1.05)+ # Add text
  labs(x='Transfer Fee (million Euro)', y='Winning', # Set axis labels
       title='Correlation between Transfer Fee and Winning (2023)', # Set plot title
       caption='Transfermarkt dataset', # Set data source caption
       colour='Winning') # Set legend title

# Calculate average transfer fee and wins per season
data=summarise(group_by(all_season, season), transfer_fee=mean(transfer_fee), win=mean(win))
ggplot(data, aes(x=season))+ # Create plot with season on x-axis
geom_line(aes(y=transfer_fee, col='Transfer Fee'))+ # Add line for transfer fees
geom_line(aes(y=win, col='Winning'))+ # Add line for wins
geom_point(aes(y=transfer_fee))+ # Add point for transfer fee
geom_point(aes(y=win))+ # Add point for wins
geom_text(aes(y=transfer_fee, label=round(transfer_fee)), vjust=-1)+ # Display transfer fee values on the line
geom_text(aes(y=win, label=round(win)), vjust=-1.5)+ # Display winning values on the line
scale_y_continuous(trans='log', breaks=c(0, 100**4, 2*100**4))+ # Set logarithmic y-axis scale with specific breaks
scale_x_continuous(breaks=seq(min(data['season']), max(data['season']), by=1))+ # Display all years on the x-axis
scale_colour_manual(name='Metric', values=c('Transfer Fee'='darkred', 'Winning'='steelblue'))+ # Set custom colors for lines
labs(title='Transfer Fee and Winning (2012-2022)', x='Season', y='Transfer Fee (million) & Winning (matches)', # Set labels
     caption='Transfermarkt dataset')

# Start of Linear Regression analysis section
# Extract only transfer_fee and win columns from season_23 for training data
trainning_data=season_23[c('transfer_fee', 'win')]
# Extract only transfer_fee column from transfer_fee_24 for testing data
testing_data=transfer_fee_24['transfer_fee']

# Create linear regression model where win is dependent on transfer_fee
model=lm(win~transfer_fee, trainning_data)
# Use the model to predict wins based on testing data transfer fees
prediction=predict(model, testing_data)
# Round the predicted values to whole numbers (as partial wins don't make sense)
prediction=round(prediction)
# Combine the original testing data with the predictions into one dataframe
testing_data=cbind(testing_data, prediction)
# Display the testing data with predictions
View(testing_data)
# Write testing_data dataframe to csv
write.csv(testing_data, file='/Users/tranduc/Documents/Data Science/Data/winning_prediction_24')
# Create visualization of predictions
ggplot(testing_data, 
       aes(transfer_fee, prediction, colour=prediction))+ # Map transfer fee to x-axis, predictions to y-axis, color by prediction value
  geom_point()+ # Add scatter points for each prediction
  geom_smooth(method='lm')+ # Add linear regression line
  scale_y_continuous(limits=c(0, NA), expand=c(0, 0))+ # # Set y-axis to start from 0
  labs(x='Transfer Fee (million Euro)', y='Winning', # Set axis labels
       title='Winning Prediction (2024 First Leg)', # Set main title
       subtitle='Predict the number of wins for the English Premier League First Leg based on the summer transfer fee in season 2024 using linear regression', # Add explanatory subtitle
       caption='Transfermarkt dataset', # Add data source
       colour='Winning') # Set legend title
