require 'csv'
require 'mechanize'
# VoysApi exports voys.nl call list..
class VoysApi::Client

  def initialize(username, password)
    @username = username
    @password = password
  end

  def logged_in?
    @logged_in || false
  end

  def login
    return true if @logged_in
    page = agent.get('https://client.voys.nl/user/login/')
    login_form = page.form
    login_form.fields.detect {|field| field.name == 'this_is_the_login_form'} || raise(VoysApi::AuthenticationError, "Could not find the login form!")
    login_form.field_with(:name => "username").value = @username
    login_form.field_with(:name => "password").value = @password
    login_result = agent.submit login_form
    if (login_result.form && login_result.form.fields.detect {|field| field.name == 'this_is_the_login_form'})
      # We're still on the login page!
      raise(VoysApi::AuthenticationError, "Error logging in!")
    end
    @logged_in = true
  end

  # Options:
  #   period_from: '2013-01-01'
  #   period_to: '2013-01-18'
  #   inboundoutbound: 0
  #   totals: 0
  #   aggregation: 0
  #   search_query: nil
  #   reset_filter: false
  #   page_number: nil
  #
  # Empty options returns everything.
  def raw_export(options = {})
    login if not logged_in?
    result = agent.post('/cdr/export', options)
    result.body
  end

  def export(options = {}, csv_options = {})
    csv_options = {col_sep: ';', converters: [:date_time], headers: :first_row, header_converters: :symbol}.merge(options)
    export = CSV.parse(raw_export, csv_options)
    return export
  rescue CSV::MalformedCSVError => exception
    raise exception, "#{exception.message}\nCSV:\n#{raw_export}"
  end

  def logout
    agent.get('https://client.voys.nl/user/logout/')
  end

private

  def agent
    @agent ||= Mechanize.new
  end

end