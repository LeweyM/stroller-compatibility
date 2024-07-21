require "application_system_test_case"

class StrollersTest < ApplicationSystemTestCase
  setup do
    @stroller = strollers(:one)
  end

  test "visiting the index" do
    visit strollers_url
    assert_selector "h1", text: "Strollers"
  end

  test "should create stroller" do
    visit strollers_url
    click_on "New stroller"

    fill_in "Brand", with: @stroller.brand_id
    fill_in "Name", with: @stroller.name
    click_on "Create Stroller"

    assert_text "Stroller was successfully created"
    click_on "Back"
  end

  test "should update Stroller" do
    visit stroller_url(@stroller)
    click_on "Edit this stroller", match: :first

    fill_in "Brand", with: @stroller.brand_id
    fill_in "Name", with: @stroller.name
    click_on "Update Stroller"

    assert_text "Stroller was successfully updated"
    click_on "Back"
  end

  test "should destroy Stroller" do
    visit stroller_url(@stroller)
    click_on "Destroy this stroller", match: :first

    assert_text "Stroller was successfully destroyed"
  end
end
