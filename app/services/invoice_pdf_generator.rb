class InvoicePdfGenerator
  def initialize(invoice)
    @invoice = invoice
    @profile = Profile.first
  end

  def generate
    Prawn::Document.new do |pdf|
      # Invoice number at top, centered
      pdf.text "INVOICE ##{@invoice.invoice_number}", size: 20, style: :bold, align: :center
      pdf.move_down 20

      # Header with logo (half size) on left, profile info below
      y_position = pdf.cursor

      # Left side - Logo and Profile Info
      pdf.bounding_box([0, y_position], width: 250) do
        if @profile&.show_logo && @profile.logo.attached?
          begin
            logo_path = ActiveStorage::Blob.service.send(:path_for, @profile.logo.key)
            pdf.image logo_path, width: 56, position: :left
            pdf.move_down 10
          rescue => e
            # Logo failed to load, continue without it
          end
        end

        pdf.text @profile&.display_name || "Your Business", size: 14, style: :bold
        if @profile&.individual? && @profile.title.present?
          pdf.text @profile.title, size: 9, color: "666666"
        end
        pdf.text @profile&.email || "", size: 9 if @profile&.email.present?
        pdf.text @profile&.phone || "", size: 9 if @profile&.phone.present?

        if @profile&.full_address.present?
          @profile.full_address.split("\n").each do |line|
            pdf.text line, size: 9
          end
        end
      end

      # Right side - Client Info
      pdf.bounding_box([pdf.bounds.width - 250, y_position], width: 250) do
        pdf.text "Bill To:", size: 12, style: :bold, align: :right
        pdf.text @invoice.client.name, size: 10, align: :right
        pdf.text "Attn: #{@invoice.client.contact_name}", size: 9, align: :right if @invoice.client.contact_name.present?
        pdf.text @invoice.client.email, size: 9, align: :right if @invoice.client.email.present?
        pdf.text @invoice.client.phone, size: 9, align: :right if @invoice.client.phone.present?

        if @invoice.client.full_address.present?
          @invoice.client.full_address.split("\n").each do |line|
            pdf.text line, size: 9, align: :right
          end
        end

        pdf.move_down 10
        pdf.text "Date: #{@invoice.invoice_date.strftime('%B %d, %Y')}", size: 9, align: :right
        pdf.text "Due: #{@invoice.due_date.strftime('%B %d, %Y')}", size: 9, align: :right
      end

      pdf.move_down 75

      # Group line items by project
      grouped_items = @invoice.line_items.includes(:time_entry).group_by do |item|
        item.time_entry&.project || nil
      end

      # Line Items - grouped by project
      grouped_items.each do |project, items|
        if project
          pdf.text project.name, size: 12, style: :bold, color: "333333"
          pdf.move_down 5
        end

        table_data = [["Description", "Hours", "Rate", "Amount"]]
        items.each do |item|
          table_data << [
            item.description,
            sprintf('%.2f', item.quantity),
            "$#{sprintf('%.2f', item.rate)}",
            "$#{sprintf('%.2f', item.amount)}"
          ]
        end

        pdf.table(table_data, width: pdf.bounds.width, cell_style: { borders: [:bottom], border_color: "CCCCCC", padding: [5, 10] }) do
          row(0).font_style = :bold
          row(0).background_color = "F5F5F5"
          row(0).borders = [:top, :bottom]
          row(0).border_width = 2
          columns(1..3).align = :right
        end

        # Project subtotal if there are multiple projects
        if grouped_items.keys.length > 1
          project_total = items.sum(&:amount)
          pdf.indent(pdf.bounds.width - 200) do
            pdf.text "#{project&.name || 'Other'} Subtotal: $#{sprintf('%.2f', project_total)}",
                     size: 10, style: :bold, align: :right
          end
        end

        pdf.move_down 15
      end

      # Totals
      pdf.move_down 10
      pdf.indent(pdf.bounds.width - 200) do
        pdf.text "Subtotal: $#{sprintf('%.2f', @invoice.subtotal)}", align: :right, size: 11
        if @invoice.discount_amount.to_f > 0
          pdf.text "Discount: -$#{sprintf('%.2f', @invoice.discount_amount)}", align: :right, size: 11
        end
        pdf.move_down 5
        pdf.text "Total: $#{sprintf('%.2f', @invoice.total)}", align: :right, style: :bold, size: 14
      end

      # Notes - use invoice notes if present, otherwise use profile default
      notes = @invoice.notes.presence || @profile&.default_invoice_notes
      if notes.present?
        pdf.move_down 30
        pdf.text "Notes:", style: :bold, size: 12
        pdf.move_down 5
        notes_text = notes.to_plain_text
        pdf.text notes_text, size: 10
      end

      # Payment Instructions - use invoice payment_instructions if present, otherwise use profile default
      payment_instructions = @invoice.payment_instructions.presence || @profile&.default_payment_instructions
      if payment_instructions.present?
        pdf.move_down 20
        pdf.text "Payment Instructions:", style: :bold, size: 12
        pdf.move_down 5
        payment_text = payment_instructions.to_plain_text
        pdf.text payment_text, size: 10
      end
    end
  end
end
