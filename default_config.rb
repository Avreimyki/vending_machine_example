module DefaultConfig
  class << self
    def default_inventory_config
      {drinks:
         {
           cola: {price: 7, inventory: 10},
           bear: {price: 8.5, inventory: 7},
           orange: {price: 7.25, inventory: 4},
           sprite: {price: 8, inventory: 5},
           apple: {price: 6.5, inventory: 3}
         },
       coins: {
         0.25 => 10,
         0.5 => 13,
         1 => 9,
         2 => 11,
         3 => 4,
         5 => 3
       }
      }
    end
  end
end