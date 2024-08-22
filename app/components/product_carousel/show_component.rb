# frozen_string_literal: true

module ProductCarousel
  class ShowComponent < ReactComponent
    def initialize(raw_props)
      super("ProductCarousel", raw_props: raw_props)
    end
  end
end

