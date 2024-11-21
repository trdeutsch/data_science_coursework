# Install the tidyverse package which contains multiple useful packages for data manipulation and visualization
install.packages('tidyverse')
# Load the tidyverse package into the current R session
library(tidyverse)

# Read historical season data from CSV file into all_season dataframe
all_season=read.csv('/Users/tranduc/Documents/Data Science/cleansed_data/all_seasons.csv')
# Display all_season dataframe in a separate viewer window
View(all_season)
# Read 2023 season data from CSV file into season_23 dataframe
season_23=read.csv('/Users/tranduc/Documents/Data Science/cleansed_data/season_23.csv')
# Display season_23 dataframe in a separate viewer window
View(season_23)
# Read historical player data from CSV file into players dataframe
players=read.csv('/Users/tranduc/Documents/Data Science/cleansed_data/all_players.csv')
# Display players dataframe in a separate viewer window
View(players)
# Read 2023 player data from CSV file into players_23 dataframe
players_23=read.csv('/Users/tranduc/Documents/Data Science/cleansed_data/players_23.csv')
# Display players_23 dataframe in a separate viewer window
View(players_23)

# Create scatter plot showing relationship between wins and transfer fees in 2023
ggplot(season_23, 
       aes(win, transfer_fee, colour=win))+ # Map wins to x-axis, transfer fee to y-axis, and color points by win count
  geom_point(position=position_jitter(w=0.5, h=0))+ # Add jittered points to reduce overplotting
  geom_smooth(method='lm', se=FALSE)+ # Add linear regression line without confidence interval
  labs(x='Win', y='Transfer Fee (million Euro)', # Set axis labels
       title='Correlation between Transfer Fee and Winning (2023)', # Set plot title
       caption='Transfermarkt dataset', # Set data source caption
       colour='Win') # Set legend title

# Calculate average transfer fee and wins per season
data=summarise(group_by(all_season, season), transfer_fee=mean(transfer_fee), win=mean(win))
ggplot(data, aes(x=season))+ # Create plot with season on x-axis
geom_line(aes(y=transfer_fee, col='Transfer Fee'))+ # Add line for transfer fees
geom_line(aes(y=win, col='Winning'))+ # Add line for wins
scale_y_continuous(trans='log', breaks=c(0, 100**4, 2*100**4))+ # Set logarithmic y-axis scale with specific breaks
scale_colour_manual(name='Metric', values=c('Transfer Fee'='darkred', 'Winning'='steelblue'))+ # Set custom colors for lines
labs(title='Transfer Fee and Winning (2012-2022)', x='Season', y='Numbers (in million)', # Set labels
     caption='Transfermarkt dataset')

# Reshape players data to combine goals and assists into single column
data=pivot_longer(players, cols=c(goals, assists), names_to='metric', values_to='goals_assists')
ggplot(data, 
       aes(player_group, goals_assists, fill=metric))+ # Create boxplot comparing player groups
  geom_boxplot()+ # Add boxplot visualization
  labs(x='Group', y='Goals and Assists', # Set axis labels
       title='Goals and Assists differences (2023)', # Set title
       subtitle='Goals and Assists differences between New and Current players in season 2023', # Set subtitle
       caption='Transfermarkt dataset', # Set caption
       fill='Metric') # Set legend title

# Calculate average transfer fee by club and position
new_data=summarise(group_by(players_23, club_name, position), 
                   fee=mean(transfer_fee))
ggplot(new_data, 
       aes(club_name, fee, fill=position))+ # Create stacked bar chart
  geom_bar(stat='identity')+ # Add bars
  labs(x='Club', y='Transfer fee (million Euro)', fill='Position', # Set labels
       title='Distribution of fee across position (2023)', # Set title
       subtitle='Distribution of fee on Attack, Midfield, Defender and Goalkeeper in season 2023', # Set subtitle
       caption='Transfermarkt dataset') # Set caption

# Reshape 2023 players data to combine goals and assists
other_data=pivot_longer(players_23, cols=c(goals, assists), names_to='metric', values_to='goals_assists')
ggplot(other_data, 
       aes(position, goals_assists, fill=metric))+ # Create boxplot comparing positions
  geom_boxplot()+ # Add boxplot visualization
  labs(x='Position', y='Goals and Assists', # Set axis labels
       title='Goals and Assists differences (2023)', # Set title
       subtitle='Goals and Assists differences between Attackers and Other positions in season 2023', # Set subtitle
       caption='Transfermarkt dataset', # Set caption
       fill='Metric') # Set legend title