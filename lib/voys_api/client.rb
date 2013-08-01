require 'mechanize'
# VoysApi exports voys.nl call list..
#
# voys_client = VoysApi::Client.new('username', 'password')
# voys_client.export # => "\"Foreign Code\";\"Client\";\"Account...
class VoysApi::Client

  def initialize(username, password)
    @username = username
    @password = password
  end

  def logged_in?
    @logged_in || false
  end

  def login
    @logged_in = true
    page = agent.get('https://client.voys.nl/user/login/')
    login_form = page.form
    login_form.field_with(:name => "username").value = @username
    login_form.field_with(:name => "password").value = @password
    login_result = agent.submit login_form
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

  def export(options = {})
    export = CSV.parse(raw_export, col_sep: ';', converters: [:date_time]) #, headers: :first_row)
    export.shift # Remove header row
    return export
  end

  def logout
    agent.get('https://client.voys.nl/user/logout/')
  end

private

  def agent
    @agent ||= Mechanize.new
  end

end