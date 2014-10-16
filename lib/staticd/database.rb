require "data_mapper"

module Staticd
  DataMapper.setup(:default, 'sqlite::memory:')

  # Load models
  require "staticd/model/site"
  require "staticd/model/release"
  require "staticd/model/domain_name"

  DataMapper.finalize
  DataMapper.auto_migrate!
end
