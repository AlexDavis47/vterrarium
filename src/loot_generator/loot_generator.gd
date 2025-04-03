extends Node

## Four tables is fine for the moment, but we can add more later
enum LootTable {
    COMMON,
    UNCOMMON,
    RARE,
    LEGENDARY
}

## Just trying one for now
var _loot_tables: Dictionary[LootTable, LootTableData] = {
    LootTable.COMMON: preload("uid://8br5jqbkh4gi")
}

func generate_loot(loot_table: LootTable, amount: int) -> Array[ItemDataResource]:
    var loot_table_data: LootTableData = _loot_tables[loot_table]
    var loot: Array[ItemDataResource] = []
    for i in range(amount):
        loot.append(loot_table_data.get_random_item())
    return loot
