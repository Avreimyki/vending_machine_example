require "tty-prompt"
require_relative  'vending_machine'
prompt = TTY::Prompt.new
machine = VendingMachine.new

def continue_prompt(machine, prompt)
  case machine.current_state
  when :choose_drink
    drink = prompt.select("Choose your destiny?", machine.get_available_drinks)
    puts machine.choose_drink(drink)
  when :enter_coins
    puts machine.next_coin_msg
    coin = prompt.select("Enter coin", machine.coins_inventory.keys)
    machine.entered_coin(coin)
  when :getting_drink
    puts "Please take your #{machine.current_drink}"
    change_plan = machine.get_drink
    if change_plan.is_a?(Hash)
      change_plan.each{|key, value| value.to_i.times{puts "Please take #{key} coin."}}
    else
      puts "We are sorry the machine didn't have change please connect system manager."
    end
  else
    "Sory I didn't understood that please try again "
  end
  puts("\n")
  continue_prompt(machine, prompt)
end

continue_prompt machine, prompt


