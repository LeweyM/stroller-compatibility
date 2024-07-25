# frozen_string_literal: true

module Search
  class ShowComponent < ReactComponent
    def initialize(raw_props)
      super("Search", raw_props: raw_props)
    end
  end
end

