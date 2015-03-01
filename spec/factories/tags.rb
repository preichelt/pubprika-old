FactoryGirl.define do
  factory :tag do
    name { Faker::Product.product_name.pluralize }
    singularized { name.singularize }
    referenced { rand(5..100) }
  end
end
