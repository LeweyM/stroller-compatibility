class CompatibleLink < ApplicationRecord
  belongs_to :product_a, class_name: "Product"
  belongs_to :product_b, class_name: "Product"
  belongs_to :adapter, class_name: "Product", optional: true

  # CompatibleLinks should not be created directly,
  # instead, use product.link(!) and product.unlink(!)

  # Flag to allow controlled creation within the model
  class_attribute :allow_creation, default: false

  def self.new(*args)
    raise NoMethodError, "Direct creation is not allowed. Use Product#link! instead." unless allow_creation
    super
  end

  def self.create(*args)
    raise NoMethodError, "Direct creation is not allowed. Use Product#link! instead." unless allow_creation
    super
  end

  def self.create!(*args)
    raise NoMethodError, "Direct creation is not allowed. Use Product#link! instead." unless allow_creation
    super
  end
end
