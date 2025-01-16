# frozen_string_literal: true

module Flipside
  RSpec.describe Values, type: :model do
    let(:feature) do
      Feature.build(
        name: "some_feature",
        description: "Special users only",
        enabled: false
      )
    end

    it "is enabled for the correct key" do
      Value.create(feature:, key: "foobar")

      expect(feature.enabled?("foobar")).to eq(true)
    end

    it "is not enabled for other keys" do
      Value.create(feature:, key: "foobar")

      expect(feature.enabled?("barfoo")).to eq(false)
    end

    it "is not enabled when key is not given" do
      Value.create(feature:, key: "foobar")

      expect(feature.enabled?).to eq(false)
    end
  end
end
