require "test_helper"

class AzureEnumTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::AzureEnum::VERSION
  end

  def test_lolware_lookup
    assert_equal(["lolzware.onmicrosoft.com", "lolware.net"], AzureEnum.federated("lolware.net"))
  end

end
