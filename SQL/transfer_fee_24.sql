-- Consistent column selection pattern: entity_name, entity_id, calculated_field
select
name
, sum(transfer_fee)/1000000 transfer_fee  -- Naming pattern: [metric]_[year]
from
(
	-- Consistent column selection: entity attributes before calculated fields
	select
	distinct
	c.name
	, transfer_fee
	-- Consistent table aliasing: first letter of table name
	from transfermarkt.clubs c
	-- Logical join order: main entity -> related entities
	join transfermarkt.transfers t
	on c.club_id=t.to_club_id
	join transfermarkt.club_games cg
	on c.club_id=cg.club_id
	join transfermarkt.games g
	on cg.game_id=g.game_id
	join transfermarkt.competitions co
	on g.competition_id=co.competition_id
	-- Filter conditions ordered: static filters first, then dynamic
	where co.name='premier-league'
	and g.season=2024
	and transfer_season='24/25'
	and (transfer_fee is not null and transfer_fee!=0)
	-- Consistent ordering by entity name
	order by c.name
)
-- Group by follows select column order
group by name