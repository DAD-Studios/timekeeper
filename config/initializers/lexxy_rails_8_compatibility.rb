# Lexxy 0.1.10.beta was built for Rails 7 and uses the old method name
# In Rails 8, the method was renamed from add_default_name_and_id to add_default_name_and_field
# This patch adds an alias so Lexxy works with Rails 8
module ActionView
  module Helpers
    module Tags
      class Base
        alias_method :add_default_name_and_id, :add_default_name_and_field
      end
    end
  end
end
