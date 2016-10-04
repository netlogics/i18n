require 'test_helper'

class I18nSimpleMergeBackendApiTest < I18n::TestCase
  class Backend < I18n::Backend::SimpleMerge
    include I18n::Backend::Pluralization
  end

  def setup
    I18n.backend = I18n::Backend::SimpleMerge.new
    super
  end

  include I18n::Tests::Basics
  include I18n::Tests::Defaults
  include I18n::Tests::Interpolation
  include I18n::Tests::Link
  include I18n::Tests::Lookup
  include I18n::Tests::Pluralization
  include I18n::Tests::Procs
  include I18n::Tests::Localization::Date
  include I18n::Tests::Localization::DateTime
  include I18n::Tests::Localization::Time
  include I18n::Tests::Localization::Procs

  test "make sure we use the SimpleMerge backend" do
    assert_equal I18n::Backend::SimpleMerge, I18n.backend.class
  end
end
