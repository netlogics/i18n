module I18n
  module Backend
    # An extension to the Simple backend that allows translations to
    # be created from the default locale's translations. Any 
    # key value pairs included in the extending translation file
    # will be merged, overriding corresponding key value pairs 
    # from the default locales translation file. 
    #
    # The implementation is provided by a Implementation module allowing to easily
    # extend Simple backend's behavior by including modules. E.g.:
    #
    # module I18n::Backend::Pluralization
    #   def pluralize(*args)
    #     # extended pluralization logic
    #     super
    #   end
    # end
    #
    # I18n::Backend::Simple.include(I18n::Backend::Pluralization)
    class SimpleMerge < Simple
      def load_yml(filename)
        begin
          filename_yml = YAML.load_file(filename)
          unless default_translation_file?(filename)
            default_yml  = YAML.load_file(default_translation_file(filename))[default_locale]
            locale_name  = locale_from_yml(filename_yml)
            filename_yml = default_yml.merge(filename_yml[locale_name])
            filename_yml = set_locale(filename_yml, locale_name)
          end
          filename_yml
        rescue TypeError, ScriptError, StandardError => e
          raise InvalidLocaleData.new(filename, e.inspect)
        end
      end

      private

      def default_locale
        I18n.locale.to_s
      end

      def default_translation_file filename
        default_translation_file =  [File.dirname(filename).to_s, default_locale].join('/')
        default_translation_file << ".yml"
      end

      def default_translation_file? filename
        filename == default_translation_file(filename)
      end

      def locale_from_yml(yml)
        yml.first[0]
      end

      def set_locale(yml, locale_name)
        {locale_name => yml}
      end
    end
  end
end


