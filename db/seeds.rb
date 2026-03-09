# frozen_string_literal: true

Order.destroy_all
Product.destroy_all
Category.destroy_all
Customer.destroy_all
Coupon.destroy_all
GiftCard.destroy_all
User.destroy_all
Role.destroy_all

admin = User.create!(
  name: "Admin User",
  email: "admin@example.com",
  password: "Password123!",
  password_confirmation: "Password123!"
)
admin.add_role :admin

User.create!(
  name: "Sarah Manager",
  email: "sarah@example.com",
  password: "Password123!",
  password_confirmation: "Password123!"
).add_role :admin

User.create!(
  name: "John Admin",
  email: "john@example.com",
  password: "Password123!",
  password_confirmation: "Password123!"
).add_role :admin

categories_data = [
  { name: "Electronics" },
  { name: "Smartphones" },
  { name: "Books" },
  { name: "Shoes" },
  { name: "Sports & Outdoors" },
  { name: "Running" },
  { name: "Men's Footwear" },
  { name: "Audio" },
  { name: "Headphones" },
  { name: "Noise Cancelling" },
  { name: "Travel Accessories" },
  { name: "New Arrivals" },
  { name: "Best Sellers" },
  { name: "Premium / High-end" },
  { name: "Sale / Clearance" },
  { name: "Home & Kitchen" },
  { name: "Clothing" },
  { name: "Gaming" },
  { name: "Laptops" },
  { name: "Accessories" }
]

categories = {}
categories_data.each do |attrs|
  cat = Category.create!(attrs)
  categories[attrs[:name]] = cat
end

products_data = [
  {
    name: "Apple iPhone 16 Pro",
    description: "Latest flagship smartphone with advanced camera and A18 Pro chip.",
    price: 119_900,
    status: "active",
    stock_quantity: 25,
    category_names: ["Smartphones", "Electronics", "New Arrivals", "Best Sellers", "Premium / High-end"]
  },
  {
    name: "Nike Air Zoom Running Shoes",
    description: "Lightweight running shoes with responsive cushioning.",
    price: 14_999,
    status: "active",
    stock_quantity: 3,
    category_names: ["Shoes", "Sports & Outdoors", "Running", "Men's Footwear", "Sale / Clearance"]
  },
  {
    name: "Sony WH-1000XM5 Headphones",
    description: "Industry-leading noise cancelling wireless headphones.",
    price: 39_900,
    status: "active",
    stock_quantity: 15,
    category_names: ["Electronics", "Audio", "Headphones", "Noise Cancelling", "Travel Accessories"]
  },
  {
    name: "Instant Pot",
    description: "7-in-1 multi-use pressure cooker.",
    price: 9_999,
    status: "active",
    stock_quantity: 8,
    category_names: ["Home & Kitchen", "Electronics", "Best Sellers"]
  },
  {
    name: "Organic Cotton T-Shirt",
    description: "Soft, sustainable organic cotton t-shirt.",
    price: 2_499,
    status: "active",
    stock_quantity: 0,
    category_names: ["Clothing", "Sale / Clearance"]
  },
  {
    name: "The Pragmatic Programmer",
    description: "Your Journey To Mastery, 20th Anniversary Edition.",
    price: 4_499,
    status: "active",
    stock_quantity: 50,
    category_names: ["Books", "Best Sellers"]
  },
  {
    name: "MacBook Pro 14\"",
    description: "Powerful laptop with M3 Pro chip for professionals.",
    price: 199_900,
    status: "active",
    stock_quantity: 12,
    category_names: ["Electronics", "Laptops", "Premium / High-end", "Best Sellers"]
  },
  {
    name: "Samsung Galaxy S24",
    description: "Android flagship with advanced AI features.",
    price: 99_900,
    status: "active",
    stock_quantity: 30,
    category_names: ["Smartphones", "Electronics", "New Arrivals"]
  },
  {
    name: "PlayStation 5",
    description: "Next-gen gaming console with 4K support.",
    price: 54_999,
    status: "active",
    stock_quantity: 8,
    category_names: ["Electronics", "Gaming", "Best Sellers"]
  },
  {
    name: "Adidas Ultraboost",
    description: "Premium running shoes with Boost cushioning.",
    price: 18_999,
    status: "active",
    stock_quantity: 22,
    category_names: ["Shoes", "Sports & Outdoors", "Running", "Men's Footwear"]
  },
  {
    name: "KitchenAid Stand Mixer",
    description: "Professional 4.8L stand mixer for baking.",
    price: 42_999,
    status: "active",
    stock_quantity: 5,
    category_names: ["Home & Kitchen", "Electronics", "Premium / High-end"]
  },
  {
    name: "Clean Code",
    description: "A Handbook of Agile Software Craftsmanship by Robert Martin.",
    price: 3_999,
    status: "active",
    stock_quantity: 45,
    category_names: ["Books", "Best Sellers"]
  },
  {
    name: "Wireless Earbuds Pro",
    description: "True wireless earbuds with active noise cancellation.",
    price: 12_999,
    status: "draft",
    stock_quantity: 100,
    category_names: ["Electronics", "Audio", "Headphones", "Accessories"]
  },
  {
    name: "Leather Wallet",
    description: "Handcrafted genuine leather bifold wallet.",
    price: 2_999,
    status: "active",
    stock_quantity: 2,
    category_names: ["Accessories", "Sale / Clearance"]
  }
]

def attach_product_image(product, seed_or_url, filename: "image.jpg")
  require "open-uri"
  return unless seed_or_url.present?
  # Use picsum.photos - reliable placeholder service that returns actual JPEG images
  url = seed_or_url.to_s.start_with?("http") ? seed_or_url : "https://picsum.photos/seed/#{seed_or_url}/400/300.jpg"
  io = URI.parse(url).open(
    "User-Agent" => "Rails/EC-Admin",
    read_timeout: 10,
    open_timeout: 5
  )
  product.images.attach(io: io, filename: "#{filename}.jpg", content_type: "image/jpeg")
  puts "  ✓ Attached image for #{product.name}"
rescue OpenURI::HTTPError, SocketError, Errno::ENOENT, Net::OpenTimeout => e
  puts "  ✗ Skip image for #{product.name}: #{e.message}"
end

# Seeds for picsum.photos - each product gets 2-3 images (multiple images per product)
product_image_seeds = %w[iphone shoes headphones pot shirt book macbook galaxy ps5 adidas mixer code earbuds wallet]

products = []
products_data.each_with_index do |attrs, idx|
  category_names = attrs.delete(:category_names)
  product = Product.create!(attrs)
  category_names.each do |cn|
    product.categories << categories[cn] if categories[cn]
  end
  base_seed = product_image_seeds[idx]
  attach_product_image(product, base_seed, filename: "product_#{product.slug}_1")
  attach_product_image(product, "#{base_seed}-2", filename: "product_#{product.slug}_2")
  attach_product_image(product, "#{base_seed}-3", filename: "product_#{product.slug}_3")
  products << product
end

customers_data = [
  { name: "Demo Customer", email: "customer@example.com" },
  { name: "Alice Johnson", email: "alice@example.com" },
  { name: "Bob Smith", email: "bob@example.com" },
  { name: "Carol Williams", email: "carol@example.com" },
  { name: "David Brown", email: "david@example.com" },
  { name: "Emma Davis", email: "emma@example.com" }
]

customers = customers_data.map do |attrs|
  Customer.create!(
    name: attrs[:name],
    email: attrs[:email],
    password: "Password123!",
    password_confirmation: "Password123!"
  )
end

def set_order_totals(order)
  amt = order.order_line_items.sum { |li| li.quantity * li.unit_price_cents }
  order.update_columns(total_amount: amt, coupon_discount: 0, gift_card_discount: 0, final_amount: amt)
end

# Order 1: Processing
order1 = Order.create!(customer: customers[0], status: "processing", total_amount: 0, coupon_discount: 0, gift_card_discount: 0, final_amount: 0)
OrderLineItem.create!(order: order1, product: products[0], quantity: 1, unit_price_cents: products[0].price)
OrderLineItem.create!(order: order1, product: products[1], quantity: 2, unit_price_cents: products[1].price)
set_order_totals(order1)

# Order 2: Pending
Order.create!(customer: customers[0], status: "pending", total_amount: 0, coupon_discount: 0, gift_card_discount: 0, final_amount: 0)

# Order 3: Shipped
order3 = Order.create!(customer: customers[1], status: "shipped", total_amount: 0, coupon_discount: 0, gift_card_discount: 0, final_amount: 0)
OrderLineItem.create!(order: order3, product: products[2], quantity: 1, unit_price_cents: products[2].price)
OrderLineItem.create!(order: order3, product: products[5], quantity: 2, unit_price_cents: products[5].price)
set_order_totals(order3)

# Order 4: Delivered
order4 = Order.create!(customer: customers[2], status: "delivered", total_amount: 0, coupon_discount: 0, gift_card_discount: 0, final_amount: 0)
OrderLineItem.create!(order: order4, product: products[3], quantity: 1, unit_price_cents: products[3].price)
OrderLineItem.create!(order: order4, product: products[4], quantity: 3, unit_price_cents: products[4].price)
set_order_totals(order4)

# Order 5: Processing
order5 = Order.create!(customer: customers[3], status: "processing", total_amount: 0, coupon_discount: 0, gift_card_discount: 0, final_amount: 0)
OrderLineItem.create!(order: order5, product: products[6], quantity: 1, unit_price_cents: products[6].price)
set_order_totals(order5)

# Order 6: Pending
order6 = Order.create!(customer: customers[4], status: "pending", total_amount: 0, coupon_discount: 0, gift_card_discount: 0, final_amount: 0)
OrderLineItem.create!(order: order6, product: products[7], quantity: 1, unit_price_cents: products[7].price)
OrderLineItem.create!(order: order6, product: products[2], quantity: 1, unit_price_cents: products[2].price)
set_order_totals(order6)

# Order 7: Shipped
order7 = Order.create!(customer: customers[5], status: "shipped", total_amount: 0, coupon_discount: 0, gift_card_discount: 0, final_amount: 0)
OrderLineItem.create!(order: order7, product: products[9], quantity: 2, unit_price_cents: products[9].price)
OrderLineItem.create!(order: order7, product: products[10], quantity: 1, unit_price_cents: products[10].price)
set_order_totals(order7)

# Order 8: Cancelled
Order.create!(customer: customers[1], status: "cancelled", total_amount: 0, coupon_discount: 0, gift_card_discount: 0, final_amount: 0)

# Coupons (new schema)
Coupon.create!([
  { code: "WELCOME10", discount_type: "percentage", discount_value: 10, min_cart_value: 1000, usage_limit: 100, status: "active" },
  { code: "FLAT20", discount_type: "fixed", discount_value: 2000, min_cart_value: 5000, usage_limit: 50, status: "active" },
  { code: "SUMMER25", discount_type: "percentage", discount_value: 25, min_cart_value: 2000, max_discount: 5000, start_date: 1.week.ago.to_date, expiry_date: 2.months.from_now.to_date, status: "active" },
  { code: "EXPIRED50", discount_type: "percentage", discount_value: 50, min_cart_value: 0, usage_limit: 10, expiry_date: 1.day.ago.to_date, status: "active" }
])

# Gift cards (new schema: initial_balance, balance, expiry_date)
GiftCard.create!([
  { code: "GC-100-XXXX", initial_balance: 10000, balance: 10000, status: "active", expiry_date: 1.year.from_now.to_date },
  { code: "GC-50-YYYY", initial_balance: 5000, balance: 5000, status: "active", expiry_date: 6.months.from_now.to_date },
  { code: "GC-25-PARTIAL", initial_balance: 2500, balance: 1200, status: "active", expiry_date: 3.months.from_now.to_date },
  { code: "GC-USED-ZZZZ", initial_balance: 7500, balance: 0, status: "redeemed", expiry_date: 1.year.from_now.to_date }
])

puts "Seeded admin users: admin@example.com, sarah@example.com, john@example.com / Password123!"
puts "Seeded #{Category.count} categories, #{Product.count} products, #{Customer.count} customers, #{Order.count} orders."
puts "Seeded #{Coupon.count} coupons, #{GiftCard.count} gift cards."
