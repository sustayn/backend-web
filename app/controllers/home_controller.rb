class HomeController < ApplicationController
  def index
    if Rails.env.development?
      html = ActiveRecord::Base.connection.execute("SELECT value FROM ember_corvae_bootstrap WHERE key='default'").first['value']
      render html: process_index_dev(html).html_safe and return
    elsif params[:revision]
      html = ActiveRecord::Base.connection.execute("SELECT value FROM ember_corvae_bootstrap WHERE key=#{ActiveRecord::Base.sanitize(params[:revision])}").first['value']
      render html: html.html_safe and return
    else
      rev_key = ActiveRecord::Base.connection.execute("SELECT value FROM ember_corvae_bootstrap WHERE key='current'").first['value']
      html = ActiveRecord::Base.connection.execute("SELECT value FROM ember_corvae_bootstrap WHERE key=#{ActiveRecord::Base.sanitize(rev_key)}").first['value']
      render html: thml.html_safe and return
    end
  end

  private

  def process_index_dev(index_string)
    index_string.gsub('assets', 'http://localhost:4200/assets');
  end
end
