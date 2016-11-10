# encoding: utf-8

require "tom_gem/version"

module TomGem
  extend self

  def generate_table_users
    if ActiveRecord::Base.connection.table_exists?(:users)
      Rails.logger.info "user表已经存在"
    else
      create_table :users do |t|
        t.string :mobile
        t.string :email
        t.string :api_token

        t.timestamps null: false
      end
    end
  end

end
