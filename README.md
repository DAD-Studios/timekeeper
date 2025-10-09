# ⏱️ Timekeeper

A professional time tracking and invoicing application built with Ruby on Rails 8. Track time, manage clients and projects, generate invoices, and get paid faster.

## 🌟 Features

### Time Tracking
- **Live Timer**: Start/stop timer with real-time tracking
- **Manual Entries**: Edit completed time entries (when not paid)
- **Task Organization**: Track work by client and project
- **History View**: Collapsible client/project grouping with earnings calculation
- **Status Tracking**: Unbilled → Invoiced → Paid workflow

### Client Management
- **Business Information**: Company name, contact person, address
- **Contact Details**: First/last name, email, phone
- **Notes**: Rich text notes for client details
- **Collapsible Forms**: Clean, organized data entry

### Project Management
- **Client Association**: Projects grouped by client
- **Hourly Rates**: Set rates per project
- **Time Tracking**: All time entries linked to projects
- **Collapsible Views**: Easy navigation with expandable sections

### Invoicing
- **Smart Creation**: Select unbilled time entries or add manual line items
- **Project Grouping**: Line items automatically grouped by project
- **Status Management**: Draft → Sent → Viewed → Paid → Overdue
- **PDF Generation**: Professional invoices with logo and branding
- **Payment Tracking**: Record partial and full payments
- **Automatic Totals**: Subtotal, discounts, and total calculation

### Profile & Branding
- **Entity Types**: Individual or Business profiles
- **Logo & Signature**: Upload and display on invoices
- **Custom Numbering**: Invoice prefix and sequential numbering
- **Payment Terms**: Default payment terms configuration
- **Theme Colors**: Primary color customization (for future theming)

### Reports & Analytics
- **Calendar View**: Visual daily time tracking
- **Earnings Overview**: Daily, weekly, monthly metrics
- **Status Indicators**: Quick view of time entry status
- **Interactive Calendar**: Navigate and view detailed metrics

### Business Rules
- **Paid Invoice Protection**: Cannot edit paid invoices (status change only)
- **Paid Time Entry Protection**: Only notes editable for paid entries
- **One Timer Rule**: Only one timer can run at a time
- **Automatic Calculations**: Earnings, duration, and totals auto-calculated
- **Automatic Paid Dates**: Set when invoice marked as paid

## 🛠️ Technology Stack

- **Ruby**: 3.4.5
- **Rails**: 8.0.3
- **Database**: SQLite (development), PostgreSQL (production-ready)
- **Asset Pipeline**: Propshaft
- **JavaScript**: Stimulus.js controllers
- **Styling**: Custom SCSS with mobile-first responsive design, Bootstrap Icons
- **PDF Generation**: Prawn
- **Testing**: RSpec (152 passing tests)
- **Rich Text**: Action Text (Trix editor)
- **File Storage**: Active Storage

## 📋 Prerequisites

- Ruby 3.4.5
- Rails 8.0.3
- SQLite3 (development)
- Node.js (for asset compilation)

## 🚀 Getting Started

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd timekeeper
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup database**
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed  # Optional: load sample data
   ```

4. **Start the server**
   ```bash
   bin/dev  # Starts Rails server and asset compilation
   ```

5. **Visit the application**
   ```
   http://localhost:3000
   ```

### First-Time Setup

1. Navigate to **Profile** page
2. Set up your business/individual profile
3. Add your first client
4. Create a project for the client
5. Start tracking time!

## 🧪 Testing

Run the complete test suite:

```bash
bundle exec rspec
```

Run specific test types:

```bash
# Models only
bundle exec rspec spec/models

# Controllers only
bundle exec rspec spec/controllers

# Requests only
bundle exec rspec spec/requests

# With documentation format
bundle exec rspec --format documentation
```

**Test Coverage**: 152 passing tests (98% pass rate)
- Models: 44 tests
- Controllers: 35 tests
- Requests: 45 tests
- Additional: 28 tests

## 📁 Project Structure

```
app/
├── controllers/         # Application controllers
│   ├── clients_controller.rb
│   ├── invoices_controller.rb
│   ├── projects_controller.rb
│   ├── time_entries_controller.rb
│   └── reports_controller.rb
├── models/             # ActiveRecord models
│   ├── client.rb
│   ├── invoice.rb
│   ├── project.rb
│   ├── time_entry.rb
│   └── profile.rb
├── views/              # ERB templates
│   ├── clients/
│   ├── invoices/
│   ├── projects/
│   ├── time_entries/
│   └── reports/
├── javascript/         # Stimulus controllers
│   └── controllers/
│       ├── collapsible_controller.js
│       ├── form_disable_controller.js
│       ├── timer_controller.js
│       ├── mobile_menu_controller.js
│       └── project_select_controller.js
└── services/           # Service objects
    └── invoice_pdf_generator.rb
```

## 🔑 Key Models

### Client
- Business name, contact name (first/last)
- Email, phone, address
- Has many projects and invoices

### Project
- Name, hourly rate
- Belongs to client
- Has many time entries

### TimeEntry
- Task description, notes
- Start/end time, duration, earnings
- Belongs to project and client
- Can be invoiced (once)

### Invoice
- Invoice number, date, due date
- Status: draft, sent, viewed, paid, partially_paid, overdue, cancelled
- Line items (from time entries or manual)
- Automatic totals calculation
- PDF generation

### Profile
- Entity type (individual/business)
- Business info or personal info
- Branding (logo, signature, colors)
- Invoice settings (prefix, numbering, payment terms)

## 🎨 UI Features

### Mobile-First Responsive Design ⭐ NEW
- **Fully responsive** across all devices (mobile, tablet, desktop)
- **Mobile navigation** with hamburger menu
- **Responsive tables** that transform into cards on mobile
- **Touch-optimized** forms and buttons (44px minimum touch targets)
- **Sticky navigation** for easy access while scrolling
- **Responsive timer widget** that adapts to screen size
- **No horizontal scrolling** on mobile devices
- **Breakpoints**: 480px (mobile), 768px (tablet), 1024px (desktop), 1400px (large)

### Collapsible Sections
- History page: Clients → Projects → Time Entries
- Projects page: Grouped by client
- Profile page: Organized sections
- Client forms: Logical grouping

### Real-time Updates
- Timer widget (visible on all pages)
- Invoice status dropdowns (auto-submit)
- Form validation and errors

### Visual Status Indicators
- Time entries: Unbilled (yellow) → Invoiced (green) → Paid (blue)
- Invoices: Color-coded status badges
- Icons for actions (view, edit, download)

## 🔒 Security & Validation

### Paid Invoice Protection
- Cannot edit paid invoices (except status)
- Form-level field disabling
- Controller-level enforcement

### Paid Time Entry Protection
- Only notes field editable
- All other fields disabled
- Clear user messaging

### Data Validation
- Required fields enforced
- Email format validation
- Unique constraints (client names, invoice numbers)
- No duplicate running timers

### Strong Parameters
- All controllers use strong parameters
- No mass assignment vulnerabilities
- Proper nested attributes handling

## 📊 Database Schema

### Key Tables
- `clients` - Client information and contacts
- `projects` - Project details and rates
- `time_entries` - Time tracking records
- `invoices` - Invoice headers
- `invoice_line_items` - Invoice line details
- `invoice_payments` - Payment records
- `profiles` - Business/individual profile

### Relationships
```
Client
  ├── has_many :projects
  ├── has_many :time_entries
  └── has_many :invoices

Project
  ├── belongs_to :client
  └── has_many :time_entries

TimeEntry
  ├── belongs_to :client
  ├── belongs_to :project
  └── has_one :invoice_line_item

Invoice
  ├── belongs_to :client
  ├── has_many :line_items
  └── has_many :payments
```

## 🚢 Deployment

### Prerequisites
- PostgreSQL database
- Redis (for Action Cable, if needed)
- Storage service (S3 for production file uploads)

### Environment Variables
```bash
DATABASE_URL=postgresql://...
RAILS_MASTER_KEY=<your-master-key>
STORAGE_SERVICE=amazon  # or local
S3_BUCKET=<your-bucket>
AWS_ACCESS_KEY_ID=<your-key>
AWS_SECRET_ACCESS_KEY=<your-secret>
```

### Deploy to Production
```bash
# Update credentials
EDITOR=nano rails credentials:edit

# Precompile assets
rails assets:precompile

# Run migrations
rails db:migrate

# Start server
rails server -e production
```

## 📝 Usage Examples

### Track Time
1. Navigate to Timer (home page)
2. Select client, project, and task
3. Click "Start Timer"
4. Click "Stop" when done
5. View in History page

### Create Invoice
1. Navigate to Invoices → New Invoice
2. Select client
3. Choose unbilled time entries OR add manual line items
4. Set invoice date and due date
5. Add notes and payment instructions (optional)
6. Create invoice
7. Download PDF or mark as sent

### Update Invoice Status
1. From invoice index or show page
2. Use status dropdown
3. Automatically saves on change
4. Paid status sets paid_date automatically

## 🐛 Troubleshooting

### Timer not starting
- Check if another timer is already running
- Only one timer allowed at a time
- Stop existing timer first

### Cannot edit time entry
- Check if it's associated with a paid invoice
- Paid entries: only notes are editable
- All other fields are locked

### PDF generation issues
- Ensure Prawn gem is installed
- Check profile has required information
- Logo must be attached and visible

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards
- Follow Rails best practices
- Write tests for new features
- Use descriptive commit messages
- Keep methods small and focused
- Extract service objects for complex logic

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Built with Ruby on Rails 8
- UI inspired by modern SaaS applications
- Icons from Bootstrap Icons
- PDF generation powered by Prawn

## 📞 Support

For questions or issues:
1. Check the documentation
2. Review existing issues
3. Create a new issue with detailed description

---

**Version**: 1.1.0
**Last Updated**: October 2025
**Status**: Production Ready ✅ | Mobile-First Responsive ✅
