# frozen_string_literal: true

module CheckLink
  class ShowComponent < ReactComponent
    def initialize(raw_props)
      super("CheckLink", raw_props: raw_props)
    end
  end
end

