require "test_helper"

describe DriversController do
  # Note: If any of these tests have names that conflict with either the requirements or your team's decisions, feel empowered to change the test names. For example, if a given test name says "responds with 404" but your team's decision is to respond with redirect, please change the test name.
  let (:driver) {
    Driver.create name: "sample driver", vin: "ghbgdsrklp2347bC9", available: true
  }
  describe "index" do
    it "responds with success when there are many drivers saved" do
      # Arrange
      # Ensure that there is at least one Driver saved
      driver
      # # Act
      get drivers_path
      expect(Driver.count).must_equal 1

      # Assert
      must_respond_with :success
    end

    it "responds with success when there are no drivers saved" do
      # Arrange
      # Ensure that there are zero drivers saved

      # Act
      get drivers_path
      expect(Driver.count).must_equal 0

      # Assert
      must_respond_with :success
    end
  end

  describe "show" do
    it "responds with success when showing an existing valid driver" do
      # Arrange
      # Ensure that there is a driver saved
      driver

      # Act
      get driver_path(driver.id)

      # Assert
      must_respond_with :success
    end

    it "responds with 404 with an invalid driver id" do
      # Arrange
      # Ensure that there is an id that points to no driver
      # Act
      get driver_path(-1)
      # Assert
      must_respond_with :not_found
    end
  end

  describe "new" do
    it "responds with success" do
      driver
      get new_driver_path

      must_respond_with :success
    end
  end

  describe "create" do
    it "can create a new driver with valid information accurately, and redirect" do
      # Arrange
      # Set up the form data
      driver_hash = {
          driver: {
              name: "new task",
              vin: 'ghbgdsrklp2347bC9'
          },
      }

      # Act-Assert
      # Ensure that there is a change of 1 in Driver.count
      expect {
        post drivers_path, params: driver_hash
      }.must_change "Driver.count", 1

      # Assert
      # Find the newly created Driver, and check that all its attributes match what was given in the form data
      new_driver = Driver.find_by(name: driver_hash[:driver][:name])
      # Check that the controller redirected the user
      must_respond_with :redirect
      must_redirect_to drivers_path(new_driver.id)
      expect(new_driver.name).must_equal driver_hash[:driver][:name]
      expect(new_driver.vin).must_equal driver_hash[:driver][:vin]
    end

    it "does not create a driver if the form data violates Driver validations, and responds with a redirect" do

      # Note: This will not pass until ActiveRecord Validations lesson
      # Arrange
      # Set up the form data so that it violates Driver validations
      driver_hash = {
          driver: {
              name: nil,
              vin: nil
          }
      }
      # Act-Assert
      # Ensure that there is no change in Driver.count
      expect {
        post drivers_path, params: driver_hash
      }.must_differ "Driver.count", 0

      # Assert
      # Check that the controller redirects
      must_respond_with :bad_request
    end
  end

  describe "edit" do
    it "responds with success when getting the edit page for an existing, valid driver" do

      # Arrange
      # Ensure there is an existing driver saved

      get edit_driver_path(driver.id)

      # Assert
      must_respond_with :success
    end

    it "responds with redirect when getting the edit page for a non-existing driver" do
      # Arrange
      # Ensure there is an invalid id that points to no driver
      get edit_driver_path(-1)

      must_redirect_to root_path
    end
  end

  describe "update" do
    before do
      Driver.create(name: "Bob Smith", vin: "ghbgdsrklp2347bC9", available: true )
    end

    let(:new_driver_hash) {
      {
          driver: {
              name: "Bob Smith",
              vin: "ghbfdcr45klsr5tgh",
              available: true
          },
      }
    }
    it "can update an existing driver with valid information accurately, and redirect" do
      # Arrange
      # Ensure there is an existing driver saved
      # Assign the existing driver's id to a local variable
      # Set up the form data
      id = Driver.first.id

      # Act-Assert
      # Ensure that there is no change in Driver.count
      expect {
        patch driver_path(id), params: new_driver_hash
      }.wont_change "Driver.count"

      must_respond_with :redirect

      driver = Driver.find_by(id: id)
      expect(driver.name).must_equal new_driver_hash[:driver][:name]
      expect(driver.vin).must_equal new_driver_hash[:driver][:vin]

      # Assert
      # Use the local variable of an existing driver's id to find the driver again, and check that its attributes are updated
      # Check that the controller redirected the user
    end

    it "does not update any driver if given an invalid id, and responds with a 404" do
      # Arrange
      # Ensure there is an invalid id that points to no driver
      id = -1
      # Set up the form data


      # Act-Assert
      # Ensure that there is no change in Driver.count
      expect {
        patch driver_path(id), params: new_driver_hash
      }.wont_change "Driver.count"

      
      # Assert
      # Check that the controller gave back a 404
      must_respond_with :not_found
      # must_redirect_to root_path
    end

    it "does not update a driver if the form data violates Driver validations, and responds with a redirect" do

      # Note: This will not pass until ActiveRecord Validations lesson
      # Arrange
      # Ensure there is an existing driver saved
      # Assign the existing driver's id to a local variable

      # Set up the form data so that it violates Driver validations

      # Act-Assert
      # Ensure that there is no change in Driver.count

      # Assert
      # Check that the controller redirects
      new_driver_hash[:driver][:vin] = nil
      driver = Driver.first

      expect {
        patch driver_path(driver.id), params: new_driver_hash
      }.wont_change "Driver.count"

      driver.reload # refresh the driver from the database
      expect(driver.vin).wont_be_nil
      must_respond_with :redirect
      must_redirect_to root_path

    end
  end

  describe "destroy" do
    it "destroys the driver instance in db when driver exists, then redirects" do
      # Arrange
      # Ensure there is an existing driver saved

      # Act-Assert
      # Ensure that there is a change of -1 in Driver.count

      # Assert
      # Check that the controller redirects
      driver_name_to_delete = "Test driver"
      driver_to_delete = Driver.create(name: driver_name_to_delete, vin: "hjkytfd4567fdserv", available: true)

      # Act
      expect {
        delete driver_path(driver_to_delete.id)
      }.must_change "Driver.count", -1

      deleted_driver = Driver.find_by(name: driver_name_to_delete)
      expect(deleted_driver).must_be_nil

      must_respond_with :redirect
      must_redirect_to drivers_path
    end

    it "does not change the db when the driver does not exist, then responds with " do
      # Arrange
      # Ensure there is an invalid id that points to no driver

      # Act-Assert
      # Ensure that there is no change in Driver.count

      # Assert
      # Check that the controller responds or redirects with whatever your group decides
      expect {
        delete driver_path(-1)
      }.wont_change "Driver.count"

      must_respond_with :not_found
    end
  end
end
