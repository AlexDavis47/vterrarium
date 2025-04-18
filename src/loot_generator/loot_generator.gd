extends Node

## Four tables is fine for the moment, but we can add more later
## Technically we dont even use this right now but we might have to someday
enum LootTable {
    COMMON,
    UNCOMMON,
    RARE,
    LEGENDARY,
    UNCOMMON_FOOD,
    RARE_FOOD,
}

## Just trying one for now
var _loot_tables: Dictionary[LootTable, LootTableData] = {
    LootTable.COMMON: preload("uid://8br5jqbkh4gi")
}

func generate_loot(loot_table: LootTableData, amount: int = 1, luck: float = 1.0) -> Array[ItemDataResource]:
    if loot_table.static_pack:
        return loot_table.get_static_pack()
    var loot: Array[ItemDataResource] = []
    for i in range(amount):
        loot.append(loot_table.get_random_item(luck))
    return loot


func get_loot_table_data(loot_table: LootTable) -> LootTableData:
    return _loot_tables[loot_table]
