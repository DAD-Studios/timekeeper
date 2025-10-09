class Project < ApplicationRecord
  belongs_to :client
  has_many :time_entries, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :client_id, case_sensitive: false }
  validates :rate, numericality: { greater_than_or_equal_to: 0 }
end
