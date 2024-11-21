-- CTE to calculate player statistics for 2023 season
with games_23 as(
	-- Aggregate player statistics for the season
	select
	player_id                    -- Player's unique identifier
	, player_name               -- Player's name
	, club_id                   -- Club's unique identifier
	, sum(goals) goals         -- Total goals in season
	, sum(assists) assists     -- Total assists in season
	from(
		-- Get match-level statistics for Premier League 2023
		select
		player_id               -- Player's unique identifier
		, player_name          -- Player's name
		, player_club_id club_id -- Club's unique identifier
		, goals                -- Goals scored in match
		, assists             -- Assists made in match
		from transfermarkt.appearances a     -- Match appearances data
		join transfermarkt.games g           -- Game details data
		on a.game_id=g.game_id              -- Link appearances to games
		join transfermarkt.competitions c    -- Competition data
		on g.competition_id=c.competition_id -- Link games to competitions
		where c.name='premier-league'        -- Filter for Premier League only
		and g.season=2023                    -- Filter for 2023 season
	)
	group by player_id, player_name, club_id -- Group to get season totals
)

-- CTE to determine player status (Current/New) based on transfer history
, players_12_23 as(
	select
	player_id                 -- Player's unique identifier
	, player_name            -- Player's name
	, club_id                -- Club's unique identifier
	, club_name              -- Club's name
	, case
		when transfer_season != 2023 then 'Current player'  -- Players transferred before 2023
		when transfer_season = 2023 then 'New player'       -- Players transferred in 2023
	  end player_group
	from(
		-- Process transfer data from 2012-2023
		select
		player_id           -- Player's unique identifier
		, player_name       -- Player's name
		, to_club_id club_id  -- Destination club identifier
		, to_club_name club_name  -- Destination club name
		, cast(concat(20, substring(transfer_season, 1, 2)) as numeric) transfer_season  -- Convert season format to year
		from transfermarkt.transfers  -- Transfer history data
		where transfer_season in ('12/13', '13/14', '14/15', '15/16',   -- Seasons from 2012/13
		'16/17', '17/18', '18/19', '19/20', '20/21', '21/22', '22/23', '23/24')  -- to 2023/24
	)
	group by player_id, player_name, club_id, club_name, player_group  -- Remove duplicate transfers
	order by club_name, player_name  -- Sort by club and player name
)

-- Final query to combine player statistics with transfer status
select
a.player_name             -- Player's name
, club_name               -- Club's name
, goals                   -- Season goals
, assists                -- Season assists
, player_group            -- Player status (Current/New)
from games_23 a           -- Player statistics CTE
join players_12_23 b      -- Player transfer status CTE
on (a.player_id=b.player_id and a.club_id=b.club_id)  -- Match players by ID and current club
order by club_name        -- Sort by club name
, player_group            -- Then by player status
, goals desc             -- Then by goals (highest first)
, assists desc           -- Then by assists (highest first)