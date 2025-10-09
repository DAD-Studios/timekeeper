# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Clearing existing data..."
Invoice.destroy_all
TimeEntry.destroy_all
Project.destroy_all
Client.destroy_all
Profile.destroy_all

puts "Creating profile..."
Profile.create!(
  entity_type: :business,
  business_name: "Acme Consulting",
  email: "billing@acmeconsulting.com",
  phone: "(555) 123-4567",
  address_line1: "123 Business St",
  city: "Austin",
  state: "TX",
  zip_code: "78701",
  country: "USA",
  invoice_prefix: "INV",
  next_invoice_number: 1,
  default_payment_terms: 30
)

puts "Creating clients..."
clients = []
5.times do |i|
  clients << Client.create!(
    name: "Client Company #{i + 1}",
    email: "contact@client#{i + 1}.com",
    phone: "(555) #{100 + i}-0000",
    address_line1: "#{100 + i} Client Ave",
    city: "Dallas",
    state: "TX",
    zip_code: "75201",
    country: "USA"
  )
end

puts "Creating projects and time entries..."
clients.each do |client|
  rand(2..4).times do |j|
    project = Project.create!(
      name: "#{client.name} - Project #{j + 1}",
      client: client,
      rate: rand(50.0..150.0).round(2)
    )

    rand(3..8).times do |k|
      start_time = (rand(1..30).days.ago + rand(8..17).hours).beginning_of_hour
      end_time = start_time + rand(1..4).hours

      TimeEntry.create!(
        task: "Task #{k + 1}",
        notes: "Work completed for task #{k + 1}.",
        project: project,
        client: client,
        start_time: start_time,
        end_time: end_time,
        rate: project.rate,
        status: "completed"
      )
    end
  end
end

puts "Creating sample invoices..."
2.times do |i|
  client = clients[i]
  invoice = Invoice.create!(
    client: client,
    invoice_date: Date.current - (i * 15).days,
    due_date: Date.current + (30 - (i * 15)).days,
    status: [:draft, :sent].sample
  )

  invoice.line_items.create!([
    { description: "Web Development Services", quantity: rand(20..50), rate: rand(75.0..125.0).round(2) },
    { description: "Consulting", quantity: rand(5..15), rate: rand(100.0..200.0).round(2) }
  ])
end

puts "✅ Seeded database successfully!"
puts "   - #{Profile.count} profile"
puts "   - #{Client.count} clients"
puts "   - #{Project.count} projects"
puts "   - #{TimeEntry.count} time entries"
puts "   - #{Invoice.count} invoices"
