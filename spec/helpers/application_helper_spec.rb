# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#translate_status" do
    it "returns translated status when key exists" do
      expect(helper.translate_status("pending")).to be_present
    end

    it "returns titleized status when key missing" do
      expect(helper.translate_status("custom_status")).to eq("Custom Status")
    end

    it "returns blank when status blank" do
      expect(helper.translate_status("")).to eq("")
    end
  end
end
