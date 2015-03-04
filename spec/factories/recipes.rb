FactoryGirl.define do
  factory :recipe do
    name { Faker::Product.product_name }
    ingredients { 5.times.collect { Faker::Food.ingredient } }
    directions { 4.times.collect { Faker::HipsterIpsum.words(10).join(" ") } }
    notes { 1.times.collect { Faker::HipsterIpsum.words(10).join(" ") } }
    prep_time { "#{[10.minutes, 15.minutes, 30.minutes, 1.hour].sample} seconds" }
    cook_time { "#{[10.minutes, 15.minutes, 30.minutes, 1.hour].sample} seconds" }
    amount { "#{[1, 2, 3, 4].sample} serving(s)" }
  end
end
