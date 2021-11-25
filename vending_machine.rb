require 'tty-prompt'
require 'hashie'
require_relative 'default_config'
class VendingMachine

  attr_accessor :drinks_inventory, :coins_inventory, :current_state, :current_drink, :current_balance

  def initialize
    @drinks_inventory = Hashie::Mash.new(DefaultConfig.default_inventory_config[:drinks])
    coins_config = DefaultConfig.default_inventory_config[:coins]
    sorted_coins = {}
    coins_config.keys.sort.reverse.each{|k| sorted_coins[k] = coins_config[k]}
    @coins_inventory = sorted_coins
    @current_state = :choose_drink
    @current_balance = 0
  end

  def get_optimize_change(change_amount, plan_to_use = {}, max_checked_coin = nil)
    return plan_to_use || {} if change_amount == 0
    max_checked_coin ||= @coins_inventory.keys.first + 1
    @coins_inventory.each do |coin, inventory|
      next if change_amount < coin || coin >= max_checked_coin
      if inventory - (plan_to_use[coin] || 0) >= 1
        plan_to_use[coin].nil? ? plan_to_use[coin] = 1 : plan_to_use[coin] += 1
        change_amount -= coin
        rest_result =  get_optimize_change(change_amount, plan_to_use, max_checked_coin)
        if rest_result
          return plan_to_use
        else
          plan_to_use[coin] -= 1
          change_amount += coin
          max_checked_coin = coin
        end
      end
    end
    change_amount == 0
  end

  def choose_drink(drink_name)
    return "We do not sell this drink" if @drinks_inventory[drink_name][:inventory].nil?
    return "#{drink_name} finish in our stock" if @drinks_inventory[drink_name][:inventory] == 0
    @current_state = :enter_coins
    @current_drink = drink_name
    "You chose #{drink_name}"
  end

  def current_drink_price
    @current_drink ? @drinks_inventory[@current_drink][:price] : 0
  end

  def next_coin_msg
    if @current_balance <  current_drink_price
      msg = "Your current balance is #{@current_balance} please enter #{current_drink_price - current_balance}"
    end
    if @coins_inventory.keys.any? do |coin|
      @current_balance + coin > current_drink_price && !get_optimize_change(@current_balance + coin - current_drink_price)
    end
      msg +="\n We are shortage in change please enter exactly tha price"
    end
    msg
  end

  def get_available_drinks
    @drinks_inventory.keys.select{|key| @drinks_inventory[key][:inventory] > 1}
  end

  def entered_coin(coin)
    return "error" unless @coins_inventory.keys.include?(coin)
    @current_balance += coin
    @coins_inventory[coin] += 1
    if @current_balance >= current_drink_price
      @current_state = :getting_drink
    end
  end

  def get_drink
    @drinks_inventory[@current_drink][:inventory] -= 1
    change = @current_balance - current_drink_price
    @current_balance = 0
    @current_state = :choose_drink
    get_optimize_change change
  end

end



