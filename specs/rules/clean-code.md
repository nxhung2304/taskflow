# Clean Code Rules

## Naming
- Use descriptive variable names
- Avoid abbreviations

Bad:
u = User.find(id)

Good:
user = User.find(id)

## Function Length
- Function should be small
- Maximum 20 lines

## Single Responsibility
- One method should do one thing only

Bad:
def process_order
  calculate_price
  charge_credit_card
  send_email
  update_inventory
end

Good:
def process_order
  price = calculate_price
  charge(price)
  notify_user
end

## Avoid Deep Nesting

Bad:
if user
  if user.active
    if user.admin
      ...
    end
  end
end

Good:
return unless user&.active?

## Prefer Early Return

Bad:
def foo
  if condition
    do_something
  end
end

Good:
def foo
  return unless condition
  do_something
end

## Avoid Magic Numbers

Bad:
if user.age > 18

Good:
LEGAL_AGE = 18

if user.age > LEGAL_AGE
