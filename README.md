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
- **Status Management**: Draft → Sent → Viewed → Paid → Partially Paid → Overdue → Cancelled
- **PDF Generation**: Professional invoices with logo and branding
- **Payment Tracking**: Record partial and full payments with automatic status updates
- **Multiple Payment Methods**: Bank Wire, Cash, CashApp, Check, Paypal, Stripe, Venmo, Zelle
- **Payment History**: View all payments with dates, methods, references, and notes
- **Automatic Totals**: Subtotal, discounts, amount paid, and amount due calculations
- **Invoice Deletion**: Delete invoices with automatic invoice number adjustment

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
- **Sequential Invoice Numbers**: Deleting the most recent invoice reverts the next invoice number

## 🛠️ Technology Stack

- **Ruby**: 3.4.5
- **Rails**: 8.0.4
- **Database**: SQLite (development), PostgreSQL (production-ready)
- **Asset Pipeline**: Propshaft
- **JavaScript**: Stimulus.js controllers
- **Styling**: Custom SCSS with mobile-first responsive design, Bootstrap Icons
- **PDF Generation**: Prawn
- **Testing**: RSpec (260 passing tests)
Rich Text: Lexxy (built on Lexical and Action Text)
- **File Storage**: Active Storage

## 📋 Prerequisites

- Ruby 3.4.5 or higher
- Rails 8.0.4 or higher
- SQLite3 (development)
- Node.js 18+ (for asset compilation)
- Bundler 2.0+

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

### Running Tests

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

# Feature tests (requires Chrome)
bundle exec rspec spec/features

# With documentation format
bundle exec rspec --format documentation
```

### Chrome Installation for Feature Tests

Feature tests that require JavaScript (marked with `js: true`) need Google Chrome and ChromeDriver. These are automatically managed by Selenium, but Chrome must be installed.

**For WSL/Ubuntu:**
```bash
# Download Chrome .deb package directly
cd /tmp
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# Install Chrome (this will also install dependencies)
sudo apt update
sudo apt install -y ./google-chrome-stable_current_amd64.deb

# Verify installation
google-chrome --version
```

**Note for WSL Users**: Chrome requires a display server. If you encounter issues running feature tests, the tests will gracefully skip with a clear message. All non-JavaScript tests work without Chrome.

**For macOS:**
```bash
brew install --cask google-chrome
```

**Note**: Non-JavaScript feature tests will run without Chrome. Only tests marked with `js: true` require a browser.

**Test Coverage**: 260 passing tests

## 📁 Project Structure

```
app/
├── controllers/         # Application controllers
│   ├── clients_controller.rb
│   ├── invoices_controller.rb
│   ├── invoice_payments_controller.rb
│   ├── projects_controller.rb
│   ├── time_entries_controller.rb
│   └── reports_controller.rb
├── models/             # ActiveRecord models
│   ├── client.rb
│   ├── invoice.rb
│   ├── invoice_line_item.rb
│   ├── invoice_payment.rb
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
- Has many payments

### InvoicePayment
- Payment amount, date, method
- Payment methods: Bank Wire, Cash, CashApp, Check, Paypal, Stripe, Venmo, Zelle
- Reference number and notes
- Belongs to invoice
- Automatically updates invoice status

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

## 📝 Usage Guide

### Getting Started Workflow

#### 1. Set Up Your Profile
1. Navigate to **Profile** (top navigation)
2. Choose entity type: **Individual** or **Business**
3. Fill in your information:
   - Business name / Your name
   - Contact details (email, phone)
   - Address information
4. Upload your logo (optional but recommended for professional invoices)
5. Configure invoice settings:
   - Invoice prefix (e.g., "INV-")
   - Starting invoice number
   - Default payment terms

#### 2. Add Your First Client
1. Navigate to **Clients** → **New Client**
2. Enter business information:
   - Client/Company name
   - Contact person (first name, last name)
   - Email and phone
   - Address
3. Add notes about the client (optional)
4. Save the client

#### 3. Create Projects
1. Navigate to **Projects** → **New Project**
2. Select the client from dropdown
3. Enter project name
4. Set hourly rate for this project
5. Save the project

#### 4. Track Your Time

**Using the Live Timer:**
1. From any page, use the timer widget at the top
2. Select:
   - Client
   - Project (automatically filtered by selected client)
   - Task description
3. Click **Start Timer**
4. The timer runs and displays elapsed time
5. Click **Stop** when finished
6. Time entry is automatically saved

**Manual Time Entry:**
1. Navigate to **History** → **New Time Entry**
2. Select client and project
3. Enter task description
4. Set start time and end time
5. Add notes (optional)
6. Save - duration and earnings are calculated automatically

#### 5. Create and Send Invoices

**Create Invoice from Time Entries:**
1. Navigate to **Invoices** → **New Invoice**
2. Select a client
3. The system loads all **unbilled** time entries for that client
4. Review and select time entries to include
5. Time entries are automatically grouped by project
6. Add invoice details:
   - Invoice date (defaults to today)
   - Due date
   - Apply discount if needed
   - Add notes and payment instructions
7. Click **Create Invoice**

**Create Manual Invoice:**
1. Navigate to **Invoices** → **New Invoice**
2. Select a client
3. Add line items manually:
   - Description
   - Hours/Quantity
   - Rate per hour
4. Add invoice details
5. Create invoice

**Download PDF:**
1. View the invoice
2. Click **Download PDF**
3. Professional PDF generated with your branding

#### 6. Record Payments

**Record a Full Payment:**
1. Open the invoice
2. Scroll to **Payments** section
3. Click **Full Payment** link to auto-fill the amount
4. Select payment method (Bank Wire, Cash, CashApp, Check, Paypal, Stripe, Venmo, or Zelle)
5. Enter payment date
6. Add reference number (e.g., check number, transaction ID)
7. Add notes (optional)
8. Click **Record Payment**
9. Invoice status automatically updates to **Paid**

**Record a Partial Payment:**
1. Open the invoice
2. In the **Payments** section, enter the partial amount
3. Select payment method and date
4. Add reference and notes
5. Click **Record Payment**
6. Invoice status updates to **Partially Paid**
7. Amount Due is automatically updated
8. Repeat to record additional payments until fully paid

**View Payment History:**
- All payments are displayed in a table showing:
  - Payment date
  - Payment method
  - Reference number
  - Amount
  - Notes
- Delete payments if needed (recalculates totals automatically)

#### 7. Monitor Your Business

**View Reports:**
1. Navigate to **Reports**
2. Toggle between:
   - **Daily View**: See earnings by day
   - **Weekly View**: Track weekly performance
   - **Monthly View**: Monthly earnings overview
3. Use the interactive calendar to navigate dates
4. View status breakdown: Unbilled, Invoiced, Paid

**Check Invoice Status:**
1. Navigate to **Invoices**
2. View all invoices with color-coded statuses:
   - Gray: Draft
   - Blue: Sent/Viewed
   - Yellow: Partially Paid
   - Green: Paid
   - Red: Overdue
3. Click any invoice to view details

### Common Tasks

**Edit a Time Entry:**
- Only **unbilled** and **invoiced** entries can be fully edited
- **Paid** entries: only notes can be edited (data integrity protection)

**Update Invoice Status:**
- Use the status dropdown on the invoice page
- Changes save automatically
- Status updates are tracked

**Delete an Invoice:**
- Navigate to invoice
- Click **Delete** button
- If it's the most recent invoice, the next invoice number is automatically adjusted

**Stop a Running Timer:**
- Click **Stop** in the timer widget
- Or navigate to a different timer and start it (stops the previous one automatically)

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

**Version**: 1.3.0
**Last Updated**: October 2025
**Status**: Production Ready ✅ | Mobile-First Responsive ✅ | Full Payment Tracking ✅
