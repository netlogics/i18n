require 'test_helper'

class I18nBackendSimpleMergeTest < I18n::TestCase
  def setup
    super
    I18n.backend = I18n::Backend::SimpleMerge.new
    I18n.load_path = [locales_dir + '/en.yml']
  end

  # useful because this way we can use the backend with no key for interpolation/pluralization
  test "simple merge backend translate: given nil as a key it still interpolations the default value" do
    assert_equal "Hi David", I18n.t(nil, :default => "Hi %{name}", :name => "David")
  end

  # loading translations
  test "simple merge load_translations: given an unknown file type it raises I18n::UnknownFileType" do
    assert_raise(I18n::UnknownFileType) { I18n.backend.load_translations("#{locales_dir}/en.xml") }
  end

  test "simple merge load_translations: given a Ruby file name it does not raise anything" do
    assert_nothing_raised { I18n.backend.load_translations("#{locales_dir}/en.rb") }
  end

  test "simple merge load_translations: given no argument, it uses I18n.load_path" do
    I18n.backend.load_translations
    assert_equal({ :en => { :foo => { :bar => 'baz' } } }, I18n.backend.send(:translations))
  end

  test "simple merge load_rb: loads data from a Ruby file" do
    data = I18n.backend.send(:load_rb, "#{locales_dir}/en.rb")
    assert_equal({ :en => { :fuh => { :bah => 'bas' } } }, data)
  end

  test "simple merge load_yml: loads data from a YAML file" do
    data = I18n.backend.send(:load_yml, "#{locales_dir}/en.yml")
    assert_equal({ 'en' => {'foo' => { 'bar' => 'baz' } } }, data)
  end

  test "simple merge load_translations: loads data from known file formats" do
    I18n.backend = I18n::Backend::SimpleMerge.new
    I18n.backend.load_translations("#{locales_dir}/en.rb", "#{locales_dir}/en.yml")
    expected = { :en => { :fuh => { :bah => "bas" }, :foo => { :bar => "baz" } } }
    assert_equal expected, translations
  end

  test "simple merge load_translations: given file names as array it does not raise anything" do
    assert_nothing_raised { I18n.backend.load_translations(["#{locales_dir}/en.rb", "#{locales_dir}/en.yml"]) }
  end

  # storing translations

  test "simple merge store_translations: stores translations, ... no, really :-)" do
    store_translations :'en', :foo => 'bar'
    assert_equal Hash[:'en', {:foo => 'bar'}], translations
  end

  test "simple merge store_translations: deep_merges with existing translations" do
    store_translations :'en', :foo => {:bar => 'bar'}
    store_translations :'en', :foo => {:baz => 'baz'}
    assert_equal Hash[:'en', {:foo => {:bar => 'bar', :baz => 'baz'}}], translations
  end

  test "simple merge store_translations: converts the given locale to a Symbol" do
    store_translations 'en', :foo => 'bar'
    assert_equal Hash[:'en', {:foo => 'bar'}], translations
  end

  test "simple merge store_translations: converts keys to Symbols" do
    store_translations 'en', 'foo' => {'bar' => 'bar', 'baz' => 'baz'}
    assert_equal Hash[:'en', {:foo => {:bar => 'bar', :baz => 'baz'}}], translations
  end

  # reloading translations

  test "simple merge reload_translations: unloads translations" do
    I18n.backend.reload!
    assert_nil translations
  end

  test "simple merge reload_translations: uninitializes the backend" do
    I18n.backend.reload!
    assert_equal false, I18n.backend.initialized?
  end

  # merging translations with defaults

  test "simple merge merges default locale" do
    I18n.default_locale = :es
    I18n.backend = I18n::Backend::SimpleMerge.new
    I18n.backend.load_translations("#{locales_dir}/es-MX.yml")
    expected = { :'es-MX' => {:foo => { :bar => "baz" }, :goo => { :car => "caz" } } }
    assert_equal expected, translations
  end

end
