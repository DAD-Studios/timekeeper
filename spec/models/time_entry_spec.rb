require 'rails_helper'

RSpec.describe TimeEntry, type: :model do
  it { should belong_to(:project) }
  it { should belong_to(:client) }

  it { should validate_presence_of(:task) }

  let(:client) { Client.create!(name: "Test Client") }
  let(:project) { Project.create!(name: "Test Project", client: client, rate: 50.00) }

  describe "#no_running_timer" do
    context "when a timer is already running" do
      before { TimeEntry.create!(task: "Running task", project: project, client: client, status: 'running', start_time: Time.current) }

      it "is not valid" do
        new_time_entry = TimeEntry.new(task: "New task", project: project, client: client, status: 'running')
        expect(new_time_entry).not_to be_valid
        expect(new_time_entry.errors[:base]).to include("A timer is already running. Please stop it before starting a new one.")
      end
    end

    context "when no timer is running" do
      it "is valid" do
        new_time_entry = TimeEntry.new(task: "New task", project: project, client: client, status: 'running')
        expect(new_time_entry).to be_valid
      end
    end
  end

  describe "#stop!" do
    let(:time_entry) { TimeEntry.create!(task: "Test task", project: project, client: client, status: 'running', start_time: 1.hour.ago) }

    it "updates the end_time and status" do
      time_entry.stop!
      expect(time_entry.end_time).to be_present
      expect(time_entry.status).to eq('completed')
    end
  end

  describe "#round_to_5_minutes" do
    let(:time_entry) { TimeEntry.new(task: "Test", project: project, client: client) }

    it "rounds times to nearest 5 minutes" do
      # Test rounding down
      time = Time.parse("2024-01-01 10:02:00")
      rounded = time_entry.send(:round_to_5_minutes, time)
      expect(rounded.strftime("%H:%M")).to eq("10:00")

      # Test rounding up
      time = Time.parse("2024-01-01 10:03:00")
      rounded = time_entry.send(:round_to_5_minutes, time)
      expect(rounded.strftime("%H:%M")).to eq("10:05")

      # Test exact 5 minute mark
      time = Time.parse("2024-01-01 10:05:00")
      rounded = time_entry.send(:round_to_5_minutes, time)
      expect(rounded.strftime("%H:%M")).to eq("10:05")

      # Test rounding with seconds
      time = Time.parse("2024-01-01 10:07:30")
      rounded = time_entry.send(:round_to_5_minutes, time)
      expect(rounded.strftime("%H:%M")).to eq("10:10")
    end
  end

  describe "#calculate_duration with rounding" do
    it "calculates duration based on rounded times" do
      # Start at 10:02:30 (rounds to 10:05)
      # End at 10:33:00 (rounds to 10:35)
      # Expected duration: 30 minutes = 1800 seconds
      time_entry = TimeEntry.create!(
        task: "Test rounding",
        project: project,
        client: client,
        start_time: Time.parse("2024-01-01 10:02:30"),
        end_time: Time.parse("2024-01-01 10:33:00"),
        status: 'completed'
      )

      expect(time_entry.duration_seconds).to eq(1800) # 30 minutes
      expect(time_entry.duration_in_hours).to be_within(0.01).of(0.5) # 30/60 hours
    end
  end

  describe "#calculate_totals_if_completed" do
    let(:time_entry) do
      TimeEntry.new(
        task: "Completed task",
        project: project,
        client: client,
        start_time: 2.hours.ago,
        end_time: 1.hour.ago, # 1 hour duration
        status: 'completed'
      )
    end

    context "when time entry is completed and project has a rate" do
      it "sets the rate and calculates earnings" do
        time_entry.save!
        expect(time_entry.rate).to eq(project.rate)
        expect(time_entry.duration_seconds).to be_present
        expect(time_entry.earnings).to eq(50.00) # 1 hour * 50.00 rate
      end
    end

    context "when time entry is completed but project has no rate" do
      let(:project_without_rate) { Project.create!(name: "No Rate Project", client: client, rate: 0) }
      let(:time_entry_without_rate) do
        TimeEntry.new(
          task: "Completed task without rate",
          project: project_without_rate,
          client: client,
          start_time: 2.hours.ago,
          end_time: 1.hour.ago,
          status: 'completed'
        )
      end

      it "sets earnings to 0" do
        time_entry_without_rate.save!
        expect(time_entry_without_rate.rate).to eq(0)
        expect(time_entry_without_rate.earnings).to eq(0)
      end
    end

    context "when time entry is not completed" do
      let(:running_time_entry) do
        TimeEntry.new(
          task: "Running task",
          project: project,
          client: client,
          start_time: 1.hour.ago,
          status: 'running'
        )
      end

      it "does not set rate or earnings" do
        running_time_entry.save!
        expect(running_time_entry.rate).to be_nil
        expect(running_time_entry.earnings).to be_nil
      end
    end
  end
end
