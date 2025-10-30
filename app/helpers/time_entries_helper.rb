module TimeEntriesHelper
  def new_entity_link(entity_type)
    return if @time_entry.paid?
    link_to "New #{entity_type}", "#", data: { action: "click->new-entity#toggle#{entity_type}" }, style: "font-size: 0.9em;"
  end
end
